/*
    Proxymow Mower - offset Omniwheel Bracket using rotating hirth joint
    Print in Black PETG
*/
$fa=1;
$fs=0.4;
cyl_outer_dia = 20;//mm
cyl_hole_dia = 7;//mm
cyl_height = 20;//mm
fixed_cyl_height = 12;//mm
bush_outer_dia = 15;//mm
bush_hole_dia = 5.3;//mm
bush_height = 14;//mm
tooth_tip_radius = 1;//mm
tooth_side = 10;
tooth_height = tooth_side * sqrt(3);
num_teeth = 16;
tooth_radial_angle = 360 / num_teeth;
half_tooth_angle = tooth_radial_angle / 2;
tooth_extension = 1.5;
moving_arm_thickness = 4;
fixed_arm_length = 50;
fixed_arm_dim = 10;
fix_hole_dia = 4.6;//mm
omniwheel_wheel_dia = 29;
omniwheel_pitch_dia = 68;//designed on 70mm, but tilted wheel foreshortens
omniwheel_hub_thickness = 10;
omniwheel_clearance = 8;
moving_axle_joint_centres = ((omniwheel_pitch_dia + omniwheel_wheel_dia) / 2) + omniwheel_clearance + (cyl_outer_dia/2);
echo("moving_axle_joint_centres", moving_axle_joint_centres);

recess_depth = 4.8;

//Omniwheel wheel clearance
hub_offset = -moving_axle_joint_centres;
wheel_offset = hub_offset + (omniwheel_pitch_dia/2);
echo("wheel_offset", wheel_offset);

module oob_assembly(mode) {
    
    //mode = "lh-assembly" | "rh-assembly" | "assembly" | "print1" | "print2" | "inner" | "outer"

    echo("minimum elbow angle: ", 360 / (2 * num_teeth));
    echo("half_tooth_angle", half_tooth_angle);
    echo("required bolt length: ", (cyl_height * 2) + (fixed_cyl_height * 1.5) + 10);
    module tooth() {
        translate([0,0,0]) rotate([90, 0, 0]) hull() {
            cylinder(cyl_outer_dia, r=tooth_tip_radius, center = true);
            translate([-tooth_side,tooth_height,0]) cylinder(cyl_outer_dia, r=tooth_tip_radius/10, center = true);
            translate([tooth_side,tooth_height,0]) cylinder(cyl_outer_dia, r=tooth_tip_radius/10, center = true);
        }
    }

    module hirth(cyl_height, cyl_outer_dia, cyl_hole_dia, num_teeth, radial_offset=0) {
        translate([0,0,0]) 
            difference() {
                //core cylinder
                translate([0,0,-cyl_height]) cylinder(cyl_height + tooth_extension, d=cyl_outer_dia);
            
                //bolt hole
                translate([0,0,-cyl_height]) cylinder(cyl_height+tooth_extension, d=cyl_hole_dia);
            
                //teeth
                for(i=[0:num_teeth]) {
                    rotate([0,0,(i*tooth_radial_angle) + radial_offset]) tooth();             
                }
                //teeth flattener
                translate([0,0,tooth_extension / 2]) cylinder(tooth_tip_radius * 2, d=cyl_outer_dia+1);        
        }
    }

    module fixed() {
        //fixed bracket
        color("purple") difference() {
            union() {
                //joint 1
                hirth(fixed_cyl_height, cyl_outer_dia, cyl_hole_dia, num_teeth);
                //arm
                translate([-fixed_arm_dim+(cyl_outer_dia/2), -fixed_arm_length/2, -fixed_cyl_height]) cube([fixed_arm_dim, fixed_arm_length, fixed_arm_dim], center=false);
            }
            //fixing holes
            hole_centres = fixed_arm_length - fixed_arm_dim;
            echo("fixed bracket hole centres: ", hole_centres);
            translate([-cyl_outer_dia/3, hole_centres/2, -fixed_cyl_height+fixed_arm_dim/2]) rotate([0,90,0]) cylinder(cyl_outer_dia, d=fix_hole_dia);
            translate([-cyl_outer_dia/3, -hole_centres/2, -fixed_cyl_height+fixed_arm_dim/2]) rotate([0,90,0]) cylinder(cyl_outer_dia, d=fix_hole_dia);
            //centre hole
            translate([0, 0, -fixed_cyl_height-1]) cylinder(h=fixed_cyl_height*2, d=cyl_hole_dia, center=false);
        }
    }

    module outer(cyl_height, bush_height, moving_arm_thickness, radial_offset=0) {
        arm_length = moving_axle_joint_centres + omniwheel_clearance - 12;
        color("cyan") difference() {
            union() {
                //joint
                /*
                    module hirth(cyl_height, cyl_outer_dia, cyl_hole_dia, num_teeth, radial_offset=0)
                */
                hirth(cyl_height, cyl_outer_dia, cyl_hole_dia, num_teeth, radial_offset);
                //arm
                translate([-bush_outer_dia/2, bush_outer_dia/4, -cyl_height]) cube([bush_outer_dia, arm_length, moving_arm_thickness], center=false);            
                //bush
                translate([0, moving_axle_joint_centres, -cyl_height]) cylinder(bush_height, d=bush_outer_dia, center=false);
            }
            //bolt hole
            translate([0,0,-cyl_height-1]) cylinder(h=cyl_height, d=cyl_hole_dia);
            //bush axle hole
            translate([0,moving_axle_joint_centres,-cyl_height-1]) cylinder(bush_height+2, d=bush_hole_dia, center=false);
            //square hole
            translate([0,0,-cyl_height]) cube([cyl_hole_dia, cyl_hole_dia, recess_depth+1], center=true); 
        }

    }
    module middle(cyl_height, bush_height, moving_arm_thickness, radial_offset) {
        color("blue") mirror([0,0,1]) outer(cyl_height, bush_height, moving_arm_thickness, radial_offset);
    }
    module inner(cyl_height, bush_height, moving_arm_thickness) {
        color("yellow") outer(cyl_height, bush_height, moving_arm_thickness);
    }

