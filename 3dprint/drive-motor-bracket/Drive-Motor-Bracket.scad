/*
    Proxymow Mower - Drive Motor Bracket
    For GB37RG Type 12V DC Motor
    Print in PETG
*/
use <..\modules\Flush-Drive-Motor-Bracket-Module.scad>

$fa=1;
$fs=0.4;

pad_width = 14; //mm
pad_length = 25; //mm
pad_height = 6; //mm
hole_size = "M4";
gearbox_dia = 37;//mm
bracket_dia = gearbox_dia + 0.25;//larger plus normal tolerance
motor_bush_hole_dia = 12.4;//mm + clearance
motor_bush_rad = 7.4;//mm
motor_pitch_circle_dia = 31;//mm
motor_mount_hole_dia = 3.5;//mm
plate_thickness = 3.5;//mm - accommodates 10mm screws without fouling

module plate() {
    translate([0, 0, gearbox_dia/2]) rotate([0, 90, 0]) cylinder(plate_thickness, d=gearbox_dia + 1);
}
module motor_bracket() {
    difference() {
        union() {
            //surround
            flush_drive_motor_bracket(pad_width, pad_length, pad_height, hole_size, bracket_dia);

            //faceplate
            hull() {
                plate();
                translate([0,-gearbox_dia/2, 0]) cube([plate_thickness, gearbox_dia, gearbox_dia/2]);
            }
        }
        //motor axle hole slot
        for (a=[0:60:360]) {
            translate([-1,0,(gearbox_dia/2)]) 
        rotate([a,0,0]) 
        translate([-1,0,motor_bush_rad]) rotate([0,90,0]) cylinder(h=plate_thickness+3, r=(motor_bush_hole_dia/2)); 
        }
        //remove centre leftovers
        translate([-1,0,(gearbox_dia/2)]) rotate([0,90,0]) cylinder(h=plate_thickness+3, r=(motor_bush_hole_dia/2)); 
        //motor mounting holes
        for (a=[30:60:360]) {
            translate([-1,0,(gearbox_dia/2)]) rotate([a,0,0]) translate([-1,0,(motor_pitch_circle_dia/2)]) rotate([0,90,0]) cylinder(h=plate_thickness+3, d=motor_mount_hole_dia); 
        }
    }
}
rotate([0, 270, 0]) motor_bracket();