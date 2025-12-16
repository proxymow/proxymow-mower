include <../shared/Constants.scad>

module plan_motor_plate() {
    /*
        generates a plate that accomodates any combination of cartesian/polar holes/slots
        the common origin aligns with the motor shaft
        suitable for transverse planetary motors
    */

    cart_holes = [
        // x, y, d
        [29, 29, 4.8],     // motor cover mount hole
        [-29, 29, 4.8],    // motor cover mount hole
    ];
    
    cart_slots = [
        // x1, y1, x2, y2, d
        [29, -36, 29, -60, 4.8], //slot pitch = 58
        [-29, -36, -29, -60, 4.8]
    ];
    polar_holes = [
        //r, theta, d
        [14, 0, 3.5],   //planetary motor mount
        [14, 90, 3.5],  //planetary motor mount
        [14, 180, 3.5], //planetary motor mount
        [14, 270, 3.5]  //planetary motor mount
    ];

    difference() {
        //plate corners
        hull() {
            //cartesian holes
            for (i=[0:1:len(cart_holes)-1]) {
                translate([cart_holes[i][0], cart_holes[i][1], 0]) cylinder(h=motor_plate_thickness, d=motor_plate_corner_dia, $fn=32, center=true);
            }
            //cartesian slots
            for (i=[0:1:len(cart_slots)-1]) {
                translate([cart_slots[i][0], cart_slots[i][1], 0]) cylinder(h=motor_plate_thickness, d=motor_plate_corner_dia, $fn=32, center=true);
                translate([cart_slots[i][2], cart_slots[i][3], 0]) cylinder(h=motor_plate_thickness, d=motor_plate_corner_dia, $fn=32, center=true);
            }
            //polar holes
            for (i=[0:1:len(polar_holes)-1]) {
                rotate([0, 0, -polar_holes[i][1]]) translate([polar_holes[i][0], 0, 0]) cylinder(h=motor_plate_thickness, d=motor_plate_corner_dia, $fn=32, center=true);
            }            
        }
        //gearbox collar at origin
        cylinder(h=motor_plate_thickness * 2, d=gearbox_collar_hole_dia, $fn=32, center=true);
        
        //cartesian holes
        for (i=[0:1:len(cart_holes)-1]) {
            translate([cart_holes[i][0], cart_holes[i][1], 0]) cylinder(h=motor_plate_thickness * 16, d=cart_holes[i][2], $fn=32, center=true);
        }
        
        //cartesian slots
        for (i=[0:1:len(cart_slots)-1]) {
            hull() {
                translate([cart_slots[i][0], cart_slots[i][1], 0]) cylinder(h=motor_plate_thickness * 2, d=cart_slots[i][4], $fn=32, center=true);
                translate([cart_slots[i][2], cart_slots[i][3], 0]) cylinder(h=motor_plate_thickness * 2, d=cart_slots[i][4], $fn=32, center=true);
            }
        }
        //polar holes
        for (i=[0:1:len(polar_holes)-1]) {
            rotate([0, 0, -polar_holes[i][1]]) translate([polar_holes[i][0], 0, 0]) cylinder(h=motor_plate_thickness * 2, d=polar_holes[i][2], $fn=32, center=true);
        }
    }
    //shoulder
    translate([0, 0, (plan_shoulder_height + motor_plate_thickness)/2]) difference() {
        cylinder(h=plan_shoulder_height, d=plan_motor_dia + (plan_shoulder_thickness * 2), center=true, $fn=32);
        cylinder(h=plan_shoulder_height*2, d=plan_motor_dia, center=true, $fn=32);
        //baseplate clearance
        translate([0, -((plan_motor_dia/2) + plan_shoulder_thickness + plan_shoulder_base_thickness), 0]) cube([100, 10, plan_shoulder_height*2], center=true);        
    }
}

plan_motor_plate();
