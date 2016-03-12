//////////////////////////////////////////////////////////////////////////////////////////////
// Public Domain Steppen controller + my own interface to my track design
// version 1.0
// by Eric Kathmann, 2016, eric.trein@gmail.com
//
// This file is public domain.  Use it for any purpose, including commercial
// applications.  Attribution would be nice, but is not required.  There is
// no warranty of any kind, including its correctness, usefulness, or safety.


#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include <stdbool.h>
#include <avr/pgmspace.h>
#include <avr/eeprom.h>
#include <avr/wdt.h>

#include "pulseTable.h"

//
// Eeprom Adres offset = 0  blok spanning commandos zoals een blok aansturing behalve support voor seinpalen
// Eeprom Adres offset = 1  relais aansturing 0x3f = richting normaal 0x3e = richting inverted alle andere waardes worden voor de blokrelais selectie waarvan ik alleen 0..5 in gebruik heb
// Eeprom Adres offset = 2  positie commando 0x3f = get turn status return is TURNING or TURNING_DONE


// Stepping defines
#define MS1 (1<<PB3)
#define MS2 (1<<PB4)
#define MS3 (1<<PB5)

#define FULL_STEP 0
#define HALF_STEP (MS1)
#define QUARTER_STEP (MS2)
#define EIGHT_STEP (MS1 + MS2)
#define SIXTEENTH_STEP (MS3)
#define STEPPING EIGHT_STEP
//
// tandwiel 1:20  motor 200 steps per rotation in 1/8 steps geeft 20x200x8=32000
//
#define FULL_CIRCLE (32000)


#define VOORUIT		1
#define ACHTERUIT	2
#define GROEN		61
#define GEEL		62
#define ROOD		63

#define kortSluitCount     r14
// met hoeveel moet er gedecimeerd worden note waarde + 1
// Doordat ik om de 5 cycles 1 puls uitstuur zorg ik ervoor
// dat het patroon van de ad conversies niet verstoord wordt.
#define KORTSLUIT_DECIMATIE 4

#define HIGH_LEVEL	((255-25)<<8)//de positive spannings voor kortsluit detectie
#define LOW_LEVEL	(25<<8)	//de negative spannings voor kortsluit detectie

// de drempels voor detectie van kortsluiting zijn wat laag want sommige
// locomotiven trekken veel stroom bij het aanzetten. Het gevaar bestaat nu wel
// van overbelasting. Ik kan goed kortsluiting detecteren maar geen overbelasting.
// Dus de eindtransistoren kunnen te heet worden bij grote belasting. Dit kan
// bijvoorbeeld in dubbel tractie bedrijf gebeuren als er twee locs gebruikt worden
// die veel stroom trekken.
// mmm ik kom op 175 op de test print en dat is niet genoeg voor hoog dus even -85 ipv 70
// TODO verklaar
#define HIGH_LEVEL_DREMPEL	((255-85)<<8)	//de positive spannings drempel voor kortsluit detectie
#define LOW_LEVEL_DREMPEL	((70)<<8)	//de negative spannings drempel voor kortsluit detectie
#define KORTSLUIT_SPANNING	1	// stand 1 van de regelaar. Hangt nu af van wat er in
                    // de tabel staat
#define SYNC_COUNT 127

// de twee ontvangen data bytes van de uart
volatile uint8_t uartData1;
volatile uint8_t uartData2;
volatile uint8_t byteCount;
volatile bool inSync; // in assembly is dit state  met 0=outof sync  en 1 = insync
volatile uint8_t brugBlokDDR; // saved DDR statuis voor de AD conversie
uint8_t syncCount;
volatile bool doHoming;

#define AANTAL_PULSEN 63
volatile uint8_t pulseBreedteCount; // AANTAL_PULSEN=63
volatile uint8_t snelheid; // 0..63 en 0x80 is de richting
volatile bool middenDetectie;
volatile bool middenDetected;
volatile uint16_t blokOn;
volatile uint16_t blokOff;

