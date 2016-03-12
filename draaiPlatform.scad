//////////////////////////////////////////////////////////////////////////////////////////////
// Public Domain Train turntable
// version 1.0
// by Eric Kathmann, 2016, eric.trein@gmail.com
//
// This file is public domain.  Use it for any purpose, including commercial
// applications.  Attribution would be nice, but is not required.  There is
// no warranty of any kind, including its correctness, usefulness, or safety.

// I made a collection of modules for a train turntable. At the bottom of the file you can comment 
// uncomment the required module for stl generation. Please note some of these modules are to big
// to print. You have to enable them in deelopIn4 module so to split them in 4 (done by a thin hairline
// Now in Cura you can load the stl and split the modue into parts that are printable.
// Note you have to allign the generated stl yourself in Cura for correct printing or split them.

// For printing the gears you have to put tanden to true or call the module with a true value
// since rendering the teath take a lot of time.

use <tandwielen.scad>
tanden=false;
cirkel=310;
brugLengte= cirkel-2;
brugHalf=brugLengte/2;

brugHoogte = 15;
ruimteOnderBrug = 1;
dikteBodem = 2;
ruimteTussenTandwiel = 10;
brugBreedte = 18;
plankOffset = 10;
plankBreedte = 18;

draaiGat = 27; // het gat in de bodem van de schijf
dikteTandwiel=5;

diepteOnderPlaat=brugHoogte+ruimteOnderBrug+dikteBodem+ruimteTussenTandwiel+dikteTandwiel+2;


//tussen de rails 16.5
// bielzen 30
// rail is boven 1.1 dik dus hardafstand = 16.5 + 1.1 =17.6
// totale hoogte rails is 1.8 biels +_2.7 staaf = 4.5
railHoogte=4.5;
bielsAfstand = 7.56;
bielsHoogte = 1.8;
railKlem=1;
module rails(aantal,rails=true)
{
    railHard = 17.6;
    bielsLengte = 30;
    bielsVolgende = bielsAfstand + 0.01;
    for (a =[0:aantal-1])
    {
        translate([a*bielsAfstand,0,0])
        {
            color("dimgray")
            {
                translate ([3.5/2,0,1.8/2]) cube([3.5,bielsLengte,bielsHoogte],center=true);
                translate ([3.5,railHard/2-2.6/2,0])cube([bielsVolgende-3.5,2.6,bielsHoogte]);
                translate ([3.5,-(railHard/2+2.6/2),0])cube([bielsVolgende-3.5,2.6,bielsHoogte]);
                // rails blokjes
                translate ([0.25,railHard/2-2.2/2-1.4,bielsHoogte])cube([3,1.4,railKlem]);
                translate ([0.25,-(railHard/2-2.2/2),bielsHoogte])cube([3,1.4,railKlem]);
                translate ([0.25,railHard/2+2.2/2,bielsHoogte])cube([3,1.4,railKlem]);
                translate ([0.25,-(railHard/2+2.2/2+1.4),bielsHoogte])cube([3,1.4,railKlem]);
            }
            
            color("silver") if (rails)
            {
                translate([bielsVolgende/2,17.6/2,bielsHoogte+0.25]) cube([bielsVolgende,2.2,0.5],center=true);
                translate([bielsVolgende/2,-17.6/2,bielsHoogte+0.25]) cube([bielsVolgende,2.2,0.5],center=true);

                translate([bielsVolgende/2,17.6/2,bielsHoogte+0.5+0.7]) cube([bielsVolgende,0.7,1.4],center=true);
                translate([bielsVolgende/2,-17.6/2,bielsHoogte+0.5+0.7]) cube([bielsVolgende,0.7,1.4],center=true);

                translate([bielsVolgende/2,17.6/2,bielsHoogte+2.7-0.4]) cube([bielsVolgende,1.1,0.8],center=true);
                translate([bielsVolgende/2,-17.6/2,bielsHoogte+2.7-0.4]) cube([bielsVolgende,1.1,0.8],center=true);
            }
        }
    }
}

module verwijderSpoorStaaf(aantal)
{
    railHard = 17.6;
    bielsLengte = 30;
    bielsVolgende = bielsAfstand + 0.01;
    for (a =[0:aantal-1])
    {
        translate([a*bielsAfstand,0,0])
        {
            translate([bielsVolgende/2,17.6/2,1.8+0.6]) cube([bielsVolgende,2.21,1.21],center=true);
            translate([bielsVolgende/2,-17.6/2,1.8+0.6]) cube([bielsVolgende,2.21,1.21],center=true);
        }
    }
}
    
