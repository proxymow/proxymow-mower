//tube clamp attaches tubes to plates without impeding tensioning rods
include <../shared/Constants.scad>
module tube_clamp() {
    //reference tube
    //color("silver") cube([20, tube_outer_dim, tube_outer_dim], center=true);

    eff_tube_outer_dim = tube_outer_dim * 1.04;
    echo("tube_outer_dim: ", tube_outer_dim, "eff_tube_outer_dim: ", eff_tube_outer_dim);
    major_dim = (eff_tube_outer_dim + clamp_ext_dia)/2;
    minor_dim = (eff_tube_outer_dim - clamp_int_dia)/2;
    pillar_offset = (eff_tube_outer_dim + clamp_fix_hole_dia + 1)/2;
    rotate([0, 180, 0]) {
        difference() { 
            hull() {
                translate([major_dim - clamp_ext_dia - (clamp_effect/2), major_dim, 0]) cylinder(h=clamp_width, d=clamp_ext_dia, center=true, $fn=32);
                translate([0, -major_dim, 0]) cylinder(h=clamp_width, d=clamp_ext_dia, center=true, $fn=32);
                translate([-major_dim, major_dim, 0]) cylinder(h=clamp_width, d=clamp_ext_dia, center=true, $fn=32);
                translate([-major_dim, -major_dim, 0]) cylinder(h=clamp_width, d=clamp_ext_dia, center=true, $fn=32);
                //pillar
                translate([-clamp_ext_dia/2, pillar_offset, 0]) rotate([0, -90, 0]) cylinder(h=eff_tube_outer_dim + clamp_ext_dia - clamp_effect, d=clamp_width, center=true, $fn=32);
            }
            hull() {
                translate([minor_dim+1, minor_dim, 0]) cylinder(h=clamp_width + 0.1, d=clamp_int_dia, center=true, $fn=32);
                translate([minor_dim, -minor_dim, 0]) cylinder(h=clamp_width + 0.1, d=clamp_int_dia, center=true, $fn=32);
                translate([-minor_dim, minor_dim, 0]) cylinder(h=clamp_width + 0.1, d=clamp_int_dia, center=true, $fn=32);
                translate([-minor_dim, -minor_dim, 0]) cylinder(h=clamp_width + 0.1, d=clamp_int_dia, center=true, $fn=32);
            }
            //fixing hole
            translate([-clamp_ext_dia/2, pillar_offset, 0]) rotate([0, -90, 0]) cylinder(h=eff_tube_outer_dim + clamp_ext_dia + 2, d=clamp_fix_hole_dia, center=true, $fn=32);
            //washer recess
            translate([-((eff_tube_outer_dim/2) - (clamp_washer_thickness/2) + clamp_ext_dia + 0.1), pillar_offset, 0]) rotate([0, -90, 0]) cylinder(h=clamp_washer_thickness, d=clamp_washer_dia, center=true, $fn=32);
        }        
    }
}

tube_clamp();