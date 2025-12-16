/*
    Constants.scad contains all the global constants
*/
use <Tooth Profile.scad>

//idler hub
idle_bearing_od = 16;//mm
idle_bearing_fit_dia = idle_bearing_od * 1.03;//push-in fit for bearing
idle_bearing_thickness = 5.25;//push-in fit
hub_thickness = 15;
hub_dia = 24;
idle_shaft_hole_dia = 6.5;//clearance for 6mm shaft
scraper_fix_hole_dia = 4.5;//mm
idler_width = 25;//mm
idler_dia = 50;//mm
idler_spacing = 0.5;//mm
radial_spacing = 5;//mm
tube_insertion = 25;//mm
tube_outer_dim = 10;//10mm square tube
tube_dim = sqrt(tube_outer_dim^2 + tube_outer_dim^2) * 1.04;
echo("tube_outer_dim:", tube_outer_dim, "tube_dim:", tube_dim);

//idler wheel
idle_wheel_thickness = 25;
idle_wheel_dia = 50;
idle_shaft_dia = 6.25;//mm
tooth_space_thickness = 11;//mm
tooth_space_dia = 35;//mm
runner_thickness = (idle_wheel_thickness - tooth_space_thickness)/2;
edge_radius = 1;
dee_shaft_offset = 1;
spigot_scale_factor = 1.0;//grow spigot hole if necessary for a tight fit

//idler axle
idle_rod_dia = 5.92;//mm tight fit for bearing
idle_rod_length = 25 + (2 * 0.5) + (2 * 15) + (2 * 2);//mm idler width + 2 spacers + 2 hubs + 2 washers
echo("idle_rod_length", idle_rod_length);
idle_rod_cap_length = 2;//mm
idle_rod_clip_width = 1;//mm
idle_rod_clip_dia = 4.5;//mm

//knurled wheel and locknut
//knob parameters
KNOB_DIAM=25;
//screw parameters
SCREWHEAD_FACETOFACE=0;
SCREWHEAD_DEPTH=12;
THRU_HOLE_DIAM=9.5;
//grippy cutouts parameters
NUM_GRIP_CUTOUTS=20;
GRIP_CUTOUT_DIAM=4;
CUTOUT_RADIUS_ADJ=1;
KNURLED_WHEEL_HEIGHT=6;
KNURLED_WHEEL_NUM_TURNS = 3.5;
LOCKNUT_HEIGHT=3;
LOCKNUT_NUM_TURNS = 1.375;

//motor plate
gearbox_collar_hole_dia = 22.2;//mm
motor_plate_thickness = 4;//mm
motor_plate_corner_dia = 15;//mm
plan_motor_dia = 36.3;//mm
plan_shoulder_base_thickness = 3;// mm
plan_shoulder_thickness = 5;// mm
plan_shoulder_height = 20;// mm

//planetary motor bracket
pmb_motor_dia = 36;//mm 35.5 plus clearance
pmb_base_thickness = 3;//mm
pmb_foot_thickness = 5;//mm
pmb_width = 10;//mm
pmb_thickness = 4;//mm
pmb_chamfer_radius = 1;//mm
pmb_fix_hole_dia = 4.5;//mm

//bearing backplate
drive_bearing_bush_dia = 24;//mm
drive_bearing_od = 16;//mm
drive_bearing_fit_dia = drive_bearing_od * 1.02;//push fit for bearing
drive_bearing_recess = 6;//mm 

//drive sprocket
sprocket_spacing = 0.5;//mm
tooth_height = 5;//mm 4 + 1 to sink into cylinder

//tube clamp
clamp_width = 10;//mm
clamp_effect = 0.75;//mm
clamp_int_dia = 0.5;//mm
clamp_ext_dia = 2.5;//mm
clamp_fix_hole_dia = 4.8;//mm
clamp_washer_dia = 13;// for 12.5mm washer
clamp_washer_thickness = 1;//mm

//drive spindle
plan_motor_drive_shaft_dia = 8;//mm
spindle_outer_dia = 20;//mm fn=6 for hex
spindle_length = 25;//mm
spindle_shoulder_dia = 30;//mm
spindle_shoulder_width = 10;//mm
drive_sprocket_shaft_hole_dia = 8.32;//for 8mm shaft
spindle_dee_shaft_offset = 1;//mm
spindle_dee_shaft_dia = plan_motor_drive_shaft_dia * 1.0175;//mm interference fit
spindle_drive_shaft_length = 25;//mm shaft is 17.5 only 14mm of which is D'eed
spindle_bearing_shaft_dia = 9.3;//space for M8 thread
spindle_thread_num_turns = 9;
spindle_thread_x_factor = 1.04;
spindle_thread_y_factor = 1.04;
spindle_thread_z_factor = 1.0;

//drive sprocket shaft
drive_sprocket_shaft_num_turns = 14;
bearing_section_length = 10;//mm
back_bearing_stub_dia = 7.95;//mm for 8mm hole in bearing

//drive sprocket cog
tth_num_teeth = 9;
tth_pitch_angle = 360 / tth_num_teeth;
drive_sprocket_dia = 50;
tooth_depression = 1.1;//to smooth base fillets
sprock_tooth_x_scale = 0.8;//put space between teeth
sprock_tooth_y_scale = 1.05;//
sprock_thickness = 11;//mm for a 7|11|7 sandwich
tth_sprock_press_angle = 5;
tth_tooth_pitch = 8;
tth_root_fillet_radius = 1;
tth_tooth_height = 5;
sprock_tooth_profile_pts = tooth_points(tth_sprock_press_angle, tth_tooth_pitch, tth_root_fillet_radius, tth_tooth_height);

//drive plain cog
plain_cog_dia = 50;
plain_cog_thickness = 7;
plain_cog_rim_thickness = 3;//mm

//just for assembly
wheelbase = 200;//mm horizontal distance between idle wheel centres
track_triangle_height = 60;//mm vertical distance between drive motor and tube centres