module railsAansluiting()
{
    difference()
    {
        union()
        {
            translate([cirkel/2+bielsAfstand*4,0,0]) rails(7,false);
            //translate([cirkel/2+bielsAfstand*(4+6),0,0]) rails(1,false);
            //translate([cirkel/2+bielsAfstand*(4+5),-15,0-0.3]) cube([15,30,0.3]);
        }
        // schuine kanten eraf
        rotate([0,0,3.75])translate([cirkel/2+bielsAfstand*4,-0.1,-1]) cube([50,10,5]);
        mirror([0,1,0])rotate([0,0,3.75])translate([cirkel/2+bielsAfstand*4,-0.1,-1]) cube([50,10,5]);
        // rails lassen
        translate([cirkel/2+bielsAfstand*9-0.1,17.5/2-2.5,1.3]) cube([20,5.1,2]);
        mirror([0,1,0])translate([cirkel/2+bielsAfstand*9-0.1,17.5/2-2.5,1.3]) cube([20,5.1,2]);
    }
}

module railsDeksel()
{
    difference()
    {
        union()
        {
            difference()
            {
                union()
                {
                    translate([cirkel/2,-20,bielsHoogte+railKlem]) cube([bielsAfstand*5,40,railHoogte-bielsHoogte-railKlem]);
                    translate([cirkel/2+bielsAfstand*4,-20,0]) cube([bielsAfstand,40,railHoogte]);
                    translate([cirkel/2+bielsAfstand*3.5,-7.25,0]) cube([bielsAfstand,14.5,railHoogte]);
                    translate([cirkel/2,-6.1,bielsHoogte]) cube([bielsAfstand*4,12.2,railHoogte-bielsHoogte]);
                    translate([cirkel/2+bielsAfstand/2+0.2,-5,0.1]) cube([bielsAfstand/2-0.4,10,bielsHoogte]);
                }
                // maak gleuven
                for(i=[2.7:4:bielsAfstand*5])
                {
                    translate([i+cirkel/2,-20,railHoogte-1]) cube([0.5,40,2]);
                }
            }
            // maak een rand plank
            rotate([0,0,3.75])translate([cirkel/2+1,-3,railHoogte-1.5]) cube([bielsAfstand*5-2,4,1.5]);
            mirror([0,1,0]) rotate([0,0,3.75])translate([cirkel/2+1,-3,railHoogte-1.5]) cube([bielsAfstand*5-2,4,1.5]);
            
        }
        rotate([0,0,3.75])translate([cirkel/2-0.1,-0.1,-1]) cube([bielsAfstand*6,15,railHoogte+2]);
        mirror([0,1,0])rotate([0,0,3.75])translate([cirkel/2-0.1,-0.1,-1]) cube([bielsAfstand*6,15,railHoogte+2]);
    }
}

module railsBuiten()
{
    $fn=180;
    step=7.5;
    //railsDeksel();
    //railsAansluiting();
    for (i=[0:step:360-step])
    {
        difference()
        {   
            rotate([0,0,i]) translate([cirkel/2,0,0]) rails(4,false);
            rotate([0,0,i]) translate([cirkel/2,0,0]) verwijderSpoorStaaf(4);
        }
        if (i<180)
            rotate([0,0,i]) railsAansluiting();
        else
           color("saddlebrown") rotate([0,0,i]) railsDeksel();
    }
    difference()
    {
        // rotate om de afronding van de hoeken precies met de bielzen te laten samenvallen
        rotate([0,0,7.5/2]) translate([0,0,-3])cylinder(d=cirkel+80,h=3,$fn=48);
        translate([0,0,-1])cylinder(d1=cirkel+2,d2=cirkel,h=1.01);
        translate([0,0,-4])cylinder(d=cirkel+2,h=3.01);
    }
}


module brugHelft()
{
    for (i=[10:3.5:25])
    translate([0,i,-4.5])cube([brugHalf,3,9]);
}
//brugHelft();
module brugRails()
{
    difference()
    {
        translate([-brugLengte/2,0,0])rails(41,false);
        translate([0,0,0.2499])cube([320,60,0.5],center=true);
        cube([0.01,60,10],center=true);
    }
}


module lager()
{
    difference(){
        cylinder(d=8,h=4,center=true,$fn=180);
        cylinder(d=3,h=6,center=true,$fn=180);
    }
}

module lagerHouder()
{
    translate([0,0,2-1])cylinder(d=2.9,h=1.1,$fn=180);
    translate([0,0,2]) cylinder(d=4,h=0.5,$fn=180);
    translate([5.5,-0.5,0])cube([1,brugHoogte/2+0.5,2.5]);
    hull()
    {
        translate([5.5,-0.5,2.5])cube([1,brugHoogte/2+0.5,1]);
        translate([0,0,2.5]) cylinder(d=4,h=1,$fn=180);
    }
}
module lagerGeheel()
{
    translate([0,0,-0.001])mirror([0,0,1]) lagerHouder();
    lager();
    lagerHouder();
}


