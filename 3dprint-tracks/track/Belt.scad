use <Belt Profile.scad>
use <../shared/Chamfer-Fillet-Machine.scad>
use <../shared/Tooth Profile.scad>

//belt
sprock_pitch = 15.708;
stretch_factor = 1.0;
track_pitch = sprock_pitch / stretch_factor;
echo("Track Pitch:", track_pitch);
num_links = 37;
delta_angle = 360 / num_links;
belt_inradius = track_pitch / (2 * tan(180 / num_links));
belt_indiameter = belt_inradius * 2;
belt_incircumference = PI * 2 * belt_inradius;
echo("inradius", belt_inradius, "indiameter: ", belt_indiameter, "incircumference", belt_incircumference);
track_thickness = 4;//mm
track_width = 40;//mm

outer_tread_base_width = 4;
outer_tread_head_width = 3;
outer_tread_height = 0.5;
inner_tread_base_width = 4;
inner_tread_head_width = 2;
inner_tread_height = 2.0;//fmly 1.5

//define the belt tooth properties
tth_belt_press_angle = 15;
tth_tooth_pitch = 8;
tth_root_fillet_radius = 1;
tth_tooth_height = 5;

//7 | 11 | 7 may be ok as well – with a 9mm tooth
tth_tooth_width = 9;//mm

//get profile points from function
belt_tooth_profile_pts = tooth_points(tth_belt_press_angle, tth_tooth_pitch, tth_root_fillet_radius, tth_tooth_height);
echo("belt_tooth_profile_pts: ", belt_tooth_profile_pts);

module outer_trap() {
    polygon([
        [-outer_tread_base_width, 0],
        [-outer_tread_head_width, outer_tread_height],
        [outer_tread_head_width, outer_tread_height],
        [outer_tread_base_width, 0]
    ]);
}
module inner_trap() {
    polygon([
        [-inner_tread_base_width, 0],
        [-inner_tread_head_width, inner_tread_height],
        [inner_tread_head_width, inner_tread_height],
        [inner_tread_base_width, 0]
    ]);
}

module wedge() {
    hull() {
        translate([0, 0, -6*track_width/16]) linear_extrude(1) outer_trap();
        translate([0, 0, -3*track_width/16]) linear_extrude(1) inner_trap();
    }
}
module tread() {
    hull() {
        wedge();
        mirror([0, 0, 1]) wedge();
    }
}

module belt(link_count, incl_tread=false, incl_teeth=true) {

    difference() {
        union() {
            //belt profile
            rotate([0, 0, 90]) rotate_extrude(angle=360*link_count/num_links, $fn=128) translate([belt_inradius, 0, 0]) full_profile();
            if (incl_tread) {
                for(n=[0:link_count-1]) {
                    //tread
                    rotate([0, 0, delta_angle * n]) translate([0, belt_inradius + track_thickness - 0.25, 0]) tread();
                }
            }
            if (incl_teeth) {
                for(n=[0:link_count-1]) {
                    //tooth straight-sided 2d
                    rotate([0, 0, delta_angle * n]) translate([0, belt_inradius, -tth_tooth_width/2]) rotate([0, 0, 180]) linear_extrude(, tth_tooth_width) chamfer_fillet_2d(belt_tooth_profile_pts);
                }
            }
        }
    }
}
//Print in TPU 15% Infill Honeycomb (if available) or cubic/grid/triangles. Tree Support for teeth.
belt(num_links, incl_tread=true);