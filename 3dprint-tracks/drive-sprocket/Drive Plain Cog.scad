include <../shared/Constants.scad>
use <../shared/Chamfer-Fillet-Machine.scad>
use <../shared/Tooth Profile.scad>

module drive_plain_cog(spoked=false) {
    difference() {
        cylinder(h=plain_cog_thickness, r=spoked?(plain_cog_dia/3): (plain_cog_dia/2) - tth_root_fillet_radius, $fn=64, center=true);
        cylinder(h=30, d=spindle_outer_dia + 0.25, $fn=6, center=true);
    }
    if (spoked) for(a=[tth_pitch_angle/2: 360/tth_num_teeth: 360]) {
        rotate([0, 0, a]) translate([plain_cog_dia/2.75, 0, 0]) cube([plain_cog_dia/4, 2, plain_cog_thickness - 0.5], center=true); 
    }
    difference() {
        hull() {
            translate([0, 0, (plain_cog_thickness/2) - tth_root_fillet_radius]) rotate_extrude($fn=64) {
                translate([(plain_cog_dia/2) - tth_root_fillet_radius,0]) circle(r=tth_root_fillet_radius, $fn=32);
            }    
            translate([0, 0, -(plain_cog_thickness/2) + tth_root_fillet_radius]) rotate_extrude($fn=64) {
                translate([(plain_cog_dia/2) - tth_root_fillet_radius,0]) circle(r=tth_root_fillet_radius, $fn=32);
            }
        } 
        cylinder(h=30, d=plain_cog_dia - plain_cog_rim_thickness, $fn=32, center=true);
    }//end diff
}//end module

*drive_plain_cog(spoked=true);
drive_plain_cog();