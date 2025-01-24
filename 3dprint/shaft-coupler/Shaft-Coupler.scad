/*
    Proxymow Mower - Shaft Coupler
    10mm Diameter Half Closed Coupler Insert, Holeless
    Push fit pair into aluminium tube - 10mm ID, 14mm OD
    Then drill and tap for grub screw through flat
    Print in PETG
*/
shaft_length = 12;
outer_dia = 10.0;
inner_dia = 6.35;
key_width = 3.3;
key_thickness = 1.0;
key_offset = 0.5;
air_hole_dia = 2.5;

module coupler() {
    

    difference() {
        union() {
            //10mm tight fit shaft
            cylinder(shaft_length, d=outer_dia, $fn=32);
        }

        //hole
        translate([0,0,-1]) cylinder(shaft_length + 2, d=inner_dia, $fn=32);

        //marker
        translate([0, inner_dia*1.5,shaft_length+4]) cube(10, center=true);
    }
    difference() {

        union() {
            //key - 0.5mm from edge
            translate([0,inner_dia/2 + key_thickness/2 - key_offset,shaft_length/2]) cube([key_width, key_thickness, shaft_length], center=true);
        //end stop
        cylinder(0.5, d=outer_dia, $fn=32);
        }

        //air hole
        translate([0,0,-1]) cylinder(h=shaft_length, d=2.5, $fn=32);
    }
}

coupler();
translate([0, 15, 0]) coupler();
translate([0, 30, 0]) coupler();
translate([0, 45, 0]) coupler();