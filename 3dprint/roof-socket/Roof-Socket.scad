/*
    Proxymow Mower - Roof Socket
    Print in TPU

    Adjust pillar_dia to suit roof pillars
*/

pillar_dia = 22.7;//mm
socket_dia = 30;//mm
floor_thickness = 1.5;//mm
socket_thickness = 10;//mm
taper_factor = 0.9;
fix_hole_dia = 4.5;//mm
module socket() {
    difference() {
        cylinder(h=socket_thickness, d=socket_dia);
        translate([0, 0, floor_thickness + 0.1]) cylinder(h=socket_thickness - floor_thickness, d=pillar_dia, $fn=32);
        translate([0, 0, floor_thickness + 0.1]) cylinder(h=socket_thickness - floor_thickness, d1=pillar_dia * taper_factor, d2=pillar_dia/taper_factor, $fn=32);
        translate([0, 0, -0.1]) cylinder(h=floor_thickness + 2, d=fix_hole_dia, $fn=32);
    }
}
socket();