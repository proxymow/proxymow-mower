/*
    Proxymow Mower - Tubular Handle
    Print in PETG

    Useful way to carry robot to site!
    Use pillar socket for forward roof pillar
*/
handle_dia = 20;
final_thickness = 17;
arch_rad = 40;
fingers_width = 80;
fingers_depth = 20;
hole_dia = 7.0;
recess_dia = 16.25;
loc_square_depth = 4;
shoulder = 25;
pillar_dia = 24;
pillar_socket_dia = 30;
pillar_socket_height = 20;

module arch() {
    translate([-arch_rad + (fingers_width + handle_dia)/2, 0, 0])rotate_extrude(angle=90, $fn=100) translate([arch_rad, 0, 0]) circle(d=handle_dia, $fn=32);
}
module bridge() {
    bridge_width = fingers_width/2 + handle_dia/2 - arch_rad;
    translate([bridge_width/2, arch_rad, 0]) rotate([0, 90, 0]) cylinder(h=bridge_width, d=handle_dia, $fn=32, center=true);
}
module leg() {
    translate([(fingers_width + handle_dia)/2, 0, 0]) rotate([90, 0, 0]) cylinder(h=fingers_depth, d=handle_dia, $fn=32);
}
module hole() {
    translate([(fingers_width + handle_dia)/2, fingers_depth - 1, 0]) rotate([90, 0, 0]) cylinder(h=fingers_depth*2, d=hole_dia, $fn=32);
}
module recess() {
    translate([(fingers_width + handle_dia)/2, fingers_depth + shoulder, 0]) rotate([90, 0, 0]) cylinder(h=fingers_depth*2, d=recess_dia, $fn=32);    
}
module locator() {
    translate([(fingers_width + handle_dia)/2 - hole_dia/2, -fingers_depth + shoulder, -hole_dia/2]) rotate([90, 0, 0]) cube([hole_dia, hole_dia, loc_square_depth]);    
}
module socket() {
    translate([(fingers_width + handle_dia)/2, pillar_socket_height+14, 0]) 
    rotate([90, 0, 0]) { 
        difference() {
            cylinder(h=pillar_socket_height, d=pillar_socket_dia, $fn=32);
            translate([0, 0, -15]) cylinder(h=pillar_socket_height, d=pillar_dia, $fn=32);
            cylinder(h=fingers_depth*2, d=recess_dia, $fn=32);
        }
    }
}
module socket_hole() {
    translate([(fingers_width + handle_dia)/2, pillar_socket_height+14, 0]) 
    rotate([90, 0, 0])  
            translate([0, 0, -15]) cylinder(h=pillar_socket_height, d=pillar_dia, $fn=32);
}
module arm() {
    difference() {
        union() {
            bridge();
            arch();
            leg();
        }
        hole();
        recess();
        //locator();
    }
}
module handle() {
    difference() {
        union() {
            mirror([1, 0, 0]) arm();
            socket();
            difference() {
                arm();
                socket_hole();
            }
        }
        translate([0, 0, (handle_dia + final_thickness)/2]) cube([fingers_width*2, fingers_width*2, handle_dia], center=true);
        translate([0, 0, -(handle_dia + final_thickness)/2]) cube([fingers_width*2, fingers_width*2, handle_dia], center=true);
        translate([-(3*fingers_width/2)-handle_dia+5, 0, 0]) cube([fingers_width*2, fingers_width*2, handle_dia], center=true);
    }
}

translate([0, fingers_depth, 0]) handle();