const int16_t EEMEM stepTabelRom[48][2] =
{
    {0,                                    0},
    {(int16_t)(1.0/48.0*FULL_CIRCLE),      (int16_t)(1.0/48.0*FULL_CIRCLE)},
    {(int16_t)(2.0/48.0*FULL_CIRCLE),      (int16_t)(2.0/48.0*FULL_CIRCLE)},
    {(int16_t)(3.0/48.0*FULL_CIRCLE),      (int16_t)(3.0/48.0*FULL_CIRCLE)},
    {(int16_t)(4.0/48.0*FULL_CIRCLE),      (int16_t)(4.0/48.0*FULL_CIRCLE)},
    {(int16_t)(5.0/48.0*FULL_CIRCLE),      (int16_t)(5.0/48.0*FULL_CIRCLE)},
    {(int16_t)(6.0/48.0*FULL_CIRCLE),      (int16_t)(6.0/48.0*FULL_CIRCLE)},
    {(int16_t)(7.0/48.0*FULL_CIRCLE),      (int16_t)(7.0/48.0*FULL_CIRCLE)},
    {(int16_t)(8.0/48.0*FULL_CIRCLE),      (int16_t)(8.0/48.0*FULL_CIRCLE)},
    {(int16_t)(9.0/48.0*FULL_CIRCLE),      (int16_t)(9.0/48.0*FULL_CIRCLE)},
    {(int16_t)(10.0/48.0*FULL_CIRCLE),     (int16_t)(10.0/48.0*FULL_CIRCLE)},
    {(int16_t)(11.0/48.0*FULL_CIRCLE),     (int16_t)(11.0/48.0*FULL_CIRCLE)},
    {(int16_t)(12.0/48.0*FULL_CIRCLE),     (int16_t)(12.0/48.0*FULL_CIRCLE)},
    {(int16_t)(13.0/48.0*FULL_CIRCLE),     (int16_t)(13.0/48.0*FULL_CIRCLE)},
    {(int16_t)(14.0/48.0*FULL_CIRCLE),     (int16_t)(14.0/48.0*FULL_CIRCLE)},
    {(int16_t)(15.0/48.0*FULL_CIRCLE),     (int16_t)(15.0/48.0*FULL_CIRCLE)},
    {(int16_t)(16.0/48.0*FULL_CIRCLE),     (int16_t)(16.0/48.0*FULL_CIRCLE)},
    {(int16_t)(17.0/48.0*FULL_CIRCLE),     (int16_t)(17.0/48.0*FULL_CIRCLE)},
    {(int16_t)(18.0/48.0*FULL_CIRCLE),     (int16_t)(18.0/48.0*FULL_CIRCLE)},
    {(int16_t)(19.0/48.0*FULL_CIRCLE),     (int16_t)(19.0/48.0*FULL_CIRCLE)},
    {(int16_t)(20.0/48.0*FULL_CIRCLE),     (int16_t)(20.0/48.0*FULL_CIRCLE)},
    {(int16_t)(21.0/48.0*FULL_CIRCLE),     (int16_t)(21.0/48.0*FULL_CIRCLE)},
    {(int16_t)(22.0/48.0*FULL_CIRCLE),     (int16_t)(22.0/48.0*FULL_CIRCLE)},
    {(int16_t)(23.0/48.0*FULL_CIRCLE),     (int16_t)(23.0/48.0*FULL_CIRCLE)},
    {(int16_t)(24.0/48.0*FULL_CIRCLE),     (int16_t)(24.0/48.0*FULL_CIRCLE)},
    {(int16_t)(25.0/48.0*FULL_CIRCLE),     (int16_t)(25.0/48.0*FULL_CIRCLE)},
    {(int16_t)(26.0/48.0*FULL_CIRCLE),     (int16_t)(26.0/48.0*FULL_CIRCLE)},
    {(int16_t)(27.0/48.0*FULL_CIRCLE),     (int16_t)(27.0/48.0*FULL_CIRCLE)},
    {(int16_t)(28.0/48.0*FULL_CIRCLE),     (int16_t)(28.0/48.0*FULL_CIRCLE)},
    {(int16_t)(29.0/48.0*FULL_CIRCLE),     (int16_t)(29.0/48.0*FULL_CIRCLE)},
    {(int16_t)(30.0/48.0*FULL_CIRCLE),     (int16_t)(30.0/48.0*FULL_CIRCLE)},
    {(int16_t)(31.0/48.0*FULL_CIRCLE),     (int16_t)(31.0/48.0*FULL_CIRCLE)},
    {(int16_t)(32.0/48.0*FULL_CIRCLE),     (int16_t)(32.0/48.0*FULL_CIRCLE)},
    {(int16_t)(33.0/48.0*FULL_CIRCLE),     (int16_t)(33.0/48.0*FULL_CIRCLE)},
    {(int16_t)(34.0/48.0*FULL_CIRCLE),     (int16_t)(34.0/48.0*FULL_CIRCLE)},
    {(int16_t)(35.0/48.0*FULL_CIRCLE),     (int16_t)(35.0/48.0*FULL_CIRCLE)},
    {(int16_t)(36.0/48.0*FULL_CIRCLE),     (int16_t)(36.0/48.0*FULL_CIRCLE)},
    {(int16_t)(37.0/48.0*FULL_CIRCLE),     (int16_t)(37.0/48.0*FULL_CIRCLE)},
    {(int16_t)(38.0/48.0*FULL_CIRCLE),     (int16_t)(38.0/48.0*FULL_CIRCLE)},
    {(int16_t)(39.0/48.0*FULL_CIRCLE),     (int16_t)(39.0/48.0*FULL_CIRCLE)},
    {(int16_t)(40.0/48.0*FULL_CIRCLE),     (int16_t)(40.0/48.0*FULL_CIRCLE)},
    {(int16_t)(41.0/48.0*FULL_CIRCLE),     (int16_t)(41.0/48.0*FULL_CIRCLE)},
    {(int16_t)(42.0/48.0*FULL_CIRCLE),     (int16_t)(42.0/48.0*FULL_CIRCLE)},
    {(int16_t)(43.0/48.0*FULL_CIRCLE),     (int16_t)(43.0/48.0*FULL_CIRCLE)},
    {(int16_t)(44.0/48.0*FULL_CIRCLE),     (int16_t)(44.0/48.0*FULL_CIRCLE)},
    {(int16_t)(45.0/48.0*FULL_CIRCLE),     (int16_t)(45.0/48.0*FULL_CIRCLE)},
    {(int16_t)(46.0/48.0*FULL_CIRCLE),     (int16_t)(46.0/48.0*FULL_CIRCLE)},
    {(int16_t)(47.0/48.0*FULL_CIRCLE),     (int16_t)(47.0/48.0*FULL_CIRCLE)}
};

