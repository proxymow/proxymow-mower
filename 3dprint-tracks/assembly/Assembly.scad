//tracked robot assembly

include <../shared/Constants.scad>
use <../idler-wheel/Idle Wheel.scad>
use <../idler-hub/Idle Hub.scad>
use <../idler-hub/Idle Axles.scad>
use <../tension-rod-adaptor/Hub Threaded Insert.scad>
use <../thumbwheels/Thumbwheel.scad>
use <../motor-plate/Motor Plate.scad>
use <../drive-motor-bracket/Planetary Motor Bracket.scad>
use <../bearing-plate/Bearing BackPlate.scad>
use <../tube-clamp/Tube Clamp.scad>
use <../drive-sprocket/Spindle.scad>
use <../drive-sprocket/Drive Sprocket Shaft.scad>
use <../drive-sprocket/Drive Plain Cog.scad>
use <../drive-sprocket/Drive Sprocket Cog.scad>
use <threadlib/threadlib.scad>

/*
    idle tube stop is the distance from sprocket axle to tube
    we need it to cut the wheelbase tubes to length
*/
idle_tube_stop = tooth_height + hub_thickness + (idle_wheel_dia/2) - tube_insertion;
echo("idle_tube_stop:", idle_tube_stop);

module square_tube(span=100) {
    color("grey") translate([span/2, 0, 0]) difference() {
        cube([span, 10, 10], center=true);
        cube([span + 0.1, 8, 8], center=true);
    }
}
module aluminium_angle(span=100) {
    color("grey") translate([span/2, 0, 0]) difference() {
        cube([span, 11.5, 11.5], center=true);
        translate([0, 0.76, -0.76]) cube([span + 0.1, 10, 10], center=true);
    }
}
module threaded_rod(rod_length=100) {
    num_turns = rod_length*0.795;
    rotate([0, 90, 0]) color("grey") bolt("M8", turns=num_turns);
}
module washer(thickness, od, id) {
    color("black") rotate([0, 90, 0]) difference() {
        cylinder(h=thickness, d=od, $fn=32, center=true);
        cylinder(h=thickness*2, d=id, $fn=32, center=true);
    }
}
module eclip(thickness, od, id) {
    color("silver") rotate([0, 90, 0]) difference() {
        cylinder(h=thickness, d=od, $fn=32, center=true);
        cylinder(h=thickness*2, d=id, $fn=32, center=true);
        cube([id/3, 3*od/4, thickness], $fn=32, center=true);
        translate([3*(od - id)/8, 0, 0]) rotate([0, 0, 90]) cube([id/3, od, thickness], $fn=32, center=true);
    }
}
module bearing(thickness, od, id) {
    color("silver") rotate([90, 0, 0]) difference() {
        cylinder(h=thickness, d=od, $fn=32, center=true);
        cylinder(h=thickness*2, d=id, $fn=32, center=true);
    }
}
module motor() {
    translate([0, 0, -55]) cylinder(h=110, d=36, $fn=32, center=true);
    intersection() {
        translate([0, 0, 8.75]) cylinder(h=17.5, d=8, $fn=32, center=true);
        translate([0, 0, 8.75]) cube([8, 6, 17.5], center=true);
    }
}
module track_assembly() {
    tube_y_offset = sprocket_spacing + (hub_thickness + idle_wheel_thickness)/2;
    echo("tube_y_offset:", tube_y_offset);
    
    //front idler
    %idler_end();
    
    //back adjustable idler
    %translate([250, 0, 0]) mirror([1,0,0]) idler_end();
    
    //bearings 6mm id x 16mm od x 5mm thick
    color("darkgray") translate([275, tube_y_offset, 0]) bearing(5, 16, 6);
    color("darkgray") translate([275, -tube_y_offset, 0]) bearing(5, 16, 6);
    color("darkgray") translate([0, tube_y_offset, 0]) bearing(5, 16, 6);
    color("darkgray") translate([0, -tube_y_offset, 0]) bearing(5, 16, 6);
   
    //threaded inserts
    translate([210, tube_y_offset, 0]) rotate([0, 90, 0]) rotate([0, 0, 45]) hub_insert();
    translate([210, -tube_y_offset, 0]) rotate([0, 90, 0]) rotate([0, 0, 45]) hub_insert();
    
    //threaded rods
    translate([133, tube_y_offset, 0]) threaded_rod(90);
    translate([133, -tube_y_offset, 0]) threaded_rod(90);
    
    //thumbwheels
    translate([190, tube_y_offset, 0]) rotate([0, 90, 0]) thumbwheel(KNURLED_WHEEL_HEIGHT, KNOB_DIAM, KNURLED_WHEEL_NUM_TURNS);
    translate([190, -tube_y_offset, 0]) rotate([0, 90, 0]) thumbwheel(KNURLED_WHEEL_HEIGHT, KNOB_DIAM, KNURLED_WHEEL_NUM_TURNS);

