/*
    Proxymow Mower - Cutter Motor Bracket
    For 775 Type 12V DC Motor
    Print in TPU to provide anti-vibration properties
*/
$fa=1;
$fs=0.4;
body_height = 10;//mm
body_dia = 56.5;//mm
cutout_height = 5;//mm
motor_body_dia = 45.5;//mm
motor_collar_dia = 18;//mm
motor_fixing_centres = 29;//mm
motor_fix_hole_dia = 4.5;//mm
fix_hole_dia = 4.5;//mm
foot_dia = 20;//mm
foot_height= 5;//mm
foot_extent = 30;//mm
fixing_centres = 66;//mm

module bracket_body() {
    //outer ring
    difference() {
        cylinder(h=body_height, d=body_dia);
        translate([0, 0, body_height/2]) cylinder(h=body_height, d=motor_body_dia);
    }
    //feet
    hull() {
        translate([foot_extent,0,0]) cylinder(h=foot_height, d=foot_dia);
        translate([-foot_extent,0,0]) cylinder(h=foot_height, d=foot_dia);
    }
}
module cm_bracket() {
    difference() {
        bracket_body();
        //central hole
        translate([0,0,-1]) cylinder(h=body_height, d=motor_collar_dia);
        //motor fixings
        translate([motor_fixing_centres/2,0,-1]) cylinder(h=body_height, d=motor_fix_hole_dia);
        translate([-motor_fixing_centres/2,0,-1]) cylinder(h=body_height, d=motor_fix_hole_dia);
        //mounting holes
        translate([fixing_centres/2,0,-1]) cylinder(h=body_height, d=fix_hole_dia);
        translate([-fixing_centres/2,0,-1]) cylinder(h=body_height, d=fix_hole_dia);
    }
}
cm_bracket();