module groteLigger()
{
    color("gray")
    {
        translate([0,brugBreedte, -brugHoogte]) cube([brugHalf/4,2,brugHoogte]);
        translate([brugHalf*3/4,brugBreedte, -brugHoogte/2]) cube([brugHalf/4,2,brugHoogte/2]);
        translate([0,brugBreedte,-1]) cube([brugHalf,4,1]);
        translate([0,brugBreedte,-brugHoogte]) cube([brugHalf/4,4,1]);
        translate([brugHalf*3/4,brugBreedte,-brugHoogte/2]) cube([brugHalf/4,4,1]);
        // schuine zijde
        hull()
        {
            translate([brugHalf/4,brugBreedte,-brugHoogte]) cube([1,2,brugHoogte]);
            translate([brugHalf*3/4,brugBreedte,-brugHoogte/2]) cube([1,2,brugHoogte/2]);
        }
        // onderklant schuin
        hull()
        {
            translate([brugHalf/4,brugBreedte,-brugHoogte]) cube([1,4,1]);
            translate([brugHalf*3/4,brugBreedte,-brugHoogte/2]) cube([1,4,1]);
        }
        // dwarsbalkjes
        for (i=[8:brugHalf/10:brugHalf])
        {
            if (i<brugHalf/4) translate([i,brugBreedte,-brugHoogte])cube([1,3.5,brugHoogte]);
            else if (i>brugHalf*3/4) translate([i,brugBreedte,-brugHoogte/2])cube([1,3.5,brugHoogte/2]);
            else 
            {
                offset = brugHoogte/2*(i-brugHalf/4)/(brugHalf/2);
                translate([i,brugBreedte,-brugHoogte + offset ])cube([1,3.5,brugHoogte-offset]);
            }
            // steunen op de dwarsbalken
            translate([i-0.5,brugBreedte,-2]) cube([2,plankOffset+plankBreedte-brugBreedte,2]);
            // vleugeltjes aan de bovenkant
            hull()
            {
                translate([i-0.5,plankOffset+plankBreedte-1,-0.4]) cube([2,1,0.4]);
                translate([i-0.5-7,brugBreedte,-0.4]) cube([1,1,0.4]);
                translate([i-0.5+7,brugBreedte,-0.4]) cube([2,1,0.4]);
            }
            // dwars onderkantjes
            hull()
            {
                translate([i+0.3,brugBreedte+7,-1]) cube([0.4,1,1]);
                translate([i+0.3,brugBreedte+1,-1]) cube([0.4,1,1]);
                translate([i+0.3,brugBreedte+1,-1-6]) cube([0.4,1,1]);
            }
        }
    }
}

module railing()
{
    
    color("dimgray")for (i=[8:brugHalf/10:brugHalf])
    {
        translate([i,plankOffset+plankBreedte,-2]) cube([1,1,15+2+railHoogte]);
    }
    color("red")translate([0,plankOffset+plankBreedte,15+railHoogte-2]) cube([9*brugHalf/10+8+1,1,2]);
    color("dimgray") translate([0,plankOffset+plankBreedte,15+railHoogte-2-6]) cube([9*brugHalf/10+8,1,2]);
}

module railingHuis()
{
    offset = 8;
    offsetTotHoek = 7.5;
    hoekPunt = offset+6*brugHalf/10+offsetTotHoek;
    // eerst de verkorte tailing
    color("dimgray")for (i=[offset:brugHalf/10:brugHalf-3*brugHalf/10])
    {
        translate([i,plankOffset+plankBreedte,-2]) cube([1,1,15+2+railHoogte]);
    }
    // laatste paal
    color("dimgray") translate([hoekPunt,plankOffset+plankBreedte,0]) cube([1,1,15+railHoogte]);
    color("red")translate([0,plankOffset+plankBreedte,15+railHoogte-2]) cube([6*brugHalf/10+offset+1+offsetTotHoek,1,2]);
    color("dimgray") translate([0,plankOffset+plankBreedte,15+railHoogte-2-6]) cube([6*brugHalf/10+offset+offsetTotHoek,1,2]);
    // nu het stuk langs het huis
    color("dimgray")for (i=[offset+7*brugHalf/10:brugHalf/10:brugHalf])
    {
        translate([i,plankOffset+2*plankBreedte,-2]) cube([1,1,15+2+railHoogte]);
    }
    color("dimgray")translate([offset-1+9*brugHalf/10,plankOffset+2*plankBreedte,-2]) cube([1,1,15+2+railHoogte]);
    
    color("dimgray")translate([hoekPunt,plankOffset+2*plankBreedte,]) cube([1,1,15+railHoogte]);
    color("red")translate([hoekPunt,plankOffset+2*plankBreedte,15+railHoogte-2]) cube([2*brugHalf/10+offsetTotHoek,1,2]);
    color("dimgray")translate([hoekPunt,plankOffset+2*plankBreedte,15+railHoogte-2-6]) cube([2*brugHalf/10+offsetTotHoek,1,2]);

