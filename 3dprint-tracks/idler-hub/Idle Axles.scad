include <../shared/Constants.scad>
//Idler Axles
//suggest slicing with 50% infill?
//use washers at both ends, and one E Clip

module idle_axle() {
    translate([0, 0, -idle_rod_dia/2.5]) difference() {
        translate([0, 0, idle_rod_dia/2.5]) union() {
            translate([0, 0, 0]) rotate([0, 90, 0]) cylinder(h=idle_rod_length, d=idle_rod_dia, $fn=64);
            translate([-idle_rod_cap_length, 0, 0]) rotate([0, 90, 0]) cylinder(h=idle_rod_cap_length, d=idle_rod_dia*1.75, $fn=64);
            translate([idle_rod_length, 0, 0]) rotate([0, 90, 0]) cylinder(h=idle_rod_clip_width, d=idle_rod_clip_dia, $fn=64);
            translate([idle_rod_length, 0, 0]) rotate([0, 90, 0]) cylinder(h=idle_rod_clip_width, d=idle_rod_clip_dia, $fn=64);
            translate([idle_rod_length+idle_rod_clip_width, 0, 0]) rotate([0, 90, 0]) cylinder(h=idle_rod_clip_width, d=idle_rod_dia, $fn=64);
        }
        translate([-idle_rod_length, -idle_rod_length/2, -idle_rod_length]) cube([idle_rod_length * 3, idle_rod_length, idle_rod_length], center=false);
    }
}
for(n=[0:1:3]) {
    translate([0, n * 12, idle_rod_dia/2.5]) idle_axle();
}
