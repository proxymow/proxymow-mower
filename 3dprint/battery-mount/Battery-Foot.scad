/*
    Proxymow Mower - Battery Mount Foot
    Print in Black PETG

    use velcro strap through foot to fix batteries
*/
batt_width = 65;//mm
batt_length = 151;//mm
batt_height = 101;//excluding terminals
batt_term_protrusion = 12;//mm incl connectors
spacer_width = 8;//mm
strap_width = 21;//mm
strap_thickness = 1.2;//mm
foot_depth = 0.35 * batt_length;
echo("foot depth", foot_depth);
foot_height = 6;//mm
foot_offset = 9;//mm
wall_thickness = 4;//mm
cap_base_thickness = 10;//mm
cap_height = 20;//mm
clearance = 0.1;//mm variable space to insert/shrinkage
chamfer_dim = 18;
fix_hole_dia = 4.5;//mm
fix_head_dia = 9;//mm
slot_head_height = 2.5;//mm
slot_length = 4;//mm
cavity_width = batt_width + clearance;
foot_width = cavity_width + (2 * wall_thickness);

module battery() {
    translate([0, batt_length/2 - foot_depth/2 + wall_thickness + clearance, batt_height/2 + wall_thickness]) rotate([0, 0, 90]) cube([batt_length, batt_width, batt_height], center=true);
}

module rounded_cube(size_array, centre=false, corner_radius=2) {
    *cube(size_array, center=centre);
    w = size_array[0];
    d = size_array[1];
    h = size_array[2];
    translate([0, centre?-d/2:0, centre?-h/2:0]) hull() {
        translate([0, corner_radius, corner_radius]) rotate([0, 90, 0]) cylinder(h=w, r=corner_radius, center=centre, $fn=32);
        translate([0, d - corner_radius, corner_radius]) rotate([0, 90, 0]) cylinder(h=w, r=corner_radius, center=centre, $fn=32);
        translate([0, corner_radius/1.414, h - corner_radius/1.414]) rotate([45, 0, 0]) rotate([0, 90, 0]) cylinder(h=w, r=corner_radius, center=centre, $fn=4);
        translate([0, d - corner_radius/1.414, h - corner_radius/1.414]) rotate([45, 0, 0]) rotate([0, 90, 0]) cylinder(h=w, r=corner_radius, center=centre, $fn=4);
    }
}
module chamfer() {
    translate([foot_width/2, foot_depth/2, cap_height/2]) rotate([0, 0, 45]) cube([chamfer_dim, chamfer_dim, cap_height*2], center=true);
}
module spacer() {
    translate([3*spacer_width/2, 0, batt_term_protrusion/2 + wall_thickness]) cube([spacer_width, foot_depth, batt_term_protrusion], center=true);
}

module round_edge(dia=5) {
    translate([dia/2, -dia/2, 0]) intersection() {
        difference() {
            cylinder(h=strap_width, d=dia*2, $fn=32);
            cylinder(h=strap_width, d=dia, $fn=32);
        }
        translate([-dia, 0, 0]) cube([dia,dia,strap_width]);
    }
}
module slot() {
    hull() {
        translate([0, foot_depth/2, -1]) cylinder(h=wall_thickness*2, d=fix_hole_dia, $fn=32);
        translate([0, foot_depth/2 + slot_length]) cylinder(h=wall_thickness*2, d=fix_hole_dia, $fn=32);
    }
    hull() {
        translate([0, foot_depth/2, wall_thickness-slot_head_height]) cylinder(h=slot_head_height, d=fix_head_dia, $fn=32);
        translate([0, foot_depth/2 + slot_length, wall_thickness-slot_head_height]) cylinder(h=slot_head_height, d=fix_head_dia, $fn=32);
    }
}
module foot() {
    difference() {
        //outside
        translate([0, 0, foot_height/2]) cube([foot_width, foot_depth, foot_height], center=true);
        //cavity
        translate([0, wall_thickness, foot_height/2 + wall_thickness]) cube([cavity_width, foot_depth, foot_height], center=true);
        //chamfers
        chamfer();
        mirror([0, 1, 0]) chamfer();
        mirror([1, 0, 0]) chamfer();
        mirror([1, 0, 0]) mirror([0, 1, 0]) chamfer();
        //strap tunnel
        translate([0, 0, 0]) cube([foot_width*2, strap_width + clearance, strap_thickness*2], center=true);
        //rounded edges
        translate([foot_width/2, strap_width/2, 0]) rotate([90, 180, 0]) round_edge();
        translate([-foot_width/2, strap_width/2, 0]) rotate([90, 270, 0]) round_edge();
        //fixing slots
        translate([0,  -foot_offset, 0]) slot();
        translate([0,  -foot_depth+foot_offset, 0]) slot();
    }
}


//assembly
module assembly() {
    color("pink") battery();
    translate([0, batt_length-foot_depth+wall_thickness*2, 0]) mirror([0,1,0]) foot();
    foot();
    %translate([0, foot_depth/2-foot_offset+slot_length/2, 0]) cube([20, 67.5, 1], center=false);
    %translate([-30, -foot_depth/2+foot_offset+slot_length/2, 0]) cube([30, 137, 1], center=false);
}
//assembly();
foot();