    // stukje naast de trap
    color("dimgray") translate([hoekPunt,plankOffset+2*plankBreedte-1.1,0]) cube([1,1,15+railHoogte]);
    color("dimgray") translate([hoekPunt,plankOffset+plankBreedte+12,0]) cube([1,1,15+railHoogte]);
    // railing naast de trap
    color("red") translate([hoekPunt,plankOffset+plankBreedte+12,15+railHoogte-2]) cube([1,plankBreedte-12.1,2]);
    color("dimgray") translate([hoekPunt,plankOffset+plankBreedte+12,15+railHoogte-2-6]) cube([1,plankBreedte-12.1,2]);

    // balken onder het huis
    color("dimgray")for (i=[offset-0.5+7*brugHalf/10:brugHalf/10:brugHalf])
    {
        translate([i,plankOffset+plankBreedte,-2]) cube([2,plankBreedte-0.01,2]);
    }
    
}

module volleLigger()
{
    groteLigger();
    mirror([1,0,0])groteLigger();
}
module binnenKant()
{
    lengte=(brugHalf-12.5)/5;
    hoogte=brugHoogte/3;
    color("gray")for (i=[0:lengte:brugHalf-lengte/2])
    {
        // blaken onder de rails
        translate([i,7,-1])cube([lengte,4,1]);
        translate([i,-7-4,-1])cube([lengte,4,1]);
        translate([i,7+1.25,-hoogte*0.8])cube([lengte,1.5,hoogte*0.8]);
        translate([i,-7-4+1.25,-hoogte*0.8])cube([lengte,1.5,hoogte*0.8]);
        // randje langs de grote balk
        translate([i,brugBreedte-2,-1])cube([lengte,2,1]);
        translate([i,-brugBreedte,-1])cube([lengte,2,1]);
        // dwars balken
        translate([i, -brugBreedte,-hoogte])cube([1,2*brugBreedte,hoogte]);
        translate([i+lengte-1, -brugBreedte,-hoogte])cube([1,2*brugBreedte,hoogte]);
        // de kruisen
        hull()
        {
            translate([i+lengte-1,-brugBreedte,-2]) cube([1,1,2]);
            translate([i,brugBreedte-1,-2])cube([1,1,2]);
        }
        hull()
        {
            translate([i+lengte-1,brugBreedte-1,-2]) cube([1,1,2]);
            translate([i,-brugBreedte,-2])cube([1,1,2]);
        }
    }
    color("gray")
    {
        $fn=180;
        diepteTotBodemLager = brugHoogte+ruimteOnderBrug+dikteBodem+ruimteTussenTandwiel + 5 -7;
        translate([brugHalf-(12.5-7),-brugBreedte,-hoogte]) cube([12.5-7, 2*brugBreedte,hoogte]);
        difference()
        {
            union()
            {
                // cylinder in het midden
                translate([0,0,-diepteTotBodemLager+1]) cylinder(d=22,h=diepteTotBodemLager-1);
                translate([0,0,-5]) cylinder(d=25,h=5);
            }
            // horizontaal gat voor de draaden
            translate([0,0,-diepteTotBodemLager]) cylinder(d=7,h=diepteTotBodemLager-2);
            // kleine gaatjes onder de rails
            translate([0,0,-5]) rotate([0,80,-30])cylinder(d=3,h=15);
            translate([0,0,-5]) rotate([0,80,30])cylinder(d=3,h=15);
            translate([-100,-50,-35]) cube([100,100,40]);
            translate([0,0,-(brugHoogte+ruimteOnderBrug+dikteBodem+4)])rotate([0,90,0]) cylinder(d=3,h=25,center=true,$fn=90);
        }
    }
}


module bodemPlanken(huis=false)
{
    color("saddlebrown")
    {
        start = 0.1+3.4*32;
        for (i=[0.1:3.4:brugHalf])
        {
            plankLengte = ((huis)&&(i>start)) ? 2*plankBreedte :plankBreedte;
            
            translate([i,plankOffset,2.8-0.5]) cube([3,plankLengte,railHoogte-2.8]);
        }
        for (i=[0:1:2])
        {
            ruimte = ((plankBreedte+plankOffset-15) - (3*3))/2;
            translate([0,i*(ruimte+3)+15,0]) cube([brugHalf,3,2.8-0.5]);
        }
        if (huis)
        {
            for (i=[0:1:2])
            {
                ruimte = ((plankBreedte) - (3*3))/3;
                translate([0.1+3.4*32,i*(ruimte+3)+plankBreedte+plankOffset+ruimte,0]) cube([brugHalf-start,3,2.8-0.5]);
            }
        }
    }
}