// vreemd ik moet de volgoorde andersom zetten anders is de ordering niet EepromAdres en dan Type zoals in assembly
const uint8_t EEMEM EepromType=3;
const uint16_t EEMEM EepromAdres=300;


//
// variabelen voor de draaiactie
//
#define TURNING_DONE 0
#define TURNING 1
volatile int16_t step = 0;
uint8_t huidigePositie=0;
bool    huidigePosititieTweedeIndex;
int16_t stepTabel[48][2];
uint8_t decimateDrempel=40; // word ook in Homing gezet
uint8_t huisDecimation;
bool needsHoming = true;

void Homing()
{
    if (doHoming)
    {
        if (PINC & (1<<PC2))
        {
            huidigePositie = 0;
            PORTB |= (1<<PB0); // terug
            step = 32000;
            decimateDrempel = 4;
        }
        else
        {
            // klaar
            decimateDrempel = 40;
            step = stepTabel[0][0];
            if (step>=0)
            {
                PORTB &= ~(1<<PB0); //vooruit
            }
            else
            {
                PORTB |= (1<<PB0); // terug
                step = -step;
            }
            doHoming = false;
            needsHoming = false;
        }
    }

}

void StepControl()
{
    static uint8_t decimate;
    Homing();
    decimate+=1;
    if ((decimate>(decimateDrempel)) && (step!=0))
    {
        decimate=0;
        step -= 1;
        PORTB |= (1<<DDB1);
    }

    static uint8_t drempelSturing =0;
    drempelSturing += 1;
    if (drempelSturing > 250)
    {
        drempelSturing =0;
        if (step>800)
        {
            decimateDrempel -= (decimateDrempel>=2) ? 1: 0;
        }
        else
        {
            decimateDrempel += (decimateDrempel<30) ? 1: 0;
        }
    }
    PORTB &= ~(1<<DDB1);
}

