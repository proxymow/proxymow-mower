/*
    Proxymow Mower - Cutter Wire Stack
    Stackable Washers to hold 2mm Strimmer Line
    Assemble stack for your preferred:
        * cut height
        * cut diameter
        * axial arrangement
        * mulch stagger. etc.
    Print in PETG
    Screw to flange and attach to cutter motor
*/
use <../shared/Drive-Motor-Metric-Hole-Module.scad>
disc_dia = 30;//mm
disc_thickness = 5;//mm
flange_hole_radius = 8;//mm
flange_hole_dia = 5.3;//mm
line_dia = 2.0; //mm
trap_factor = 1.2;//1.0 = no trap, 2.0 = half line diameter
orifice_radius = 2.0;
orifice_gradient = 10;

module orifice(q, dia) {
    rotate_extrude(angle=360, convexity=10) 
        mirror([1, 1, 0]) rotate([0, 0, 0]) difference() {
            square([q, q]);
            translate([dia/2, q + dia/2]) circle(q, $fn=100);
        }
}
module disc(local_dia) {
    cylinder(h=disc_thickness, d=local_dia, $fn=32, center=true);
}
module washer(local_dia, orifice_gradient) {
    difference() {
        disc(local_dia);
        for (a =[45:90:360]) {
            rotate([0,180,a]) translate([flange_hole_radius, 0, disc_thickness/2]) metric_hole(disc_thickness, "M3", csk=true);
        }
        //line channel
        translate([0, 0, trap_factor * (disc_thickness - line_dia)/2]) rotate([90, 0, 0]) cylinder(h=disc_dia+10, d=line_dia, $fn=32, center=true);
        //countersink orifice
        translate([0, disc_dia/3, trap_factor * (disc_thickness - line_dia)/2]) rotate([90, 0, 0]) orifice(orifice_gradient, line_dia);
        //countersink orifice
        rotate([0, 0, 180]) translate([0, disc_dia/3, trap_factor * (disc_thickness - line_dia)/2]) rotate([90, 0, 0]) orifice(orifice_gradient, line_dia);
        //lower countersink orifice A
        rotate([0,0,0]) translate([0, disc_dia/3, -(disc_thickness + line_dia)/2]) rotate([90, 0, 0]) orifice(orifice_gradient, line_dia);
        //lower countersink orifice B
        rotate([0,0,90]) translate([0, disc_dia/3, -(disc_thickness + line_dia)/2]) rotate([90, 0, 0]) orifice(orifice_gradient, line_dia);
        //lower countersink orifice C
        rotate([0,0,180]) translate([0, disc_dia/3, -(disc_thickness + line_dia)/2]) rotate([90, 0, 0]) orifice(orifice_gradient, line_dia);
        //lower countersink orifice D
        rotate([0,0,270]) translate([0, disc_dia/3, -(disc_thickness + line_dia)/2]) rotate([90, 0, 0]) orifice(orifice_gradient, line_dia);
        //access
        translate([0, 0, disc_thickness/2]) rotate([90, 0, 0]) cylinder(h=disc_dia+10, d=line_dia, $fn=32, center=true);
    }
}
module stack() {
    translate([0, 0, 0]) rotate([0, 0, 0]) washer(disc_dia, orifice_gradient);    
    translate([0, 0, disc_thickness]) rotate([0, 0, 90]) washer(disc_dia, orifice_gradient);    
    translate([0, 0, disc_thickness*2]) rotate([0, 0, 180]) washer(disc_dia, orifice_gradient);    
    translate([0, 0, disc_thickness*3]) rotate([0, 0, 270]) washer(disc_dia, orifice_gradient);    
}

for (b = [0:32:127]) translate([0, -b, 0]) washer(disc_dia, orifice_gradient);