/*
    Proxymow Mower - Hinge
    Print in TPU

    Adjust thickness to vary flexibility
*/

fix_hole_dia = 4.5;
corner_dia = 10;
hinge_length = 55;
hinge_width = 80;
thickness = 2.0;
fix_offset_x = 30;
fix_offset_y = 20;

module hinge() {
    difference() {
        hull() {
            translate([hinge_width/2, hinge_length/2, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
            translate([-hinge_width/2, hinge_length/2, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
            translate([hinge_width/2, -hinge_length/2, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
            translate([-hinge_width/2, -hinge_length/2, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
        }
        translate([fix_offset_x, fix_offset_y, 1]) cylinder(h=thickness+2, d=fix_hole_dia, center=true, $fn=32);
        translate([fix_offset_x, -fix_offset_y, 1]) cylinder(h=thickness+2, d=fix_hole_dia, center=true, $fn=32);
        translate([-fix_offset_x, fix_offset_y, 1]) cylinder(h=thickness+2, d=fix_hole_dia, center=true, $fn=32);
        translate([-fix_offset_x, -fix_offset_y, 1]) cylinder(h=thickness+2, d=fix_hole_dia, center=true, $fn=32);
    }
}

hinge();