ISR(USART_RXC_vect)
{
    uartData1 = uartData2;
    uartData2 = UDR;
    if (!inSync)
    {
        // out of sync
        // set het brugblok uit
        DDRD &= ~(1<<PD7);
        PORTD &= ~(1<<PD7);
        if ((uartData1 ==0) && (uartData2==0))
        {
            // sync gevonden
            byteCount = 2;
        }
    }
    else
    {
        // main programma zet deze op 0 als we 2 bytes bereiken
        byteCount += 1;
        // nu eerst de DA converter starten
        // save de status van het brugblok bij de start van de AD converter
        brugBlokDDR = DDRD;
        ADCSR |= (1<<ADSC); // start de AD conversie de multiplexer word nu niet ingesteld ik neem aan dat die goed staat voor 1 blok
        StepControl();
        if (middenDetectie)
        {
            if ((PINC & (1<<PC3)) == 0)
            {
                // loc detected
                middenDetected = true;
                snelheid = snelheid &0x80; // onthoud richting
            }
        }

        uint8_t pulse = pgm_read_byte(&pulseTabel[snelheid&0x3f][pulseBreedteCount>>3]);
        if (pulse & (1<<(pulseBreedteCount&0x7)))
        {
            // moet spanning geleverd worden
            // toevalig zit brugBlok op bit 7 en is riching bepaald door bit 7 in snelheid:)
            PORTD = (snelheid&0x80) | (PORTD&0x7f);
            DDRD |= (1<<DDD7);
        }
        else
        {
            // geen spanning dus uitgang zwevend (geen pullup dus port op 0
            PORTD &= ~(1<<DDD7);
            DDRD &= ~(1<<DDD7);
        }


        pulseBreedteCount += 1;
        if (pulseBreedteCount == AANTAL_PULSEN)
        {
            pulseBreedteCount=0;
            // zit nog iets meer aanvast
        }

    }
}



// tijdelijk voor testen
ISR(USART_UDRE_vect)
{
//    UDR = 0xf0;
}


ISR(ADC_vect)
{
    // het gesampled signaal wordt met het volgende filter behandeld
    // output = 1/16 * input + (1-1/16) * output
    // Daar ik geen vermenigvuldiger heb splits ik de temp (1-1/16) in
    // de volgende expressie
    // output = 1/16 * input + output - 1/16 * output
    // De berekening wordt in 16 bit arthematic gedaan want anders
    // verlies ik teveel bitten van de input. Via de UART geef ik het
    // MSB deel terug (zonder afronding).
    // Ik ge er hier vanuit dat input en output op de zelfde manier
    // geschaald zijn dit is helaas op de hardware niet het geval.
    // de ad heeft de volgend verdeling
    // bit 7 6 5 4 3 2 1 0
    // MSB 0 0 0 0 0 0 x x
    // LSB x x x x x x x x
    // waarbij x een AD bit is. Tezien is dat het 16bit getal uit de AD
    // geheel naar beneden is geschaald. Wil ik zodadelijk alleen het MSB
    // uit het filter pakken dan gooi ik bijna alle bitten weg. Dus moet
    // het AD getal met 64 vermenigvuldigd worden
    uint16_t input = ADCL + (ADCH<<8);

    // voor output = 1/16 * input + output - 1/16 * output
    // moet ok input eerst * 64 en dan * 1/16 doen. Dat is het AD
    // signaal * 4
    //input <<= 2;
    //input <<= 1;



    // Nu gaan we output ophalen. We gebruiken voor
    // elk kanaal een appart filter en ook een
    // apart filter voor spanning en geen spanning
    //
    // convert adInput number to a bit mask

    uint16_t output = blokOff;
    if (brugBlokDDR & (1<<DDD7))
    {
        output = blokOn;
    }


    // goed we hebben nu output dus eerst output bij 1/16*input
    // optellen. Bij deze optelling kan een overflow onstaan gelukkig
    // is het filter zo dat ik kan garanderen dat input en output binnen
    // een 16bit word passen dus zal een evetuele tijdelijk overflow in een
    // tussen resultaat geen probleem opleveren.
    //output = input+output - (output>>4);
    output = input+output - (output>>6);

    if (brugBlokDDR & (1<<DDD7))
    {
        // blok heeft spanning
        if ((output > LOW_LEVEL_DREMPEL) && (output < HIGH_LEVEL_DREMPEL))
        {
            // spanning binnen low en high dus concludeer ik kortsluiting
            // zet dit blok nu uit
            DDRD &= ~(1<<DDD7);
            snelheid |= 0x40;  // zet bit 6 om kortsluiting te melden
        }
        blokOn = output;
    }
    else
    {
        blokOff = output;
    }
}

