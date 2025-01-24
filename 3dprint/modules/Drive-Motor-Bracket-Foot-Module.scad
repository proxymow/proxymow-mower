use <Drive-Motor-Foot-Module.scad>
use <Drive-Motor-Metric-Hole-Module.scad>
$fa=1;
$fs=0.4;

module top_foot(pad_width=50, pad_length=25, pad_height=10, hole_size="M4", hole_offset_x=0, hole_offset_y=0) {
    hole_offset = pad_length/2 - pad_width/2;
    translate([0, 0, 0]) difference() {
        drive_motor_foot(pad_width, pad_length, pad_height);
        translate([0, 0, pad_height]) metric_hole(pad_height, hole_size, hole_offset_x, hole_offset_y, false);
    }
}