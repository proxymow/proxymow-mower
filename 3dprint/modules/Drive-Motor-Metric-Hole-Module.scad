use <Drive-Motor-Hole-Module.scad>
$fa=1;
$fs=0.4;

module metric_hole(pad_height = 10, hole_size = "M4", hole_offset_x=0, hole_offset_y=0, csk=true) {
    if (hole_size == "M3") {
        hole_dia = 3.6;
        csk_dia = (csk) ? 6.94:0;
        altitude = (csk_dia - hole_dia) / 2; 
        pad_hole(pad_height+2, hole_dia, csk_dia, altitude, hole_offset_x, hole_offset_y);
    }
    else if (hole_size == "M4") {
        hole_dia = 4.8;
        csk_dia = (csk) ? 9.18:0;
        altitude = (csk_dia - hole_dia) / 2; 
        pad_hole(pad_height+2, hole_dia, csk_dia, altitude, hole_offset_x, hole_offset_y);
    }
}
