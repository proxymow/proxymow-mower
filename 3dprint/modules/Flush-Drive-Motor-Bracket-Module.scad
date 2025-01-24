use <Drive-Motor-Bracket-Foot-Module.scad>
$fa=1;
$fs=0.4;

module fillet(width=20, radius=3, orient=0) {
    rotate([orient,0,0]) difference() {
        color("yellow") translate([2, 0, 0]) rotate([0,90,0]) cylinder(width-4, r=radius, center=false);
        translate([1, radius, radius]) rotate([0,90,0]) cylinder(width, r=radius, center=false);
    }
}

module flush_drive_motor_bracket(pad_width=50, pad_length=25, pad_height=10, hole_size="M4", motor_dia=40) {
    pad_offset = 26;
    bracket_dia = motor_dia + (2 * pad_height);
    difference() {
        union() {
            translate([pad_width/2, pad_height + (motor_dia + pad_length)/2 - 4, 0]) 
                top_foot(pad_width, pad_length, pad_height, hole_size, 0, 4);
            translate([pad_width/2, -(pad_height + (motor_dia + pad_length)/2 - 4), 0]) 
                top_foot(pad_width, pad_length, pad_height, hole_size, 0, -4);
            translate([0, 0, -pad_height]) difference() {
                union() {
                    translate([0, 0, motor_dia/2+ pad_height]) rotate([0,90,0]) cylinder(pad_width, r=motor_dia/2 + pad_height, center=false);
                    translate([0, -bracket_dia/2, 0]) cube([pad_width, bracket_dia, bracket_dia/2], center=false);
                }
                translate([-1, 0, motor_dia/2 + pad_height]) rotate([0,90,0]) cylinder(pad_width+2, r=motor_dia/2, center=false);
                translate([-1, -motor_dia/2, 0]) cube([pad_width+2, motor_dia, bracket_dia/2], center=false);
                translate([-1,-bracket_dia,-bracket_dia+pad_height]) cube([bracket_dia, 2*bracket_dia, bracket_dia], center=false);
            }
    translate([0, motor_dia/2 + pad_height, pad_height]) fillet(pad_width, pad_width/3);
    translate([0, -(motor_dia/2 + pad_height), pad_height]) fillet(pad_width, pad_width/3, 90);
            }
    }
}