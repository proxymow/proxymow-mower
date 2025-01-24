/*
    Proxymow Mower - Bearing Housing
    Supports mower weight to extend motor life
    Print in PETG
    Adapt hole to suit any available bearing
*/
use <..\modules\Flush-Drive-Motor-Bracket-Module.scad>

$fn = 32;
pad_width = 14; //14
pad_length = 25; //25
pad_height = 6; //6
hole_size = "M4";
pad_hole_offset = 4;
gearbox_dia = 37;//mm
//the following dimensions match the motor housing!
//then the holes will line up
bracket_dia = gearbox_dia + 0.25;//larger plus normal tolerance
motor_bush_rad = 7.4;//mm

bearing_id = 6;//mm
bearing_od = 13;//mm
bearing_width = 5;//mm
housing_dia = (bracket_dia + pad_height)*1.0;
bearing_fit_dia = bearing_od * 1.02;//push fit
shaft_clearance_dia = bearing_id * 1.25;//clearance

module housing() {
    difference() {
        union() {
            flush_drive_motor_bracket(pad_width, pad_length, pad_height, hole_size, bracket_dia);
            translate([0,0,housing_dia/2]) rotate([0,90,0]) cylinder(h=pad_width, d=housing_dia);
            translate([0,(-housing_dia/2), 0]) cube([pad_width, housing_dia, (housing_dia/2)+motor_bush_rad]);
        }
        //bearing recess
        translate([-0.5,0,(gearbox_dia/2) + motor_bush_rad]) rotate([0,90,0]) cylinder(h=bearing_width+1, d=bearing_fit_dia);
        //shaft clearance
        translate([0,0,(gearbox_dia/2) + motor_bush_rad]) rotate([0,90,0]) cylinder(h=bearing_width*4, d=shaft_clearance_dia);
        
    }
}
//rotate for printing
rotate([0, 90, 0]) housing();
