include <../shared/Constants.scad>
//Idle Wheel

module ring(outer_dia, thickness, radius) {
    rotate_extrude($fn=64) {
        translate([(outer_dia/2) - radius, 0]) {
            hull() {
                translate([0, (thickness/2) - radius]) circle(r=radius, $fn=32);
                translate([0, -(thickness/2) + radius]) circle(r=radius, $fn=32);
            }
        }    
    }
}
module dee_shaft(hgt, dia, offset) {
    difference() {
        cylinder(h=hgt, d=dia, center=true, $fn=32);
        translate([0, dia - offset, 0]) cube([dia, dia, hgt+0.1], center=true);
    }
}
module idle_wheel() {
    translate([0, 0, -(runner_thickness + tooth_space_thickness)/2]) difference() {
        union() {
            hull() ring(idle_wheel_dia, runner_thickness, edge_radius);
            translate([0, 0, (runner_thickness+tooth_space_thickness)/2]) cylinder(h=tooth_space_thickness, d=tooth_space_dia, $fn=32, center=true);
            translate([0, 0, runner_thickness + tooth_space_thickness]) hull() ring(idle_wheel_dia, runner_thickness, edge_radius);
        }
        //D shaft hole
        dee_shaft(50, idle_shaft_dia, dee_shaft_offset);
    }
}
module splitter_cube(split_level, height) {
    cube_dim = 60;
    translate([0, 0, -height*split_level]) cube([cube_dim, cube_dim, height], center=true);
}
module split_idle_wheel(lower=true) {
    tot_thickness = (runner_thickness * 2) + tooth_space_thickness;
    lower_split_level = 0.5;
    upper_split_level = 1 - lower_split_level;
    spigot_height = tot_thickness/4;
    spigot_dia = idle_wheel_dia/2;
    scaled_spigot_dia = spigot_dia*spigot_scale_factor;
    echo("scaled_spigot_dia:", scaled_spigot_dia);
    if (lower) {
        translate([0, 0, tot_thickness/2]) union() {
            intersection() {
                idle_wheel();
                splitter_cube(lower_split_level, tot_thickness);
            }
            difference() {
                translate([0, 0, ((tot_thickness+spigot_height)/2) - (tot_thickness*lower_split_level)]) cylinder(h=spigot_height, d=spigot_dia, $fn=32, center=true);
                cylinder(h=tot_thickness * 2, d=idle_shaft_dia, center=true, $fn=32);
            }
        }
    } else {
        translate([0, 0, tot_thickness/2]) mirror([0, 0, 1]) difference() {
            idle_wheel();
            //enlarged deepened spigot recess
            translate([0, 0, (((tot_thickness+spigot_height+1)/2) + 0.0) - (tot_thickness*lower_split_level)]) cylinder(h=spigot_height+2, d=scaled_spigot_dia, $fn=32, center=true);
            splitter_cube(lower_split_level, tot_thickness);
        }
    }
}

//Assembled Wheel
*idle_wheel();

//Split parts for printing
split_idle_wheel();
translate([52, 0, 0]) split_idle_wheel(lower=false);
