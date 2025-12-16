//Drive Sprocket Cog
include <../shared/Constants.scad>
use <../shared/Chamfer-Fillet-Machine.scad>

//module drive_sprocket_cog(outer_dia, tooth_height, tooth_depression) {
module drive_sprocket_cog() {
    difference() {
        union() {
            cylinder(h=sprock_thickness, r=((drive_sprocket_dia/2) - tth_tooth_height), $fn=64);
            for(a=[tth_pitch_angle/2: 360/tth_num_teeth: 360]) {
                //sprocket tooth
                rotate([0, 0, a]) translate([0, (drive_sprocket_dia/2) - (tth_tooth_height*tooth_depression)]) scale([sprock_tooth_x_scale, sprock_tooth_y_scale]) linear_extrude(sprock_thickness) chamfer_fillet_2d(sprock_tooth_profile_pts);    
            }//next tooth
        }//end union
        cylinder(h=30, d=spindle_outer_dia + 0.25, $fn=6, center=true);
    }
}//end module

drive_sprocket_cog();