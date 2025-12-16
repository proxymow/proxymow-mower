/* 
    electronic modules chassis
    
*/

//variables for the chassis
plat_width=140;//mm
plat_length=100;//mm
plat_thickness=2.5;//mm
peg_pitch=25;//mm
rail_slot_vgap=1.5 + 0.3;//mm
rail_length=40;//mm
hinge_dia=10;//mm
hinge_hole_dia=5.3;//mm
hinge_y_offset=24;//mm
hinge_height = 25;//mm
antenna_wall_extent=89;//mm
antenna_wall_socket_length = 54;//mm
antenna_wall_socket_slot_length=48;//mm

connector_wall_extent=79;//mm
connector_wall_socket_length = 70;//mm
connector_wall_socket_slot_length=60;//mm

wall_socket_width=6;//mm
wall_socket_height = 8;//mm
wall_socket_slot_width=2.25;//mm
wall_socket_slot_depth=6;//mm

east_west_western_peg_holes=[
    [18.7, 4.3], //1
    [18.7, 30.0],//2    30 - 4.3 = 25.7 pitch, 22.1 board
    [18.7, 71.6],//3    71.6 - 30 = 41.6 pitch, 38.0 board
    [18.7, 95.2] //4    95.2 - 71.6 = 23.6 pitch, 20.0 board
];
north_south_southern_peg_holes=[
    [60.4, 18.7],   //5  
    [102, 18.7],    //6  102 - 60.4 = 41.6 pitch, 38.0 board
    [135.3, 18.7],  //7  135.3 - 102 = 33.3 pitch, 29.7 board
    [56.7, 62.5],   //8 
    [135.3, 62.5],  //9  135.3 - 56.7 = 78.6 pitch, 75.0 board
];


base_major_thickness = 2;//mm
base_minor_thickness = 1;//mm
outer_frame_width = 150;//mm
frame_width = outer_frame_width - (base_major_thickness/2);//mm
peg_length = 2.5;//mm
base_width = 50;//mm

wall_corner_dia = 10;//mm
wall_thickness = 2;//mm
wall_plug_depth = 6;//mm
wall_hinge_offset = 24;//mm

antenna_wall_north_base_width = 24;//mm
antenna_wall_south_base_width = 24;//mm
antenna_wall_north_top_width = 0;//mm
antenna_wall_south_top_width = 24;//mm
antenna_wall_height = 25;//mm

connector_wall_north_base_width = 25;//mm
connector_wall_south_base_width = 25;//mm
connector_wall_north_top_width = 40;//mm
connector_wall_south_top_width = 40;//mm
connector_wall_height = 47;//mm

toggle_hole_dia = 12.5;//mm
toggle_spacing = 50;//mm

antenna_hole_dia = 6.8;//mm
antenna_hole_offset = 15;//mm
led_hole_dia = 3.5;//mm
led_hole_offset = 30;

//variables for the assembled model
box_inner_width = 170;//mm
box_inner_length = 70;//mm
box_inner_depth = 55;//mm
term_block_num_terms = 12;
term_block_pitch = 8.2;//mm
term_block_hole_dia = 2.75;//mm
terminal_dim = 6;//mm
terminal_length = 16;//mm

