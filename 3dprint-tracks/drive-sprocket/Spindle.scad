//Spindle for Sprocket Components
include <../shared/Constants.scad>
use <threadlib/threadlib.scad>

module dee_shaft(hgt, dia, offset) {
    difference() {
        cylinder(h=hgt, d=dia, center=true, $fn=32);
        translate([0, dia - offset, 0]) cube([dia, dia, hgt+0.1], center=true);
        translate([0, -(dia - offset), 0]) cube([dia, dia, hgt+0.1], center=true);
    }
}

module spindle() {
     {
        rotate([0, 180, 0]) difference() {
            union() {
                cylinder(h=spindle_length, d=spindle_outer_dia, $fn=6, center=true);
                translate([0, 0, (spindle_length + spindle_shoulder_width)/2]) cylinder(h=spindle_shoulder_width, d=spindle_shoulder_dia, $fn=32, center=true);
            }
        translate([0, 0, (spindle_drive_shaft_length + 0.1)/2]) dee_shaft(spindle_drive_shaft_length, spindle_dee_shaft_dia, spindle_dee_shaft_offset);
        translate([0, 0, -(spindle_length/2)]) cylinder(h=spindle_length + 2, d=spindle_bearing_shaft_dia, center=true, $fn=32);
        }
        translate([0, 0, 0.5]) scale([spindle_thread_x_factor, spindle_thread_y_factor, spindle_thread_z_factor]) nut("M8", turns=spindle_thread_num_turns, Douter=9, $fn=6);
    }
}

spindle();