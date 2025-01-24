/*
    Proxymow Mower - Omniwheel Frame
    Print in Black PETG
*/
use <ns-wheel.scad>
wheel_hole_dia = 5.8;//mm
wheel_thickness = 7;// mm
axle_bush_dia = 10;//mm
mount_dia = 70;//mm
num_wheels = 9;
incl_wheels = num_wheels;
sector_angle = 360/num_wheels;
spoke_width = 8;//mm
sector_side_length = mount_dia * tan(180/num_wheels);//mm
axle_hole_length = 40;//mm
axle_depth = -5;//mm
flange_radius = 10;
flange_wall_thickness = 5;
flange_height = 10;
flange_hole_dia = 2 * (flange_radius - flange_wall_thickness);
shaft_hole_dia = 6;//clearance for 5mm perspex shaft
bearing_od = 15;
bearing_fit_dia = bearing_od * 1.02;//tight fit for bearing
bearing_width = 5;

module frame_body() {

    for (w = [0:1:incl_wheels]) { 
        //donut ring
        rotate_extrude(angle=sector_angle*(incl_wheels + 1)) translate([mount_dia/2, 0, 0]) circle(d=axle_bush_dia, $fn=32);
        //spokes
        rotate([0, 0, (w + 0.5) * sector_angle]) translate([0, -spoke_width/4, -axle_bush_dia/2]) cube([mount_dia/2 + 0.5, spoke_width/2, axle_bush_dia], center=false);
    }
    //flange
    cylinder(flange_height, r=flange_radius, center = true);
}
module frame_holes() {
    
    for (w = [0:1:incl_wheels]) { 
        //wheel gap
        rotate([0, 0, w * sector_angle]) translate([mount_dia/2, -1, 0]) rotate([90,0,-10]) 
            cylinder(h=wheel_thickness+1, d=axle_bush_dia*2, center=true, $fn=32);
        //axle access holes
        rotate([0, 0, w * sector_angle]) translate([mount_dia/2, 0, 0]) rotate([90,0,-10]) 
            translate([0, 0, -axle_hole_length+13]) cylinder(h=axle_hole_length, d=wheel_hole_dia*1.0, center=false, $fn=32);
    }
    //shaft hole
    translate([0,0,1]) cylinder(flange_height*2, d=shaft_hole_dia, center = true, $fn=32);
    //5x15x5 bearing recess
    translate([0,0,bearing_width/2 + 0.5]) cylinder(bearing_width + 1, d=bearing_fit_dia, center = true, $fn=32);
}
module frame() {
    difference() {
        frame_body();
        frame_holes();
    }
}

frame();