    //assembly
    module moving_arm(gap=0) {
        translate([0, 0, -gap]) outer(cyl_height + moving_arm_thickness/2, bush_height + moving_arm_thickness/2, moving_arm_thickness);//cyan
        translate([0, 0, gap]) middle(cyl_height, bush_height, moving_arm_thickness/2, half_tooth_angle);//blue
        translate([0, 0, cyl_height + fixed_cyl_height/2 + gap]) inner(fixed_cyl_height/2, moving_arm_thickness/2, moving_arm_thickness/2);//yellow
    }

    if (mode == "lh-assembly") {
        //Left Handed
        rotate([0, 90, 180]) union() {
            translate([0, 0, fixed_cyl_height/2 + cyl_height]) rotate([0, 180, 0]) fixed();
            translate([0, 0, 0]) rotate([0, 0, -33.75]) moving_arm();
        }
    } else if (mode == "rh-assembly") {
        //Right Handed
        rotate([0, 90, 180]) union() {
            translate([0, 0, fixed_cyl_height/2 + cyl_height])  rotate([0, 180, 0]) fixed();
            translate([0, 0, 0])  rotate([0,0,180 + 33.75]) moving_arm();        
        }
    } else if (mode == "assembly") {
        //Left Handed
        rotate([0, 90, 180]) union() {
            translate([0, 30, 30]) rotate([0, 180, 0]) fixed();
            translate([0, 30, 0]) rotate([0, 0, -half_tooth_angle]) moving_arm();
            
            //Omniwheel Sub-wheel
            color("red") translate([0, 30-wheel_offset, 0]) rotate([0,90,0]) cylinder(7, d=omniwheel_wheel_dia, center=true);

            //Omniwheel hub clearance
            color("red") translate([0, 30,0]) rotate([0,0,-half_tooth_angle]) translate([0, -hub_offset, 0]) cylinder(omniwheel_hub_thickness, d=20, center=true);
        }    
        //Right Handed
        rotate([0, 90, 180]) union() {
            translate([0, -30, 30])  rotate([0, 180, 0]) fixed();
            translate([0, -30, 0])  rotate([0,0,180 + half_tooth_angle]) moving_arm();

            //Omniwheel Sub-wheel
            color("red") translate([0, -30+wheel_offset,0]) rotate([0,90,0]) cylinder(7, d=omniwheel_wheel_dia, center=true);
            
            //Omniwheel hub clearance
            color("red") translate([0, -30,0]) rotate([0,0,half_tooth_angle]) translate([0, hub_offset,0]) cylinder(omniwheel_hub_thickness, d=20, center=true);
        }
    } else if (mode == "print1") {
        //with bushes
        union() {
            translate([0, fixed_arm_length/2, fixed_cyl_height]) fixed();
            translate([cyl_outer_dia + 1, 0, fixed_cyl_height/2]) inner(fixed_cyl_height/2, moving_arm_thickness/2, moving_arm_thickness/2);
            translate([0, -cyl_outer_dia/2 - 1, cyl_height]) rotate([0, 180, 180]) middle(cyl_height, bush_height, moving_arm_thickness/2, half_tooth_angle);
            translate([cyl_outer_dia + 1, -cyl_outer_dia - 1, cyl_height]) rotate([0, 0, 180]) outer(cyl_height, bush_height, moving_arm_thickness);
        }
    } else if (mode == "print2") {
        //bushless
        union() {
            translate([0, 0, fixed_cyl_height]) fixed();
            translate([cyl_outer_dia + 1, 0, fixed_cyl_height/2]) inner(fixed_cyl_height/2, moving_arm_thickness/2, moving_arm_thickness/2);
            translate([2 * cyl_outer_dia + 2, 0, cyl_height]) rotate([0, 180, 0]) middle(cyl_height, 0, moving_arm_thickness/2, half_tooth_angle);
            translate([3 * cyl_outer_dia + 3, 0, cyl_height]) rotate([0, 0, 0]) outer(cyl_height, moving_arm_thickness, moving_arm_thickness);
        }
    } else if (mode == "inner") {
        translate([0, fixed_arm_length/2, fixed_cyl_height]) fixed();
    } else if (mode == "outer") {
        union() {
            translate([cyl_outer_dia + 1, 0, fixed_cyl_height/2]) inner(fixed_cyl_height/2, moving_arm_thickness/2, moving_arm_thickness/2);
            translate([0, -cyl_outer_dia/2 - 1, cyl_height]) rotate([0, 180, 180]) middle(cyl_height, bush_height, moving_arm_thickness/2, half_tooth_angle);
            translate([cyl_outer_dia + 1, -cyl_outer_dia - 1, cyl_height]) rotate([0, 0, 180]) outer(cyl_height, bush_height, moving_arm_thickness);
        }
    }
}

oob_assembly("print1"); // lh-assembly | rh-assembly | assembly | print1 | print2 | inner | outer