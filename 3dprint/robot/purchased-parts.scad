/*
    Proxymow Mower - Purchased parts
    Don't Print - just for illustration

*/
module wheel_flange() {
    major_dia = 32;
    minor_dia = 16;
    hole_dia = 10;
    fix_hole_span = 24;//mm
    fix_hole_dia = 3.9;//mm
    grub_hole_dia = 3;
    thickness = 3;
    height = 13;
    difference() {
        union() {
            cylinder(h=thickness, d=major_dia, $fn=32);
            cylinder(h=height, d=minor_dia, $fn=32);
        }
        //central hole
        cylinder(h=height + 2, d=hole_dia, $fn=32);
        
        //fixing holes
        for(i = [0 : 90 : 360])
         rotate(i) translate([0, -fix_hole_span/2, -1]) cylinder(h=thickness+2, d=fix_hole_dia, $fn=32);
        
        //grub hole
        translate([0, 0, height/2]) rotate([0, 90, 45]) cylinder(h=minor_dia + 2, d=grub_hole_dia, $fn=32, center=true);
        
    }
}
module cutter_flange() {
    major_dia = 22;
    minor_dia = 11;
    hole_dia = 5;
    fix_hole_span = 16;//mm
    fix_hole_dia = 3.0;//mm
    grub_hole_dia = 3;
    thickness = 2;
    height = 12;
    difference() {
        union() {
            cylinder(h=thickness, d=major_dia, $fn=32);
            cylinder(h=height, d=minor_dia, $fn=32);
        }
        //central hole
        cylinder(h=height + 2, d=hole_dia, $fn=32);
        
        //fixing holes
        for(i = [0 : 90 : 360])
         rotate(i) translate([0, -fix_hole_span/2, -1]) cylinder(h=thickness+2, d=fix_hole_dia, $fn=32);
        
        //grub hole
        translate([0, 0, height/2]) rotate([0, 90, 45]) cylinder(h=minor_dia + 2, d=grub_hole_dia, $fn=32, center=true);
        
    }
}
module hinge() {
    difference() {
        cube([80, 100, 0.25], center=true);
        translate([20, 30, 1]) cylinder(h=3, d=4.5, center=true, $fn=32);
        translate([20, -30, 1]) cylinder(h=3, d=4.5, center=true, $fn=32);
        translate([-20, 30, 1]) cylinder(h=3, d=4.5, center=true, $fn=32);
        translate([-20, -30, 1]) cylinder(h=3, d=4.5, center=true, $fn=32);
    }
}
module battery_7ah() {
    cube([151, 65, 102]);//incl terminals
}
module drive_motor() {
    cylinder(h=60, d=37);
    rotate([0, 0, 180]) translate([-7, 0, 60]) cylinder(h=19.5, d=6);    
}
module cutter_motor() {
    cylinder(h=77, d=45);
    translate([0, 0, -21]) cylinder(h=98, d=5);    
}
drive_motor();