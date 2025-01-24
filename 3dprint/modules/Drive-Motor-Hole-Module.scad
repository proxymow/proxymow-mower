$fa=1;
$fs=0.4;
module pad_hole(height=10, hole_dia=2, csk_dia=0, altitude=0, hole_offset_x=0, hole_offset_y=0) {
    shim = 0.1;//ensure hole pierces material
    translate([hole_offset_x, hole_offset_y, shim/2]) rotate([0, 180, 0]) union() { 
        cylinder(h=height + shim, d=hole_dia);
        cylinder(h=altitude, d1=csk_dia, d2=hole_dia);
        translate([0, 0, -height/2]) cylinder(h=height/2, d=csk_dia);
    }
}
*pad_hole(10, 2, 6, 6, 0, 10);