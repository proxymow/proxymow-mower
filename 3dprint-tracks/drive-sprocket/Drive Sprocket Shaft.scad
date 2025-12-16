include <../shared/Constants.scad>
use <threadlib/threadlib.scad>
//Drive Sprocket Shaft - replace with section cut from M8 shanked stainless steel bolt for additional strength
module drive_sprocket_shaft() {
    rotate([0, 180, 0]) union() {
        translate([0, 0, -12.5]) bolt("M8", turns=drive_sprocket_shaft_num_turns, higbee_arc=30);
        translate([0, 0, (bearing_section_length/2) + 5]) cylinder(h=bearing_section_length, d=back_bearing_stub_dia, $fn=64, center=true);
    }
}

drive_sprocket_shaft();