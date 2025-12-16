include <../shared/Constants.scad>
use <threadlib/threadlib.scad>

module rotate_on_circle(angle, radius) {
    dx = radius * sin(angle);
    dy = radius * cos(angle);
    translate([dx, dy, 0]) children();
}
module body(height) {
    difference() {
        //Knob
        cylinder(r = KNOB_DIAM / 2, h = height, center = true, $fn = 64);

        //screwHole
        cylinder(r = THRU_HOLE_DIAM / 2, h = height * 2, center = true, $fn = 64);

        //grippyCutouts
        for(i = [1:NUM_GRIP_CUTOUTS]) {

          rot_angle = (360 / NUM_GRIP_CUTOUTS) * i;
          //translate([0, 0, -(((height - SCREWHEAD_DEPTH) / 2) + 0.01)])
            rotate_on_circle(rot_angle, (KNOB_DIAM / 2) + CUTOUT_RADIUS_ADJ)
              cylinder(r = GRIP_CUTOUT_DIAM / 2, h = height + 0.01, center = true, $fn = 64);
        }

        //top filet
          rotate_extrude()
            polygon(points = [
              [KNOB_DIAM, height],
              [0, height + 2],
              [0, height],
              [KNOB_DIAM / 1.29, 0]
            ], $fn = 100);

        //bottom filet
          rotate_extrude()
            polygon(points = [
              [-KNOB_DIAM, -height],
              [0, -height - 2],
              [0, -height],
              [-KNOB_DIAM / 1.29, 0]
            ], $fn = 100);

        cylinder(h = 20, d = 9.9, $fn = 32);
    }
}
module thumbwheel(height, dia, num_turns) {
    body(height);
    translate([0, 0, (-num_turns/1.625)]) nut("M8", turns = num_turns, Douter = 10);
}

thumbwheel(KNURLED_WHEEL_HEIGHT, KNOB_DIAM, KNURLED_WHEEL_NUM_TURNS);
