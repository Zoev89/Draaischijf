
MCU_TARGET     = atmega8
OPTIMIZE       = -Ofast

DEFS           =
LIBS           =

# Override is only needed by avr-lib build system.
# -S option is to see the amount of stack is used in the list file
override CFLAGS        = -g -Wall $(OPTIMIZE) -Wno-main -std=c99 -mmcu=$(MCU_TARGET) $(DEFS)
override LDFLAGS       = -Wl,-Map,$@.map

DraaiSchijfController.hex: main.c
	avr-gcc $(CFLAGS)  main.c -o DraaiSchijfController.elf
	avr-objdump -h -D -S DraaiSchijfController.elf > DraaiSchijfController.lst
	avr-objcopy -j .text -j textData -j .data -O ihex DraaiSchijfController.elf DraaiSchijfController.hex
	avr-objcopy -j .eeprom --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 -O ihex DraaiSchijfController.elf DraaiSchijfController_eeprom.hex

prog:
	avrdude -P usb -c avrispmkii -p m8 -U flash:w:DraaiSchijfController.hex:i -U eeprom:w:DraaiSchijfController_eepromSaved.hex:i  -U lfuse:w:0b00111111:m

progEeprom:
	avrdude -P usb -c avrispmkii -p m8 -U eeprom:w:DraaiSchijfController_eeprom.hex:i

saveEeprom:
	avrdude -P usb -c avrispmkii -p m8 -U eeprom:r:DraaiSchijfController_eepromSaved.hex:i

	
