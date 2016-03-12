//////////////////////////////////////////////////////////////////////////////////////////////
// Public Domain Gears for train turntable
// version 1.0
// by Eric Kathmann, 2016, eric.trein@gmail.com
//
// This file is public domain.  Use it for any purpose, including commercial
// applications.  Attribution would be nice, but is not required.  There is
// no warranty of any kind, including its correctness, usefulness, or safety.

use <gear.scad>


module ring(dia)
{
    difference()
    {
    cylinder(d=dia+0.1, h=0.3);
    translate([0,0,-0.2])cylinder(d=dia-0.4, h=0.5);
    }
}

module groteWiel(hoogteBus, tanden=false)
{
	translate([0,0,-2.5])
    difference()
	{
		union()
		{
			// met een 8 en een 160 tandswiel ben je in 20 slagen rond
			// met 9 153 in 17 slagen rond
			// bearing 608zz 8mm binnen 22mm buiten 7m hoog
			difference()
			{
				union()
				{
					if (tanden)
					{
						gear(mm_per_tooth=4,number_of_teeth=160,twist=0,thickness=5,hole_diameter=22, twist=0/160);
						//translate([0,0,3]) mirror([0,0,1]) gear(mm_per_tooth=4,number_of_teeth=160,twist=0,thickness=3,hole_diameter=22,twist=10);
					}
					else
					{$fn=360;
					    translate([0,0,0-2.5]) cylinder(r=outer_radius(mm_per_tooth=4,number_of_teeth=160,clearance=0),h=5);
					}
				}
				translate([0,0,-5])cylinder(d=190,h=15,$fn=360);
			}

			translate([0,0,-1])
			{
				cube([191,15,3],center=true);
				rotate([0,0,45])   cube([191,15,3],center=true);
				rotate([0,0,90])   cube([191,15,3],center=true);
				rotate([0,0,135])   cube([191,15,3],center=true);
			}
			// add een rand voor de aandrijving
			difference()
            {
                $fn=360;
                cylinder(d=25,h=hoogteBus+2.5);
                // baksteen patroon
                for(i=[2:2:hoogteBus+2.5])
                {
                    translate([0,0,i-0.1]) ring(25);
                    for (r=[0:20:360])
                    {
                        rotate([0,0,r+i*4])translate([24.6/2,0,i-2-0.05]) cube([0.3,0.3,2]);
                    }
                }

                // gat voor bevestiging iets geroteerd zodat je er makkelijker bij kan
                rotate([0,0,22.5])translate([0,0,2.5+6]) rotate([0,90,0]) cylinder(d=3,h=25,center=true,$fn=90);
            }
		}
        
	    translate([0,0,-5]) cylinder(d=22.05,h=hoogteBus+10,$fn=360);
	}
 }

module kleineWiel(tanden=false)
{
    translate([0,0,-2.5]) if (tanden)
    {
        gear(mm_per_tooth=4,number_of_teeth=8,twist=0,thickness=5,hole_diameter=5,twist=-0/8);
    }
    else
    {
	    translate([0,0,0-2.5]) cylinder(r=outer_radius(mm_per_tooth=4,number_of_teeth=8,clearance=0),h=5);
    }
    // cylinder boven op tandwiel voor klem
    $fn=180;
    difference()
    {
        translate([0,0,0]) cylinder(d=6,h=8);
        translate([0,0,-1]) cylinder(d=5,h=10);
        translate([-0.25,0,-1]) cube([0.5,20,10]);
    }
}

module kleineWielKlem()
{
    $fn=180;
    difference()
    {
        union()
        {
            scale([1,2,1])translate([0,0,0])cylinder(d=8,h=7);
        }
        // schroefgat
        translate([-5,5.5,3.5])rotate([0,90,0])cylinder(d=3,h=10);
        // gat voor de as
        translate([0,0,-1]) cylinder(d=6,h=12);
        // sleuf
        translate([-0.25,0,-1]) cube([0.5,20,12]);
        // klop schroef bijde zijden
        translate([2.5,5.5,3.5]) rotate([0,90,0]) cylinder(d=6,h=2);
        translate([-2.5-2,5.5,3.5]) rotate([0,90,0]) cylinder(d=6,h=2);
    }
}

 // probeer met iets schuins
 // twist van 10 ipv 15 want bij 15 krijg ik teveel retractions
 // blau pla 210 50mm/s 0.8 wall 
 //gear(mm_per_tooth=4,number_of_teeth=8, thickness=3,hole_diameter=5,twist=10);
 //translate([0,0,3]) mirror([0,0,1])gear(mm_per_tooth=4,number_of_teeth=8,thickness=3, hole_diameter=5, twist=10);

groteWiel(20);
//kleineWiel();