module raamKozijn(grote)
{
    translate([-0.5,-0.5,0])cube([grote+1,grote+1,0.2]);
}
module raamGlas(grote)
{
    translate([0,0,-4])cube([grote,grote,5]);
}
module huisZijkant(breedte,diepte,hoogte,deurHoogte)
{
    raam = 5;
    difference()
    {
        union()
        {
            difference()
            {
                hull()
                {
                    translate([0,-hoogte,-0.01]) cube([diepte,hoogte,0.01]);
                    translate([1,-hoogte+1,-1]) cube([diepte-2,hoogte-1,0.1]);
                }
                // planken (sleuven)
                for (i=[1:1:diepte])
                    translate([i,-hoogte-0.1,-0.2+0.01]) cube([0.3,hoogte+0.2,0.2]);
            }
            translate([diepte/3-raam/2,-3.5*raam,0])raamKozijn(raam);
            translate([2*diepte/3-raam/2,-3.5*raam,0])raamKozijn(raam);
        }
        translate([diepte/3-raam/2,-3.5*raam,0])raamGlas(raam);
        translate([2*diepte/3-raam/2,-3.5*raam,0])raamGlas(raam);
    }
}
module huisVoorAchter(breedte,diepte,hoogte)
{
    difference()
    {
        hull()
        {
            translate([0,0,-0.01]) cube([hoogte,breedte,0.01]);
            translate([0,1,-1]) cube([hoogte-1,breedte-2,0.1]);
        }
        // planken (sleuven)
        for (i=[1:1:breedte])
            translate([-0.1,i,-0.2+0.01]) cube([hoogte+0.2,0.3,0.2]);
    }
}

module huisVoorKant(breedte,diepte,hoogte,deurHoogte)
{
    difference()
    {
        union()
        {
            huisVoorAchter(breedte,diepte,hoogte);
            // deur kozijn
            translate([deurHoogte/2,breedte/2,0])cube([deurHoogte,9,0.5],center =true);
            translate([deurHoogte+0.5,breedte/2,0])cube([1,10,0.7],center =true);
            
        }
        // gat van de deur
        translate([deurHoogte/2-0.01,breedte/2,0])cube([deurHoogte,8,20],center =true);
    }
}

module huisAchterKant(breedte,diepte,hoogte)
{
    raam = 5;
    difference()
    {
    
        union()
        {
            huisVoorAchter(breedte,diepte,hoogte);
            translate([2.5*raam,breedte/2-raam/2,-0.01])raamKozijn(raam);
        }
        translate([2.5*raam,breedte/2-raam/2,0])raamGlas(raam);
    }
}
module huisDakPlanken(breedte,overhang)
{
    difference()
    {
        cylinder(d=breedte,h=overhang+0.2);
        // planken worden in spiegelbeeld gemaakt want die zitten in een difference
        for(i=[0:1:breedte])
        {
             translate([i-breedte/2,-breedte,overhang]) cube([0.8,2*breedte,0.4]);
        }
    }
}
module huisDakRonding(breedte,diepte,overhang)
{
    $fn=16;
    difference()
    {
        union()
        {
            cylinder(d=breedte+5,h=diepte+overhang);
            for(i=[0:1:4])
            {
                translate([0,0,i*(diepte+overhang-1)/4]) cylinder(d=breedte+5+0.4,h=1);
            }
        }
        translate([0-breedte/4,-breedte,-0.1])cube([breedte,2*breedte,2*diepte]);
        translate([0,0,-overhang/2]) huisDakPlanken(breedte+3,overhang);
        translate([0,0,3*overhang/2 + diepte]) mirror([0,0,1]) huisDakPlanken(breedte+3,overhang);
    }
    //huisDakPlanken(breedte+3,overhang);
}