void updatePosition(int8_t update, bool alternateTable)
{
    stepTabel[huidigePositie][alternateTable] += update;
    if (huidigePositie == 0)
    {
        // voor de home position alles tabel entries updaten
        for (int i=1;i<48;i++)
        {
            stepTabel[i][alternateTable] += update;
        }
    }
    if (update>=0)
    {
        PORTB &= ~(1<<PB0);
        step = update;
    }
    else
    {
        PORTB |= (1<<PB0);
        step = -update;
    }
}

void huisVerlichting( bool aan)
{
    if (aan)
    {
        PORTC &= ~(1<<PC4);
        huisDecimation = 0;
    }
    else
        PORTC |= (1<<PC4);
}

void main()
{
    //PORTD = (1 << DDD6) | (1 << DDD7); // bit 6..7 pullup
    DDRD = (1 << DDD2)| (1 << DDD3)| (1 << DDD4)| (1 << DDD5)| (1 << DDD6); // 2..6 output 7 input
    PORTD = 31 <<2; // alle Blok Relais uit d2..d6

    // uitgang
    // PC1 richting relais
    // PC4 Led Lamp
    // ingang
    // PC2 Homing
    // PC3 Platform middel
    DDRC = (1 << DDC1) | (1 << DDC4);

    DDRB = (1 << DDB0)| (1 << DDB1)| (1 << DDB2)| (1 << DDB3)| (1 << DDB4)| (1 << DDB5); // 0..5 output
    PORTB = (1<<PB2) + STEPPING;  // motor disabled and fullstep enable alleen als we een draai commando krijgen


    // initialize de AD converter
    //   7     6     5     4     3     2     1     0
    // ADEN  ADSC  ADFR  ADIF  ADIE  ADPS2 ADPS1 ADPS0
    // we enablen de ad converter ADEN en enablen de interrupt ADIE
    // en we selecteren division factor 128 en dat geeft
    // ADPS2=1 ADPS1=1 ADPS0=1 zie table 22 op blz 56 van het databook
    // met een klok van 14.7453Mhz en de deler op 128 geeft een AD klok van 115 Khz
    ADCSR =  (1<<ADEN) + (1<<ADIE)+(1<<ADPS2) + (1<<ADPS1) + (1<<ADPS0);

    for (int i=0;i<48;i++)
    {
        stepTabel[i][0] = eeprom_read_word((uint16_t*)&stepTabelRom[i][0]);
        stepTabel[i][1] = eeprom_read_word((uint16_t*)&stepTabelRom[i][1]);
    }


    //zet de baud rate van de uart 28800 met 14.7456Mhz
    // klok.geeft 31 voor de deler
    UBRRL = 31;

    // voor atmega8 hoef ik niet de UBRRH te initializeren want die
    // is default 0
    // U2X is ook default 0. Ik gebruik de highspeed mode niet

    // zet de uart aan
    //   7     6     5     4     3     2     1     0
    // RXCIE TXCIE UDRIE RXEN  TXEN  CHR9  RXB8  TXB8
    // dit is voor een blok
    UCSRB = (1<<RXCIE)+(1<<RXEN)+(1<<TXEN);
    // tijdelijk voor test
    //UCSRB =(1<<RXCIE)+(1<<UDRIE)+(1<<RXEN)+(1<<TXEN);
    //UDR = 0xf0;
    //UCSRA = 0; //(1<<UDRE);

    byteCount = 0;
    syncCount = SYNC_COUNT;
    uartData1 = uartData2 = 1; // geen 0 want er is geen sync
    wdt_enable(WDTO_60MS);
    sei ();
    huisVerlichting(false);

    do
    {
        while(byteCount!=2);
        byteCount = 0;
        // er zijn 2 bytes
        syncCount -= 1;
        if (syncCount)
        {

            if ((uartData1==0) && (uartData2==0))
            {
                // we hebben een sync
                syncCount = SYNC_COUNT;
                pulseBreedteCount = 0;
                uartData1 = uartData2 = 1;// geen 0 want er is geen sync
                inSync = true;
                if (step == 0)
                {
                    huisDecimation += 1;
                    if (huisDecimation == 250)
                    {
                        huisVerlichting(false);
                    }
                }
                wdt_reset();
            }
            else
            {
                // in de assembly van de blok controller word naar een adres 0 gekeken naar een reset commando, Ik geloof niet dat ik daar gebruik van maak
                uint16_t adres = uartData1 | ((uartData2&0x3)<<8);
                uint8_t data = uartData2 >> 2;

                uint16_t startAdres = eeprom_read_word (&EepromAdres);
                cli();
                if (startAdres == adres)
                {
                    //blok ccommandos
                    if (data==VOORUIT)
                    {
                        snelheid |= 0x80;
                        UDR = blokOn >> 8;
                        blokOn = HIGH_LEVEL;
                    }
                    else if (data==ACHTERUIT)
                    {
                        snelheid &= ~0x80;
                        UDR = blokOn >> 8;
                        blokOn = LOW_LEVEL;
                    }
                    else if (data>= GROEN)
                    {
                        // bij kortsluiting (bit 6 van snelheid) geef 0 terug
                        UDR = (snelheid&0x40) ? 0: (blokOff >> 8);
                    }
                    else if (data ==0)
                    {

                        UDR = blokOff >> 8;
                        snelheid = snelheid &0x80; // onthoud richting
                        middenDetected = false;
                        middenDetectie = false;  // reset de midden detectie
                        // reset de blok on meeting
                        blokOn = (snelheid & 0x80) ?  HIGH_LEVEL: LOW_LEVEL;

                    }
                    else
                    {
                        // snelheid commando
                        // bij kortsluiting (bit 6 van snelheid) geef 0 terug
                        UDR = (snelheid&0x40) ? 0: (blokOff >> 8);
                        if (middenDetected == false)
                        {
                            // alleen een snelheid update als er nog geen midden detectie gedaan is.
                            snelheid = (snelheid &0xc0) | data; // onthoud richting en kortsluiting
                        }

                    }

                }
                else if ((startAdres+1) == adres)
                {
                    // blok relais aaansturing
                    if (data == 0x3f)
                    {
                        PORTC |= (1<<PC1);
                    }
                    else if (data == 0x3e)
                    {
                        PORTC &= ~(1<<PC1);
                    }
                    else
                    {
                        // relais pd2..pd6
                        PORTD = (PORTD & 0b10000011) | ((data&0b011111)<<2);
                    }
                    UDR = 0; // misschien iets van de detectors
                }
                else if (((startAdres+2) == adres) || ((startAdres+3) == adres))
                {
                    bool tweedeIndex = ((startAdres+3) == adres);

                    // draai commando
                    huisVerlichting(true);
                    if (data<=60)
                    {
                        PORTB = STEPPING;  // motor enabled and fullstep
                    }

                    if (data<48)
                    {
                        if (huidigePositie == data)
                        {
                        }
                        else
                        {
                            int16_t naar = stepTabel[data][tweedeIndex];
                            int16_t van = stepTabel[huidigePositie][huidigePosititieTweedeIndex];
                            if (huidigePositie < data)
                            {
                                PORTB &= ~(1<<PB0);
                                step = naar - van;

                            }
                            else
                            {
                                PORTB |= (1<<PB0);
                                step = van - naar;
                            }
                            huidigePositie = data;
                            huidigePosititieTweedeIndex = tweedeIndex;
                        }
                    }
                    // 0 ..47 ga naar positie
                    // updates in de stap tabel
                    // 48,49 +1 -1
                    // 50,51 +2 -2
                    // 52,53 +4 -4
                    // 54,55 +8,-8
                    // 56,57 +16,-16
                    // 58,59 +32,-32
                    // eind updates in de stap tabel
                    // 60 home
                    // 61 enable midden detectie met zet snelheid =0 reset de middenDetectie
                    // 62 write eeprom staptabel
                    // 63 get bitfiled status bit 0 = TURNING  bit 1 = middenDetected  bit 2 = needsHoming

                    else if (data==48)
                    {
                        updatePosition(1,tweedeIndex);
                    }
                    else if (data==49)
                    {
                        updatePosition(-1,tweedeIndex);
                    }
                    else if (data==50)
                    {
                        updatePosition(2,tweedeIndex);
                    }
                    else if (data==51)
                    {
                        updatePosition(-2,tweedeIndex);
                    }
                    else if (data==52)
                    {
                        updatePosition(4,tweedeIndex);
                    }
                    else if (data==53)
                    {
                        updatePosition(-4,tweedeIndex);
                    }
                    else if (data==54)
                    {
                        updatePosition(8,tweedeIndex);
                    }
                    else if (data==55)
                    {
                        updatePosition(-8,tweedeIndex);
                    }
                    else if (data==56)
                    {
                        updatePosition(16,tweedeIndex);
                    }
                    else if (data==57)
                    {
                        updatePosition(-16,tweedeIndex);
                    }
                    else if (data==58)
                    {
                        updatePosition(32,tweedeIndex);
                    }
                    else if (data==59)
                    {
                        updatePosition(-32,tweedeIndex);
                    }
                    else if ((data==60) && (PINC & (1<<PC2))) // alleen als we geen contact zien anders kunnen we door de hystiresus gaan schuiven
                    {
                        doHoming = true;
                        step = 1; // correct status
                    }
                    else if (data==61)
                    {
                        middenDetectie = true;
                    }
                    else if (data==62)
                    {
                        // dit duurt telang zodat het antwoord niet optijd is.
                        sei ();
                        UDR = ((step == 0) ? TURNING_DONE : TURNING) + middenDetected*2;
                        for (int i=0;i<48;i++)
                        {
                            eeprom_write_word((uint16_t*)&stepTabelRom[i][0], (uint16_t)stepTabel[i][0]);
                            eeprom_write_word((uint16_t*)&stepTabelRom[i][1], (uint16_t)stepTabel[i][1]);
                        }
                        cli();
                    }
                    else if (data==0x3f)
                    {
                    }

                    if (data !=62)
                    {
                        // voor alle gevallen return waarde maar behalve voor eeprom write want die is al gedaan
                        UDR = ((step == 0) ? TURNING_DONE : TURNING) + middenDetected*2 + needsHoming*4;
                    }

                }
                sei ();
            }
        }
        else
        {

        }


    }
    while(1);
}
/*
CKOPT CKSEL3..1 Frequency Range (MHz) Recommended Range for Capacitors C1 and C2 for Use with Crystals (pF)
1   101 (1) 0.4 - 0.9   –
1   110     0.9 - 3.0   12 - 22
1   111     3.0 - 8.0   12 - 22

CKSEL0 SUT1..0 Start-up Timefrom Power-down and Power-save 0 00 258 CK (1) 4.1ms Ceramic resonator, fastrising power
0   01  258     CK (1)  65ms Ceramic resonator, slowlyrising power
0   10  1K      CK (2)  – Ceramic resonator, BODenabled
0   11  1K      CK (2)  4.1ms Ceramic resonator, fastrising power
1   00  1K      CK (2)   65ms Ceramic resonator, slowlyrising power
1   01  16K     CK      – Crystal Oscillator, BODenabled
1   10  16K     CK      4.1ms Crystal Oscillator, fastrising power
1   11  16K     CK      65ms Crystal Oscillator, slowlyrising power


van blok programming
            // notes voor de fuses
            // 00011111 are the fuse bits read from an ATmega8
            // 0xxxxxxx - BODLEVEL 4V (default 2.7V)
            // x0xxxxxx - brownout detection enabled
            // xxSUxxxx - reset delay, datasheet p28
            // xxxxCKSE - clock select, datasheet p24
            sprintf (text,
                     "avrdude -P usb -c avrispmkii -p %s -B8 -U flash:w:%s8.hex:i -U eeprom:w:%s8_eeprom.hex:i "
                     "-U eeprom:w:0x%x,0x%x:m -U lfuse:w:0b00011111:m",
                     deviceString[device],
                     blokFile, blokFile, adres & 0xff, adres >> 8);

CKOPT=1 CKSEL3..1 = 7
CKSEL0=1 SUT1..0=3
dus onze fuses worden dit: mmm de datasheet zegt iets over 8Mhz maar ook over 16MHz nou ja het lijkt te werken op 14.7
 -U lfuse:w:0b00111111:m
*/
