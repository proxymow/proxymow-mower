/*
    Proxymow Mower - Robot Assembly
    Don't Print - just for illustration

*/
use <../omniwheel-bracket/Omniwheel-Bracket.scad>
use <../omniwheel/assembly.scad>
use <../wheel/FlangeWheel12.scad>
use <../wheel-bearing-mount/BearingHousing.scad>
use <purchased-parts.scad>
use <misc-parts.scad>
use <../drive-motor-bracket/Drive-Motor-Bracket.scad>
use <../cutter-motor-bracket/Cutter-Motor-Bracket.scad>
use <../cutter-wire-stack/Cutter-Wire-Stack.scad>
use <../target/Target-230.scad>
use <../battery-mount/Battery-Foot.scad>
use <../handle/Tubular-Handle.scad>
use <../hinge/Hinge.scad>

module half_drive() {
    translate([150, 0, 0]) union() {
        translate([0, 85, -10]) union() { 
            oob_assembly("rh-assembly");
            rotate([-33.75,0,0]) translate([0, 66.5, 0]) ow_assembly();
        }
        translate([0, -85, -10]) union() { 
            oob_assembly("lh-assembly");
            rotate([33.75,0,0]) translate([0, -66.5, 0]) ow_assembly();
        }
        translate([0, 0, -26]) union() {
            translate([5, 0, 0]) rotate([0,-90,0]) wheel_assembly();
            color("silver") translate([-5, 0, 0]) rotate([0, -90, 0]) wheel_flange();
        }

        color("orange") translate([-26, 0, 0]) rotate([0, 180, 0]) housing();
    }
    color("blue") translate([74, 0, 0]) rotate([0, 180, 0]) motor_bracket();
    color("gray") translate([10, 0, -18.5]) rotate([0, 90, 0]) drive_motor();
    color("silver") translate([123, 0, -26.0]) drive_shaft();
}
module cutter() {
    color("silver") translate([0, 0, 20]) rotate([0, 0, 45]) cutter_flange();
    color("orange") translate([0, 0, 2.5]) stack();
    color("red") translate([0, 0, 4]) rotate([0, 90, 100]) cylinder(h=160, d=2, center=true);
    color("red") translate([0, 0, 9]) rotate([0, 90, 10]) cylinder(h=200, d=2, center=true);
}
half_drive();
mirror([1, 0, 0]) half_drive();
//lawn
%color("#00FF0020") translate([0, 0, -95]) cube([400, 600, 10], center=true);

//baseplate
%color("#A52A2A20") translate([0, 0, 0]) baseplate_north();
%color("#A52A2A20") translate([0, -3, 0]) baseplate_south();

//hinge
color("silver") translate([0, -53.33, 9]) hinge();

//batteries
translate([8, 50, 0]) union() {
    color("black") translate([100, -44, 10.2]) rotate([0, 0, 90]) battery_7ah();
    //battery feet
    translate([67, -21.5, 9]) color("blue") foot();
    translate([67, 83.5, 9]) color("blue") rotate([0, 0, 180]) foot();
}
translate([-8, 50, 0]) union() {
    color("black") translate([-34.5, -44, 10.2]) rotate([0, 0, 90]) battery_7ah();
    translate([-67, -21.5, 9]) color("blue") foot();
    translate([-67, 83.5, 9]) color("blue") rotate([0, 0, 180]) foot();
}

//cutter north
*color("green") translate([0, 135, 9]) rotate([0, 0, 90]) cm_bracket();
*color("gray") translate([0, 135, 13]) cutter_motor();
translate([0, 135, -32]) cutter();
//cutter south
color("green") translate([0, -135, 9]) rotate([0, 0, 90]) cm_bracket();
color("gray") translate([0, -135, 13]) cutter_motor();
translate([0, -135, -32]) cutter();

//roof
%translate([0, 0, 114]) roof();
*color("white") translate([0, 0, 118]) rotate([0, 0, 180]) shuttle();
//pillars
translate([90, 180, 4]) cylinder(h=107, d=25, $fn=32);
translate([-90, 180, 4]) cylinder(h=107, d=25, $fn=32);
translate([0, -24, 54]) cylinder(h=57, d=25, $fn=32);

//handle
translate([0, 25, 29]) rotate([270, 180, 90]) handle();