module huisDak(breedte,diepte)
{
    overhang =1;
        hull()
        {
            translate([0,0,-0.01]) cube([diepte,breedte,0.01]);
            translate([1,1,-1]) cube([diepte-2,breedte-2,0.1]);
        }
        translate ([-overhang/2,breedte/2,-breedte/4])rotate([0,90,0]) huisDakRonding(breedte,diepte,overhang);
        translate([-overhang/2,-2,-1])cube([diepte+overhang,1.5,1]);
        translate([-overhang/2,breedte+0.5,-1])cube([diepte+overhang,1.5,1]);
}
module huis()
{
    // 23mm is ongeveer 2m
    deurHoogte = 23;
    breedte = plankBreedte-2;
    hoogte = 26;
    diepte = 28;
    los = false;
    if (los)
    {
        // alle onderdelen los voor printen
        translate([0,0,1])huisDak(breedte,diepte);
        translate([0,20,1])huisVoorKant(breedte,diepte,hoogte,deurHoogte);
        translate([0,-20,1])huisAchterKant(breedte,diepte,hoogte,deurHoogte);
        translate([-30,0,1])huisZijkant(breedte,diepte,hoogte,deurHoogte);
        translate([-30,30,1])huisZijkant(breedte,diepte,hoogte,deurHoogte);
        translate([30,0,0]) cube([deurHoogte,8,0.5]); // deur
    }
    else
    {
        translate([0,0,hoogte])huisDak(breedte,diepte);
        rotate([0,-90,0]) huisVoorKant(breedte,diepte,hoogte,deurHoogte);
        translate([0,breedte,0])rotate([-90,0,0])huisZijkant(breedte,diepte,hoogte,deurHoogte);
        mirror([0,1,0])rotate([-90,0,0])huisZijkant(breedte,diepte,hoogte,deurHoogte);
        translate([diepte,0,0])mirror([1,0,0])rotate([0,-90,0])huisAchterKant(breedte,diepte,hoogte);
    }
}

module huisGeplaatst()
{
    color("saddlebrown") translate([brugHalf-36,plankOffset+plankBreedte,railHoogte]) huis();
}


module volleBodemPlanken()
{
    bodemPlanken();
    translate([-0.01,0,0]) mirror([1,0,0]) bodemPlanken();
}

module volleRailing()
{
    railing();
    mirror([1,0,0]) railing();
}

module beideLagers()
{
    translate([145,11.5,-7])rotate([0,0,180]) rotate([0,-90,0]) rotate([0,0,-90]) mirror([0,0,1])lagerGeheel();
    translate([145,-11.5,-7]) rotate([0,-90,0]) rotate([0,0,-90]) lagerGeheel();
}

module onderkant()
{
    $fn=360;
    bodem = brugHoogte+ruimteOnderBrug+dikteBodem;
    difference()
    {
        union()
        {
            translate([0,0,-bodem]) cylinder(d=cirkel+4,h=bodem-3);
            translate([0,0,-3]) cylinder(d=cirkel+2,h=2);
        }
        union()
        {
            translate([0,0,-13]) cylinder(d=cirkel,h=20);
            translate([0,0,-(brugHoogte+ruimteOnderBrug)]) cylinder(d1=cirkel/3,d2=cirkel-35,h=brugHoogte+ruimteOnderBrug-13+0.1);
            translate([0,0,-30]) cylinder(d=draaiGat,h=60);
            for(i=[0:90:270])
            { 
            rotate([0,0,i]) translate([-95,-95,-bodem-1]) cylinder(d=2,h=dikteBodem+3);
                // geintegreede schroef
            //rotate([0,0,i]) translate([-95,-95,-bodem+1]) cylinder(d=5.7,h=2.5,$fn=6);
            }

        }
    }
    // Ring voor de brug rails
    translate([0,0,-12])difference()
    {
        cylinder(r=146,h=2,center=true,$fn=180);
        cylinder(r=146-1,h=4, center=true,$fn=180);
    }
    for(r=[0:3:360-3])
    {
        rotate([0,0,r])translate([146-0.5,0,-12-0.25])cube([3,3,1.5],center=true);
    }
}

module tandwielen()
{
    offset = brugHoogte+ruimteOnderBrug+dikteBodem+ruimteTussenTandwiel;
    // rotate zodat het gat alligned
    rotate([0,0,-22.5])translate([0,0,-offset])groteWiel(offset-5,tanden);
    // plaats het lager
    translate([0,0,-offset-5]) difference()
    {
        cylinder(d=22,h=7);
        translate([0,0,0-1])cylinder(d=8,h=9);
    }
    translate([107,0,-offset]) rotate([0,0,22]) kleineWiel(tanden);
    translate([107,0,-offset]) rotate([0,0,22]) kleineWielKlem();
}

module ring()
{
    difference()
    {
    cylinder(d=25.1, h=0.3);
    translate([0,0,-0.2])cylinder(d=24.6, h=0.5);
    }
}

module bakstenen()
{
    difference()
    {
        $fn=180;
        cylinder(d=25,h=20);
        for(i=[2:2:20])
        {
            translate([0,0,i-0.1]) ring();
            for (r=[0:20:360])
            {
                rotate([0,0,r+i*4])translate([24.6/2,0,i-2-0.05]) cube([0.3,0.3,2]);
            }
        }
    }
}
//bakstenen();
module driehoek(h)
{
    hull()
    {
        translate([7,15,h-11]) cube([1,1,12]);
        translate([7,85,h-11]) cube([1,1,12]);
        translate([75,85,h-11]) cube([1,1,12]);
    }
}

