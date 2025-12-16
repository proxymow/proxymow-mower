/*
    Proxymow Mower - 230mm Space Shuttle Target
    2-part design to fit print Ender-3 print bed
    Slice with Top Layers = 0 and gyroid infill to expose texture
    Print in White Filament
*/
target_width = 148;   //mm
target_length = 230;  //mm
target_radius = 20;  //mm
half_target_width = target_width / 2;
half_target_length = target_length / 2;
thickness = 3;// mm
split_ratio = 0.5;
peg_dim = 10;
peg_depth = thickness / 2;
clearance = 0.2; // mm
peg_hole = peg_dim + (clearance * 2);//clearance each side
scale_factor = 1.1;
echo("scale_factor", scale_factor);

//Math
//leg length from simple geometry
leg_length = sqrt((half_target_width * half_target_width) + (target_length * target_length));

function midpoint(start_x, start_y, finish_x, finish_y) = 
    [(start_x + finish_x)/2, (start_y + finish_y)/2];

function get_point_adistance_along_line(start_x, start_y, finish_x, finish_y, d) =
  let (x_length = finish_x - start_x)
  let (y_length = finish_y - start_y)
  let (line_length = sqrt(x_length^2 + y_length^2))
  let (ratio = d / line_length)
  let (new_x = start_x + (x_length * ratio))
  let (new_y = start_y + (y_length * ratio))
  
  [new_x, new_y];

module shuttle() {
    v1_x = 0;
    v1_y = half_target_length;
    v2_x = -half_target_width;
    v2_y = -half_target_length;
    v3_x = half_target_width;
    v3_y = -half_target_length;
    v12 = get_point_adistance_along_line(v1_x, v1_y, v2_x, v2_y, target_radius);
    v21 = get_point_adistance_along_line(v2_x, v2_y, v1_x, v1_y, target_radius);
    v13 = get_point_adistance_along_line(v1_x, v1_y, v3_x, v3_y, target_radius);
    v31 = get_point_adistance_along_line(v3_x, v3_y, v1_x, v1_y, target_radius);
    v23 = get_point_adistance_along_line(v2_x, v2_y, v3_x, v3_y, target_radius);
    v32 = get_point_adistance_along_line(v3_x, v3_y, v2_x, v2_y, target_radius);
    v12m = midpoint(v13[0], v13[1], v23[0], v23[1]);
    v23m = midpoint(v31[0], v31[1], v21[0], v21[1]);
    v31m = midpoint(v32[0], v32[1], v12[0], v12[1]);
    linear_extrude(height=thickness, center=false) polygon(
        [
            v12,
            v12m,
            v21,
            v23,
            v23m,
            v32,
            v31,
            v31m,
            v13
        ]
    );
}

module mycut() {
    translate([-target_width/2, -target_length/2, -1]) cube([target_width, 2*target_length/3, thickness + 2]);
}

module tail() {
    intersection() {
        shuttle();
        mycut();
    }
    color("blue") translate([0, target_length/6, peg_depth]) cube([peg_dim, peg_dim, peg_depth], center=true);
}

module tip() {
    difference() {
        shuttle();
        mycut();
        translate([0, target_length/6, peg_depth]) scale(scale_factor) cube([peg_dim, peg_dim, peg_depth], center=true);
    }
}
translate([70, 0, 0]) rotate([0,0,180 + 16]) color("orange") tip();
color("yellow") tail();