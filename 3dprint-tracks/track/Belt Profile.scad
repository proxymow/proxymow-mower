//Belt Profile, used by belt - don't print!
track_width = 40;//mm
track_thickness = 4;//mm
bead_rad = 2.0;//mm

module belt_profile() {
    //bead
    translate([track_thickness - bead_rad, (track_width/2)-bead_rad]) circle(bead_rad, $fn=32);
    
    pts = [
        [0, 0],
        [0, track_width/2],
        [track_thickness-bead_rad, track_width/2],
        [track_thickness, (track_width/2)-bead_rad],
        [track_thickness, 0],
        [0, 0]
    ];
    polygon(pts);
}
module full_profile() {
    belt_profile();
    mirror([0, 1, 0]) belt_profile();
}
*belt_profile();
*full_profile();