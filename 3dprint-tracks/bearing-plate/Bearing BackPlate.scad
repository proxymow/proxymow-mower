//Bearing BackPlate
include <../shared/Constants.scad>

module back_plate() {
    /*
        generates a plate that accomodates any combination of cartesian/polar holes/slots
        the common origin aligns with the motor shaft
    */

    cart_holes = [
        // x, y, d
        [29, -50, 4.8],     // wheelbase tube mount
        [-29, -50, 4.8]     // wheelbase tube mount
    ];
    
    cart_slots = [
        // x1, y1, x2, y2, d
        [29, -36, 29, -60, 4.8],
        [-29, -36, -29, -60, 4.8]
    ];
    polar_holes = [
        //r, theta, d
    ];

    difference() {
        union() {
            //plate corners
            hull() {
                //bearing housing at origin
                cylinder(h=motor_plate_thickness, d=drive_bearing_bush_dia, $fn=32, center=true);
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
            }//end hull
            //bearing bush
            translate([0, 0, drive_bearing_recess]) cylinder(h=drive_bearing_recess * 2, d=drive_bearing_bush_dia, $fn=32, center=true);
            //bearing bush fillet
            translate([0, 0, motor_plate_thickness/2]) circular_fillet(extent=10, dia=drive_bearing_bush_dia, angle=130);
        }//end union
            
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
        //bearing recess
        translate([0, 0, drive_bearing_recess + 0.1]) cylinder(h=drive_bearing_recess * 2, d=drive_bearing_fit_dia, $fn=32, center=true);
    }    
}

module circular_fillet(extent=10, dia=10, angle=360) {
    rotate([0, 0, -(90 - (angle/2))]) rotate_extrude(angle=-angle, $fn=64) translate([extent + (dia/2), extent]) mirror([1, 1, 0]) difference() {
        square(extent);
        circle(extent, $fn=32);
    }
}
back_plate();