/*
    Proxymow Mower - Omniwheel Axle
    Print in Black PETG
    
    Use E-clip to retain

*/

rod_dia = 4.80;//mm
rod_length = 50;//mm
stop_length = 2;//mm
stop_dia = 5.5;
slot_width = 1;//mm
slot_dia = 4;//mm
module rod() {
    difference() {
        union() {
            translate([0, 0, rod_dia/2.5]) rotate([0, 90, 0]) cylinder(h=rod_length, d=rod_dia, $fn=64);
            translate([0, 0, rod_dia/2.5]) rotate([0, 90, 0]) cylinder(h=stop_length, d=stop_dia, $fn=64);
        }
        difference() {
        translate([rod_length-stop_length, 0, rod_dia/2.5]) rotate([0, 90, 0]) cylinder(h=slot_width, d=slot_dia*2, $fn=64);
        translate([rod_length-stop_length, 0, rod_dia/2.5]) rotate([0, 90, 0]) cylinder(h=slot_width, d=slot_dia, $fn=64);
        }
        translate([0, -rod_length/2, -rod_length]) cube(rod_length, center=false);
    }
}

for(n=[0:1:3]) {
    translate([0, n * 7, 0]) rod();
}