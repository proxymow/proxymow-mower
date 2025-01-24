/*
    Proxymow Mower - Omniwheel SubWheels
    Print without support in Black PETG
*/
wheel_outer_dia = 27;// mm
wheel_thickness = 7;// mm
wheel_hole_dia = 5.8;//mm
tape_width = 48;//mm

module wheel() {
    difference() {
        rotate_extrude(angle=360, $fn=32) 
            union() {
                hull() {
                    translate([(wheel_outer_dia-wheel_thickness)/1.65, 0, 0]) 
                        circle(d=wheel_thickness/1.75, $fn=32);
                    translate([wheel_thickness/2, 0, 0]) square([wheel_thickness, wheel_thickness], center=true);
                }
        }
        cylinder(h=wheel_thickness+1, d=wheel_hole_dia, center=true, $fn=32);
    }
}
//optimum print layout...
translate([-wheel_outer_dia/2.3, 0, 0]) union() {
    for (w = [0:1:4]) translate([0, w*wheel_outer_dia * 1.05, 0]) wheel();
    for (w = [0:1:3]) translate([wheel_outer_dia/1.075, (w + 0.5)*wheel_outer_dia * 1.05, 0]) wheel();
}