module onderplaat()
{
    $fn=180;
    h=-diepteOnderPlaat;
    ruimteTotBodem = -(h + (brugHoogte+ruimteOnderBrug+dikteBodem));
    difference()
    {
        union()
        {
            translate([0,0,h]) cylinder(d=12,h=2);
            translate([0,0,h]) cylinder(d=8,h=2+7);
            translate([0,0,h-3])cube([200,200,6],center=true);
            for(i=[0:90:270])
                rotate([0,0,i]) translate([-100,-100,h]) cube([10,10,ruimteTotBodem]);
            // cyclinder voor aanbrengen veer
            translate([75,-85,h]) cylinder(d=14,h=4);
        }
        // gat in het midden
        translate([0,0,h-11]) cylinder(d=5,h=40);
        // schroefgaten in de steunen
        for(i=[0:90:270])
        {
            rotate([0,0,i]) translate([-95,-95,h-11]) cylinder(d=4,h=40);
            rotate([0,0,i]) translate([-95,-95,h-11]) cylinder(d=6,h=ruimteTotBodem/2+11);
        }
        // motor uitsnijding
        hull()
        {
            translate([80,-25,h-11]) cube([30,50,12]);
            translate([90,-45,h-11]) cube([20,1,12]);
            translate([90,45,h-11]) cube([20,1,12]);
        }
        // gat voor motor ophanging
        translate([90,80,h-11]) cylinder(d=2.5,h=12);
        // gat voor veer
        translate([75,-85,h-0.1]) cylinder(d=2,h=5);
        driehoek(h);
        mirror([1,0,0])driehoek(h);
        rotate([0,0,90]) { driehoek(h); mirror([1,0,0])driehoek(h);}
        rotate([0,0,180]) { driehoek(h); mirror([1,0,0])driehoek(h);}
        rotate([0,0,270]) scale([0.75,0.75,1]) { driehoek(h); mirror([1,0,0])driehoek(h);}

    }
}

module motor()
{
    translate([0,0,-47-4])
    difference()
    {
        union()
        {
            translate([-42/2,-42/2,0]) cube([42,42,47]);
            translate([0,0,47]) cylinder(d=22,h=2);
            translate([0,0,47]) cylinder(d=5,h=22+2);
        }
        for(i=[0:90:270])
            rotate([0,0,i]) translate([31/2,31/2,47-4])cylinder(d=2.8,h=5);
        for(i=[0:90:270])
            rotate([0,0,i]) translate([17.5+5,17.5+5,47/2])rotate([0,0,45])cube([10,10,49],center=true);
    }
}
module motorPlaat()
{
    $fn=90;
    translate([0,0,-2])
    difference()
    {
        union()
        {
            hull()
            {
                cube([42,42,4],center=true);
                translate([0,34-8.5,0])cube([20,1,4],center=true);
                translate([0,-34+8.5,0])cube([20,1,4],center=true);
            }
        translate([0,34,0])cube([20,16,4],center=true);
        translate([0,-34,0])cube([20,16,4],center=true);
        }
        cylinder(d=23,h=5,center=true);
        for(i=[0:90:270])
            rotate([0,0,i]) translate([31/2,31/2,0])cylinder(d=3,h=5,center=true);
        // gaten voor de bevestigings schroeven van de motorBeugel
        translate ([20/4,34,0])cylinder(d=3,h=5,center=true);
        translate ([-20/4,34,0])cylinder(d=3,h=5,center=true);
        translate ([20/4,-34,0])cylinder(d=3,h=5,center=true);
        translate ([-20/4,-34,0])cylinder(d=3,h=5,center=true);
    }
}

module motorBeugel()
{
    $fn=90;
    // steun voor schanier punt
    difference()
    {
        hull()
        {
            translate([90,80,-diepteOnderPlaat]) cylinder(d=14,h=4);
            translate([107,35,-diepteOnderPlaat]) cylinder(d=14,h=4);
        }
        translate([90,80,-diepteOnderPlaat-1]) cylinder(d=3.2,h=6);
    }
    difference()
    {
        hull()
        {
            translate([107,34,-diepteOnderPlaat]) cylinder(d=14,h=4);
            translate([107,34,-diepteOnderPlaat-5]) cube([20,16,1], center=true);
        }
        //gaten voor de bevestigings schroeven
        translate([107-20/4,34,-diepteOnderPlaat-6]) cylinder(d=2,h=6);
        translate([107+20/4,34,-diepteOnderPlaat-6]) cylinder(d=2,h=6);
    }
    //steun voor de veer
    difference()
    {
        hull()
        {
            translate([107,-34,-diepteOnderPlaat]) cylinder(d=14,h=4);
            translate([107,-34,-diepteOnderPlaat-5]) cube([20,16,1], center=true);
        }
        //gaten voor de bevestigings schroeven
        translate([107-20/4,-34,-diepteOnderPlaat-6]) cylinder(d=2,h=6);
        translate([107+20/4,-34,-diepteOnderPlaat-6]) cylinder(d=2,h=6);
    }

