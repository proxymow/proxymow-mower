include <../shared/Constants.scad>

module profile() {
    hull() {
        translate([pmb_thickness - pmb_chamfer_radius, pmb_width/2 - (1 * pmb_chamfer_radius), 0]) circle(r=pmb_chamfer_radius, $fn=32);
        translate([pmb_thickness - pmb_chamfer_radius, -pmb_width/2 + (1 * pmb_chamfer_radius), 0]) circle(r=pmb_chamfer_radius, $fn=32);
        translate([0, -(pmb_width/2), 0]) square(pmb_chamfer_radius);
        translate([0, (pmb_width/2) - pmb_chamfer_radius, 0]) square(pmb_chamfer_radius);
    }
}

module hoop() {
    rotate_extrude(angle=180, $fn=64) {
        translate([pmb_motor_dia/2, 0, 0]) profile();
    }
}
module leg() {
    translate([pmb_motor_dia/2, 0, 0]) rotate([90, 0, 0]) linear_extrude((pmb_motor_dia/2) + pmb_base_thickness) profile();
}

module pad() {
    translate([pmb_width/2, 0, 0]) rotate([0, 270, 0]) linear_extrude(pmb_width) profile();    
}
module foot() {
    translate([pmb_thickness + ((pmb_motor_dia + pmb_width)/2) - 1.0, -(pmb_motor_dia/2 + pmb_base_thickness), 0]) rotate([0, 90, 90]) difference() {
        union() {
            intersection() {
                pad();
                rotate([0, 0, 90]) pad();
            }
            translate([-pmb_width/2, pmb_thickness-pmb_chamfer_radius, pmb_thickness - pmb_chamfer_radius*2]) cube([pmb_width, pmb_chamfer_radius*2, pmb_chamfer_radius*2]);
        }
        translate([0, 0, pmb_thickness]) cylinder(h=pmb_thickness*3, d=pmb_fix_hole_dia, center=true, $fn=32);
    }
}
module plan_motor_bracket() {
    hoop();
    leg();
    mirror([1, 0, 0]) leg();
    translate([0, -(pmb_motor_dia + pmb_base_thickness)/2, 0]) rotate([90, 0, 90]) cube([pmb_base_thickness, pmb_width, pmb_motor_dia], center=true);
    foot();
    mirror([1, 0, 0]) foot();
}

plan_motor_bracket();