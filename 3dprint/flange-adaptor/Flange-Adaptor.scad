/*
    Proxymow Mower - Flange Adaptor
    Adapts a 6mm D shaft to 10mm Flange Hole with anti-vibration grub screw hole
    Print in PETG
*/
shaft_length = 13;
outer_dia = 10.1;
inner_dia = 6.35;
key_width = 3.3;
key_length = 2.0;
key_offset = 0.5;
grub_hole_dia = 4.1;
grub_hole_offset = 5.0;

module grub() {
    //grub hole
    translate([0, 0, grub_hole_offset]) rotate([0,90,90]) cylinder(shaft_length, d=grub_hole_dia, $fn=32);
}

module adapter() {
    

    difference() {
    
        //10mm tight fit shaft
        cylinder(shaft_length, d=outer_dia, $fn=32);//

        //enlarged hole > 6.2 in file
        translate([0,0,-1]) cylinder(shaft_length + 2, d=inner_dia, $fn=32);//fmly 6.4

        grub();
    }
    difference() {

        //key - 0.5mm from edge, 6.4/2 - 0.5 = 2.7
        translate([0,inner_dia/2 + key_length/2 - key_offset,shaft_length/2]) cube([key_width, key_length, shaft_length], center=true);

        //grub hole in key
        grub();
    }
}

adapter();