//supplementary components
module lid() {
    difference() {
        cube([200, 120, 15], center=true);
        translate([0, 0, 5]) cube([190, 72, 10], center=true);
        translate([0, 0, 5]) cube([170, 110, 10], center=true);
    }
}
module box() {
    translate([0, 0, 69.6/2]) difference() {
        cube([199-28, 110, 69.6], center=true);
    }
}
module terminal(term_dim, term_length) {
    difference() {
        union() {
            //body
            cube([term_dim, term_length, term_dim], center=true);
            //screws
            translate([0, term_dim/2, term_dim/2]) cylinder(h=term_dim/2, d=term_dim/2, $fn=32, center=true);
            translate([0, -term_dim/2, term_dim/2]) cylinder(h=term_dim/2, d=term_dim/2, $fn=32, center=true);
        }
        //cable hole
        rotate([90, 0, 0]) cylinder(h=term_length*2, d=term_dim/2, $fn=32, center=true);

    }    
}
module bridge(term_width, term_length, hole_dia) {
    difference() {
        cube([term_width/2, term_width, term_width], center=true);
        //fixing hole
        rotate([0, 0, 90]) cylinder(h=term_length*2, d=hole_dia, $fn=32, center=true);
    }
}
module terminal_block(num_terms=12, pitch=8, term_dim=6, term_length=16, term_fix_hole_dia=2.75) {
    translate([-(pitch * num_terms/2) + pitch/2, 0, 0]) {
        for (t=[0:1:num_terms-1]) {
            translate([t * pitch, 0, 0]) terminal(term_dim, term_length);
        }
        for (t=[0:1:num_terms-2]) {
            translate([(pitch/2) + t * pitch, 0, 0]) bridge(term_dim, term_length, term_fix_hole_dia);
        }
    }
}
module spindle() {
    rotate([0, 90, 0]) cylinder(h=190, d=4, $fn=32, center=true);
}
//main components
module rail(slot_vgap, peg_length, peg_pitch, length) {
    rail_dim = 3 * slot_vgap;//rail | gap | rail
    difference() {
        cube([rail_dim, length, rail_dim], center=true);
        translate([0, 0, slot_vgap]) {
            rotate([90, 0, 0]) cylinder(h=length + 0.1, d=slot_vgap, $fn=32, center=true);
            translate([0, 0, slot_vgap/2]) cube([slot_vgap, length + 0.1, slot_vgap], center=true);
            //lead-in
            translate([0, -length/2, 0]) rotate([90, 0, 0]) cylinder(h=5, d1=slot_vgap, d2=slot_vgap*2, $fn=32, center=true);
            translate([0, length/2, 0]) rotate([90, 0, 0]) cylinder(h=5, d2=slot_vgap, d1=slot_vgap*2, $fn=32, center=true);
        }
        translate([0, 0, -slot_vgap]) {
            rotate([90, 0, 0]) cylinder(h=length + 0.1, d=slot_vgap, $fn=32, center=true);
            translate([0, 0, -slot_vgap/2]) cube([slot_vgap, length + 0.1, slot_vgap], center=true);
            //lead-in
            translate([0, -length/2, 0]) rotate([90, 0, 0]) cylinder(h=5, d1=slot_vgap, d2=slot_vgap*2, $fn=32, center=true);
            translate([0, length/2, 0]) rotate([90, 0, 0]) cylinder(h=5, d2=slot_vgap, d1=slot_vgap*2, $fn=32, center=true);
        }
    }
    //pegs
    translate([(rail_dim + peg_length)/2, peg_pitch/2, 0]) rotate([0, 90, 0]) cylinder(h=peg_length, d=rail_dim, $fn=4, center=true);
    translate([(rail_dim + peg_length)/2, -peg_pitch/2, 0]) rotate([0, 90, 0]) cylinder(h=peg_length, d=rail_dim, $fn=4, center=true);
}
module platform(
    width, 
    length, 
    thickness, 
    east_west_western_peg_holes, 
    north_south_southern_peg_holes, 
    peg_pitch, 
    slot_vgap, 
    rail_length, 
    hinge_dia, 
    hinge_hole_dia, 
    hinge_y_offset, 
    ant_extent, 
    conn_extent, 
    socket_width
    ) {
    rail_dim = 3 * slot_vgap;//rail | gap | rail
    rail_dim_clearance = rail_dim + 0.325;
    peg_hole_dia = rail_dim_clearance;
    
    difference() {
        union() {
            //platform
            cube([width, length, thickness], center=true);
            //antenna hinge
            translate([-ant_extent/2, hinge_y_offset, -(hinge_hole_dia + thickness)/2]) rotate([0, 90, 0]) cylinder(h=ant_extent + (socket_width/2), d=hinge_dia, $fn=32, center=true);
            translate([-ant_extent/2, hinge_y_offset, -thickness]) cube([ant_extent + (socket_width/2), hinge_dia, thickness], center=true);
            translate([-width/2, hinge_y_offset - (hinge_dia/2), -thickness/2])  mirror([1,0,0]) cube([ant_extent + (socket_width/4) - (width/2), hinge_dia, thickness], center=false);
            //connector hinge
            translate([conn_extent/2, hinge_y_offset, -(hinge_hole_dia + thickness)/2]) rotate([0, 90, 0]) cylinder(h=conn_extent + (socket_width/2), d=hinge_dia, $fn=32, center=true);
            translate([conn_extent/2, hinge_y_offset, -thickness]) cube([conn_extent + (socket_width/2), hinge_dia, thickness + (hinge_hole_dia/2)], center=true);
            translate([width/2, hinge_y_offset - (hinge_dia/2), -thickness/2]) cube([conn_extent + (socket_width/4) - (width/2), hinge_dia, thickness], center=false);
        }
        //hinge holes
        translate([width/2, hinge_y_offset, -(hinge_hole_dia + thickness)/2]) rotate([0, 90, 0]) cylinder(h=width/4, d=hinge_hole_dia, $fn=32, center=true);
        translate([-conn_extent, hinge_y_offset, -(hinge_hole_dia + thickness)/2]) rotate([0, 90, 0]) cylinder(h=width/4, d=hinge_hole_dia, $fn=32, center=true);
        //peg holes
        translate([-width/2, -length/2,0]) {
            //east-west peg holes
            for (p = [ 0 : len(east_west_western_peg_holes) - 1 ]) 
            {
                west_pt=east_west_western_peg_holes[p];
                translate(west_pt) {
                    //hole
                    cylinder(h=thickness+0.1, d=peg_hole_dia, $fn=4, center=true);
                    //lead-in
                    translate([0, 0, thickness/2]) cylinder(h=thickness/2, d1=peg_hole_dia, d2=peg_hole_dia * 1.5, $fn=4, center=true);
                    //hole
                    translate([peg_pitch, 0, 0]) cylinder(h=thickness+0.1, d=peg_hole_dia, $fn=4, center=true);
                    //lead-in
                    translate([peg_pitch, 0, thickness/2]) cylinder(h=thickness/2, d1=peg_hole_dia, d2=peg_hole_dia * 1.5, $fn=4, center=true);
                    *translate([peg_pitch/2, 0, (thickness - 0.5 + 0.1)/2]) cube([rail_length + 0.5, rail_dim, 0.5], center=true);
                    *translate([peg_pitch/2, rail_dim, (thickness - rail_sink + 0.1)/2]) text(str(p + 1), size=10, halign="center", valign="bottom");
                }
            }
            //north-south peg holes
            for (q = [ 0 : len(north_south_southern_peg_holes) - 1 ]) 
            {
                south_pt=north_south_southern_peg_holes[q];
                translate(south_pt) {
                    //hole
                    cylinder(h=thickness+0.1, d=peg_hole_dia, $fn=4, center=true);
                    //lead-in
                    translate([0, 0, thickness/2]) cylinder(h=thickness/2, d1=peg_hole_dia, d2=peg_hole_dia * 1.5, $fn=4, center=true);
                    //hole
                    translate([0, peg_pitch, 0]) cylinder(h=thickness+0.1, d=peg_hole_dia, $fn=4, center=true);
                    //lead-in
                    translate([0, peg_pitch, thickness/2]) cylinder(h=thickness/2, d1=peg_hole_dia, d2=peg_hole_dia * 1.5, $fn=4, center=true);
                    *translate([0, peg_pitch/2, (thickness - 0.5 + 0.1)/2]) cube([rail_dim, rail_length + 0.5, 0.5], center=true);
                    *translate([rail_dim, peg_pitch/2, (thickness - rail_sink + 0.1)/2]) text(str(len(east_west_eastern_peg_holes) + q + 1), size=10, halign="center", valign="center");
                }
            }
        }
    }
}
module wall(
    north_base_width, 
    south_base_width,
    north_top_width, 
    south_top_width, 
    height, 
    corner_dia,
    thickness, 
    plug_depth,
    hinge_height,
    hinge_offset
) {
    width = north_base_width + south_base_width;
    translate([0, corner_dia/2, 0]) {
        difference() {
            hull() {
                //north base
                translate([north_base_width, 0, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
                //south base
                translate([-south_base_width, 0, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
                //north top
                translate([north_top_width, height, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
                //south top
                translate([-south_top_width, height, 0]) cylinder(h=thickness, d=corner_dia, $fn=32, center=true);
            }
            //hinge hole
            translate([-hinge_offset, hinge_height, 0]) cylinder(h=thickness*2, d=5.3, $fn=32, center=true);
        }
   }
    //overlapping plug
    translate([(width/2)-south_base_width, 0, thickness/2]) cube([width, plug_depth*2, thickness], center=true);
}
module antenna_wall(
    north_base_width,
    south_base_width,
    north_top_width,
    south_top_width,
    height,
    corner_dia, 
    thickness,
    plug_depth,
    hinge_height,
    hinge_offset
) {
    difference() {
        wall(
            north_base_width, 
            south_base_width,
            north_top_width, 
            south_top_width, 
            height,
            corner_dia,
            thickness, 
            plug_depth,
            hinge_height,
            hinge_offset
        );
        //led hole
        translate([0, led_hole_offset, 0]) cylinder(h=thickness*2, d=led_hole_dia, $fn=32, center=true);
        //antenna hole
        translate([0, antenna_hole_offset, 0]) cylinder(h=thickness*2, d=antenna_hole_dia, $fn=32, center=true);
    }
}
module holes(term_dim) {
    //centered terminal block peg holes
    cylinder(h=term_dim, d1=term_block_hole_dia, d2=term_block_hole_dia-0.5, $fn=64, center=true);
    for (t=[0:1:(term_block_num_terms-2)/2]) {
            translate([t * term_block_pitch, 0, 0]) cylinder(h=term_dim, d=term_block_hole_dia, $fn=64, center=true);
            translate([-(t * term_block_pitch), 0, 0]) cylinder(h=term_dim, d=term_block_hole_dia, $fn=64, center=true);
    }
}
module connector_wall(
    north_base_width=32,
    south_base_width=32,
    north_top_width=32,
    south_top_width=32,
    height=25,
    corner_dia=10, 
    thickness=2,
    plug_depth=6,
    hinge_height=25,
    hinge_offset=32
) {
    difference() {
        wall(
            north_base_width, 
            south_base_width,
            north_top_width, 
            south_top_width, 
            height, 
            corner_dia,
            thickness, 
            plug_depth,
            hinge_height,
            hinge_offset
        );
        translate([0, height + corner_dia/2, 0]) holes(terminal_dim);
    }
}
module socket(
    width, 
    length, 
    height, 
    slot_width, 
    slot_length, 
    slot_depth
) {
    difference() {
        hull() {
            translate([0, -length/2, 0]) cylinder(h=height, d=width, $fn=32, center=true);
            translate([0, length/2, 0]) cylinder(h=height, d=width, $fn=32, center=true);
        }
        translate([0, 0, (height - slot_depth + 0.01)/2]) {
            hull() {
                translate([0, -slot_length/2, 0]) cylinder(h=slot_depth, d=slot_width, $fn=32, center=true);
                translate([0, slot_length/2, 0]) cylinder(h=slot_depth, d=slot_width, $fn=32, center=true);
            }
        }
    }
}
module base(ant_extent, conn_extent, base_width, socket_height, socket_width, hinge_height, major_thickness, minor_thickness) {
    difference() {
        union() {
            //antenna
            translate([ant_extent/2, 0, socket_height/2]) cube([ant_extent, base_width, socket_height], center=true);
            //connector
            translate([-conn_extent/2, 0, socket_height/2]) cube([conn_extent, base_width, socket_height], center=true);
            //sockets
            translate([ant_extent + (socket_width/2), 0, socket_height/2]) socket(
                wall_socket_width, 
                antenna_wall_socket_length, 
                wall_socket_height, 
                wall_socket_slot_width, 
                antenna_wall_socket_slot_length, 
                wall_socket_slot_depth
            );
            translate([-(conn_extent + (socket_width/2)), 0, socket_height/2]) socket(
                wall_socket_width, 
                connector_wall_socket_length, 
                wall_socket_height, 
                wall_socket_slot_width, 
                connector_wall_socket_slot_length, 
                wall_socket_slot_depth
            );
        }
        //cutouts
        translate([ant_extent/2, 0, (socket_height + 2.1)/2]) cube([ant_extent, base_width - 10, socket_height - 2], center=true);
        translate([-conn_extent/2, 0, (socket_height + 2.1)/2]) cube([conn_extent, base_width - 10, socket_height - 2], center=true);
        //toggle switches
        cylinder(h=major_thickness*9, d=toggle_hole_dia, $fn=32, center=true);
        translate([toggle_spacing, 0, 0]) cylinder(h=major_thickness*9, d=toggle_hole_dia, $fn=32, center=true);
        translate([-toggle_spacing, 0, 0]) cylinder(h=major_thickness*9, d=toggle_hole_dia, $fn=32, center=true);
        //toggle recesses
        translate([0, 0, (3*major_thickness/4)+0.1]) cylinder(h=major_thickness/2, d=toggle_hole_dia*3, $fn=32, center=true);
        translate([toggle_spacing, 0, (3*major_thickness/4)+0.1]) cylinder(h=major_thickness/2, d=toggle_hole_dia*3, $fn=32, center=true);
        translate([-toggle_spacing, 0, (3*major_thickness/4)+0.1]) cylinder(h=major_thickness/2, d=toggle_hole_dia*3, $fn=32, center=true);
    }
}
module assembly() {
    //antenna wall
    translate([antenna_wall_extent + wall_thickness + (wall_socket_width/2) - (wall_socket_slot_width/2), 0, wall_socket_height]) rotate([90, 0, 270]) antenna_wall(
        antenna_wall_north_base_width,
        antenna_wall_south_base_width,
        antenna_wall_north_top_width,
        antenna_wall_south_top_width,
        antenna_wall_height,
        wall_corner_dia, 
        wall_thickness,
        wall_plug_depth,
        hinge_height,
        wall_hinge_offset
    );
    //connector wall
    translate([-(connector_wall_extent + wall_thickness), 0, wall_socket_height]) rotate([90, 0, 270]) connector_wall(
        connector_wall_north_base_width,
        connector_wall_south_base_width,
        connector_wall_north_top_width,
        connector_wall_south_top_width,
        connector_wall_height,
        wall_corner_dia, 
        wall_thickness,
        wall_plug_depth,
        hinge_height,
        wall_hinge_offset        
    );
    base(
        antenna_wall_extent, 
        connector_wall_extent, 
        base_width, 
        wall_socket_height, 
        wall_socket_width, 
        hinge_height,
        base_major_thickness,
        base_minor_thickness
    );
    color("white") translate([-(connector_wall_extent - wall_thickness), 0, connector_wall_height + (wall_corner_dia/2) + wall_socket_height]) rotate([90, 0, 90]) terminal_block(); 
    translate([0, 24, hinge_height + wall_socket_height + 5]) spindle();
    color("grey", alpha=0.5) translate([10, 0, hinge_height + wall_socket_height + 9]) platform(
        plat_width, 
        plat_length, 
        plat_thickness, 
        east_west_western_peg_holes,
        north_south_southern_peg_holes, 
        peg_pitch, 
        rail_slot_vgap, 
        rail_length, 
        hinge_dia, 
        hinge_hole_dia, 
        hinge_y_offset, 
        antenna_wall_extent, 
        connector_wall_extent, 
        wall_socket_width
    );
    %lid();
    color("white", alpha=0.25) box();
    
    //toggle switches
    translate([0, 0, 16]) cube([25, 35, 32], center=true);
    
}
//complete assembly - uncomment only for visualisation
assembly();

//print configurations - uncomment to generate print files
//walls - print together using support touching buildplate
*antenna_wall(
    antenna_wall_north_base_width,
    antenna_wall_south_base_width,
    antenna_wall_north_top_width,
    antenna_wall_south_top_width,
    antenna_wall_height,
    wall_corner_dia, 
    wall_thickness,
    wall_plug_depth,
    hinge_height,
    wall_hinge_offset
);
*translate([0, -14, 0]) mirror([0, 1, 0]) {
    connector_wall(
        connector_wall_north_base_width,
        connector_wall_south_base_width,
        connector_wall_north_top_width,
        connector_wall_south_top_width,
        connector_wall_height,
        wall_corner_dia, 
        wall_thickness,
        wall_plug_depth,
        hinge_height,
        wall_hinge_offset        
    );
}
//base
*base(
    antenna_wall_extent, 
    connector_wall_extent, 
    base_width, 
    wall_socket_height, 
    wall_socket_width, 
    hinge_height,
    base_major_thickness,
    base_minor_thickness
);

//rail - print in this orientation, no support - 9off
*rail(rail_slot_vgap, peg_length, peg_pitch, rail_length);

//platform - print upside down to avoid support
*rotate([180, 0, 0]) {
    platform(
        plat_width, 
        plat_length, 
        plat_thickness, 
        east_west_western_peg_holes,
        north_south_southern_peg_holes, 
        peg_pitch, 
        rail_slot_vgap, 
        rail_length, 
        hinge_dia, 
        hinge_hole_dia, 
        hinge_y_offset, 
        antenna_wall_extent, 
        connector_wall_extent, 
        wall_socket_width
    );
}