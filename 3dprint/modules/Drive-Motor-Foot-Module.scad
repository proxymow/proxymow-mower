use <MCAD/boxes.scad>
$fa=1;
$fs=0.4;

module drive_motor_foot(pad_width=50, pad_length=25, pad_height=10) {
    union() {
        translate([0,0,pad_height/2])
            roundedBox(size=[pad_width,pad_length,pad_height],radius=pad_height/6,sidesonly=false);
        translate([0,0,pad_height/2 - pad_height/4])
            roundedBox(size=[pad_width,pad_length,pad_height/2],radius=pad_height/6,sidesonly=true);
        
    }
}
drive_motor_foot();