    difference()
    {
        hull()
        {
            translate([90,-80,-diepteOnderPlaat]) cylinder(d=14,h=4);
            translate([107,-35,-diepteOnderPlaat]) cylinder(d=14,h=4);
        }
        translate([90,-80,-diepteOnderPlaat-1]) cylinder(d=2,h=6);
    }
    

}

module Baan()
{
    translate([1900,-1390,0])scale([5, 5, 0.1]) surface(file = "baan.png", center = true, convexity = 5,invert=true);
    translate([160,0,0])rails(70);
    rotate([0,0,7.5]) translate([160,0,0])rails(70);
    rotate([0,0,15]) translate([160,0,0])rails(70);
    rotate([0,0,15+7.5]) translate([160,0,0])rails(70);
    rotate([0,0,-40]) translate([160,0,0])rails(30);
    rotate([0,0,-7.5]) translate([160,0,0])rails(70);
}

module OnderkantAfstandBlok()
{
    $fn=20;
    difference()
    {
        cube([15,15,2],center=true);
        cylinder(d=4,h=5,center=true);
    }
}

module Schijfsteun()
{
    cube([10,30,2],center=true);
}
    

module BevestigingsRing()
{
    $fn=60;
    difference()
    {
        union()
        {
            cylinder(d=10,h=0.5);
            translate([0,0,0.5]) cylinder(d=8,h=0.1);
        }
        translate([0,0,-1]) cylinder(d=5,h=10);
    }
}
//BevestigingsRing();

module Trap()
{
    hoogte = 18;
    breedte = 10;
    color("saddlebrown")
    difference()
    {
        union()
        {
            hull()
            {
                cube([2,0.8,2]);
                translate([hoogte,0,hoogte]) cube([2,0.8,2]);
            }
            translate([0,breedte,0])hull()
            {
                cube([2,0.8,2]);
                translate([hoogte,0,hoogte]) cube([2,0.8,2]);
            }
            // treden
            for(t=[1-0.4:2:hoogte])
            {
                translate([t-0.4,0,t]) cube([2.5,breedte,0.4]);
            }
            // bevestiging
            translate([hoogte-1,0.81,hoogte-4.41])cube([2,breedte-0.8-0.02,3]);
        }
        // snij de bovenkant eraf mag niet uitsteken
        translate([0,-2,hoogte-1]) cube([2*hoogte,2*hoogte,5]);
    }
}
module deelopIn4()
{
    difference()
    {
    //railsBuiten();
    //onderkant();
        translate([0,-0.005,-40]) cube([360,0.01,80]);
        rotate([0,0,90])translate([0,-0.005,-40]) cube([360,0.01,80]);
        rotate([0,0,180])translate([0,-0.005,-40]) cube([360,0.01,80]);
        rotate([0,0,270])translate([0,-0.005,-40]) cube([360,0.01,80]);
    }
}
//deelopIn4();
//Baan();
//rails(5,false);
//verwijderSpoorStaaf(5);
//translate([107,0,-diepteOnderPlaat-5]) motor();
//translate([107,0,-diepteOnderPlaat-5]) motorPlaat();
module Pootjes()
{
    cube([10,10,55]);
}


for(i=[-90:90:90]) rotate([0,0,i]) translate([-100,0,-34]) Schijfsteun();
railsBuiten();
//lagerHouder();
onderplaat();
translate([0,0,-26])mirror([0,0,1])BevestigingsRing();
for(i=[0:90:270]) rotate([0,0,i])translate([95,95,-18]) OnderkantAfstandBlok();
motorBeugel();
translate([107,0,-40])motorPlaat();
translate([107,0,-40]) motor();
onderkant();
tandwielen();
//huis();
//Trap();
//Pootjes();
//railsDeksel();
//railsAansluiting();

module BinnenInCirkel()
{
intersection()
{
    translate([0,0,0.5]) union() // added 0.5 omdat de lagers 0.5 hoger zijn geworden
    {
        translate([90,plankBreedte+11,-13]) Trap();
        //groteLigger();
        bodemPlanken(true);
        binnenKant(); translate([0,0,-0.5])beideLagers();
        huisGeplaatst();
        mirror([1,0,0])railing();
        railingHuis();
        mirror([0,1,0]) volleRailing();
        mirror([1,0,0]) {binnenKant(); beideLagers();}
        volleLigger();
        mirror([0,1,0]) volleLigger();
        mirror([1,0,0])bodemPlanken();
        mirror([0,1,0]) volleBodemPlanken();
        translate([0,0,-0.5]) brugRails();
   }
   cylinder(d=brugLengte,h=100,center=true,$fn=180);
}
}
BinnenInCirkel();