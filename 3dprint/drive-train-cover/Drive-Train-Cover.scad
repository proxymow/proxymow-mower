/*
    Proxymow Mower - Drive Train Cover
    Print in PETG

    Print flat then fold over brackets and screw to base
    Left-hand and right-hand required
*/
internal_dia = 49.25;//mm
internal_height = 43.125;//mm
cover_length = 120;//mm
foot_width = 8;//mm
foot_extent = 5;//mm
foot_thickness = 2;//mm
seal_width = 2;//mm
seal_angle = 75;
notch_width = 15;//mm
notch_height = 7;//mm
fix_hole_dia = 4.5;
wall_thickness = 0.6;
wall_distance = internal_height - (internal_dia/2);
half_circum = PI * internal_dia / 2;
cover_distance = (wall_distance * 2) + half_circum;
echo("cover_distance", cover_distance);

module tab() {
    rotate([270, 0, 0]) translate([0, -foot_extent, -(cover_distance-foot_thickness)/2]) difference() {
        union() {
            cylinder(h=foot_thickness, d=foot_width, $fn=32, center=true);
            translate([0, foot_extent/2, 0]) cube([foot_width, foot_extent, foot_thickness], $fn=32, center=true);
        }
        cylinder(h=foot_thickness+1, d=fix_hole_dia, $fn=32, center=true);
    }
}

module seal() {
    translate([0, (cover_distance + (cos(seal_angle) * seal_width))/2, seal_width/2]) rotate([seal_angle, 0, 0]) cube([cover_distance, seal_width, wall_thickness], center=true);
}
module notch1() {
    translate([-cover_length/2 - 0.5, (cover_distance + foot_thickness)/2+0.5, -foot_extent/2]) rotate([90, 0, 0]) cube([notch_width, foot_extent, notch_height+2], center=false);
}
module notch2() {
    translate([-cover_length/2 + 50, (cover_distance + foot_thickness)/2+0.5, -foot_extent/2]) rotate([90, 0, 0]) cube([notch_width, foot_extent, notch_height], center=false);
}
module notch3() {
    translate([(cover_length/2) - (3*notch_width/2) + 0.5, -(cover_distance/2)+foot_thickness, foot_extent/2]) rotate([90, 0, 0]) cube([notch_width*3, foot_extent*2, notch_height+2], center=true);
}
module notch4() {
    translate([(cover_length/2) - (3*notch_width/2) + 0.5, (cover_distance/2)-foot_thickness, foot_extent/2]) rotate([90, 0, 0]) cube([notch_width*3, foot_extent*2, notch_height+2], center=true);
}
module cover(left_handed=true) {
    difference() {
        union() {
            translate([0, 0, wall_thickness/2]) cube([cover_length, cover_distance, wall_thickness], center=true);
            translate([-41.5, 0, 0]) tab();
            translate([-41.5, 0, 0]) mirror([0, 1, 0]) tab();
            translate([10, 0, 0]) tab();
            translate([10, 0, 0]) mirror([0, 1, 0]) tab();
            seal();
            mirror([0, 1, 0]) seal();
        }
        translate([-41.5, -foot_thickness, 0]) tab();
        mirror([0, 1, 0]) translate([-41.5, -foot_thickness, 0]) tab();
        translate([10, -foot_thickness, 0]) tab();
        mirror([0, 1, 0]) translate([10, -foot_thickness, 0]) tab();
        notch1();
        mirror([0, 1, 0]) notch1();
        notch2();
        mirror([0, 1, 0]) notch2();
        if (left_handed) notch3(); else notch4();
    }
}
//Left handed
rotate([0, 0, 90]) cover(true);

//Right handed
//rotate([0, 0, 90]) cover(false);
