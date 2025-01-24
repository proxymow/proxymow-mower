/*
    Proxymow Mower - Omniwheel Assembly
    Don't Print - just for visualisation
*/
use <Frame.scad>
use <NS-wheel.scad>
num_wheels = 9;
mount_dia = 70;//mm
sector_angle = 360/num_wheels;
module wheels() {
    for (w = [0:1:num_wheels]) { 
        //wheel
        rotate([0, 0, w * sector_angle]) translate([mount_dia/2, -1, 0]) rotate([90,0,-10]) 
            wheel();
    }
}
module ow_assembly() {
    rotate([0, 90, 0]) union() {
        frame();
        color("black") wheels();
    }
}

ow_assembly();