    //locknuts
    translate([195, tube_y_offset, 0]) rotate([0, 90, 0]) thumbwheel(LOCKNUT_HEIGHT, KNOB_DIAM, LOCKNUT_NUM_TURNS);
    translate([195, -tube_y_offset, 0]) rotate([0, 90, 0]) thumbwheel(LOCKNUT_HEIGHT, KNOB_DIAM, LOCKNUT_NUM_TURNS);
    
    //washers
    translate([186, tube_y_offset, 0]) washer(1.4, 16, 8.4);
    translate([186, -tube_y_offset, 0]) washer(1.4, 16, 8.4);
    
    //idler
    rotate([0, 90, 90]) idle_wheel();
    translate([275, 0, 0]) rotate([0, 90, 90]) idle_wheel();
    
    //idler axle
    translate([0, -30, 0]) rotate([0, 0, 90]) idle_axle();
    translate([250, -100, 0]) rotate([0, 0, 90]) idle_axle();
    
    //idler washers
    translate([0, 28.8, 0]) rotate([0, 0, 90]) washer(1.2, 12, 6.3);
    translate([0, -28.8, 0]) rotate([0, 0, 90]) washer(1.2, 12, 6.3);
    translate([250, 30, 0]) rotate([0, 0, 90]) washer(1.2, 12, 6.3);
    translate([250, -30, 0]) rotate([0, 0, 90]) washer(1.2, 12, 6.3);
    
    //idler e-clips
    translate([0, 30.5, 0]) rotate([0, 0, 90]) eclip(1, 8, 5);
    translate([250, 33, 10]) rotate([0, 0, 90]) eclip(1, 8, 5);
    
    wb_tube_length = 120;
    echo("wb_tube_length:", wb_tube_length);
    
    //inner tube - with 4.5mm hole 51mm from end
    translate([idle_tube_stop, tube_y_offset, 0]) difference() {
        square_tube(wb_tube_length);
        translate([51, 0, 0]) rotate([90, 0, 0]) cylinder(h=tube_outer_dim*2, d=4.5, $fn=32, center=true);
    }
    
    //outer tube - with 4.5mm hole 51mm from end
    translate([idle_tube_stop, -tube_y_offset, 0]) difference() {
        square_tube(wb_tube_length);
        translate([51, 0, 0]) rotate([90, 0, 0]) cylinder(h=tube_outer_dim*2, d=4.5, $fn=32, center=true);
    }
    
    //motor plate
    translate([100, sprocket_spacing + (motor_plate_thickness + tube_outer_dim + hub_thickness + idle_wheel_thickness)/2, track_triangle_height]) rotate([90, 0, 180]) plan_motor_plate();
    
    //tube clamp
    translate([129, -20, 0]) rotate([90, 0, 90]) tube_clamp();
    translate([129, 20, 0]) rotate([90, 0, -90]) tube_clamp();
    
    //motor
    color("blue") translate([100, sprocket_spacing + (motor_plate_thickness + tube_outer_dim + hub_thickness + idle_wheel_thickness)/2, track_triangle_height]) rotate([90, -90, 0]) motor();
    
    //motor bracket
    translate([100, 130, track_triangle_height]) rotate([90, 0, 0]) plan_motor_bracket();

    //bearing backplate
    %translate([100, -(sprocket_spacing + (hub_thickness + motor_plate_thickness + idle_wheel_thickness + tube_outer_dim)/2), track_triangle_height]) rotate([90, 0, 180]) back_plate();
    
    //bearing 8mm id x 16mm od x 5mm thick
    color("darkgray") translate([100, -(sprocket_spacing + (hub_thickness + idle_wheel_thickness + tube_outer_dim - 5)/2), track_triangle_height]) bearing(5, 16, 8);
    
    //spindle
    translate([100, 0, track_triangle_height]) rotate([90, 0, 0]) spindle();
    
    //drive sprocket shaft
    translate([100, -10, track_triangle_height]) rotate([-90, 0, 0]) drive_sprocket_shaft();
    
    //drive cogs
    translate([100, 9, track_triangle_height]) rotate([90, 0, 0]) drive_plain_cog();
    translate([100, 5.5, track_triangle_height]) rotate([90, 0, 0]) drive_sprocket_cog();
    translate([100, -9, track_triangle_height]) rotate([90, 0, 0]) drive_plain_cog();
    
    //locknut
    translate([100, -13.75, track_triangle_height]) rotate([90, 0, 0]) thumbwheel(LOCKNUT_HEIGHT, KNOB_DIAM, LOCKNUT_NUM_TURNS);
    
    //shelf support 11.5x11.5x160 aluminium angle
    difference() {
        translate([20, 35.25, 24.75]) aluminium_angle(160);
        translate([71, 35.25, 24.0]) rotate([90, 0, 0]) cylinder(h=20, d=4.5, $fn=32, center=true);
        translate([129, 35.25, 24.0]) rotate([90, 0, 0]) cylinder(h=20, d=4.5, $fn=32, center=true);
    }
    
    //battery, control box & cutter motor shelf approx 500mm x 250mm x 9mm thick plywood
    //not shown full size
    color("brown") translate([100, 80, 35]) cube([160, 110, 9], center=true);
}
track_assembly();