/*
    Proxymow Mower - Robot Miscellaneous non-printed parts
    Don't Print - just for illustration

*/

//baseplate
ratio = 0.6;
thickness = 9;//mm plywood
width = 260;//mm
length = 500;//mm
roof_width = 300;//mm
roof_length = 420;//mm
roof_thickness = 4;//mm

module baseplate_north() {
    difference() {
        cylinder(h=thickness, d=length);
        translate([width, 0, (thickness/2) + 1]) cube([width, length, thickness + 4],center=true);
        translate([-width, 0, (thickness/2) + 1]) cube([width, length, thickness + 4],center=true);
        translate([0, -length*ratio, (thickness/2) + 1]) cube([width+1, length, thickness + 4],center=true);
    }        
}
module baseplate_south() {
    difference() {
        cylinder(h=thickness, d=length);
        translate([width, 0, (thickness/2) + 1]) cube([width, length, thickness + 4],center=true);
        translate([-width, 0, (thickness/2) + 1]) cube([width, length, thickness + 4],center=true);
        translate([0, length*(1-ratio), (thickness/2) + 1]) cube([width+1, length, thickness + 4],center=true);
    }        
}
module roof() {
    //A3 Roof
    cube([roof_width, roof_length, roof_thickness], center=true);
}
module drive_shaft() {
    rotate([0, 90, 0]) difference() {
        cylinder(h=65, d=6, $fn=32, center=true);
        translate([5.5, 0, 0]) cube([6, 6, 65], center=true);
    }
}