/*
    Proxymow Mower - 120mm Spiked Rimmed Flange-Mount Wheel
    Print in Black PETG
*/
outer_dia = 120;//mm
rim_depth = 20;//mm
rim_thickness = 10;//mm
spoke_width = 16;//mm
spoke_thickness = 8;//mm
hub_thickness = 14;//mm
hub_width = 34;//mm
hub_hole = 7;//mm
spike_dia = 7;//mm
spike_length = 10;//mm
spike_arc = 15;//degrees
fix_hole_span = 24;//mm
fix_hole_dia = 4.1;//mm

module frame() {
    
    //rim
    difference() {
        cylinder(rim_thickness, d=outer_dia, $fn=360/spike_arc);
        translate([0,0,-1]) cylinder(rim_thickness+2, d=outer_dia-rim_depth);
    }
    cylinder(h=spoke_thickness, d=hub_width);

    //shield
    translate([0,0,0]) cylinder(1, d=outer_dia, $fn=360/spike_arc);
    
    //spokes
    for(i=[0:90:360]) {
        rotate([0, 0, i]) translate([(hub_width/4)-20,-spoke_width/2,0]) cube([(outer_dia/2), spoke_width, spoke_thickness]);
    }

    //spikes
    for(i = [spike_arc/2 : spike_arc: 360])
       rotate(i)
        translate([(outer_dia/2)-1, 0,rim_thickness/2]) 
            rotate([0,90,0]) cylinder(h=spike_length, d1=spike_dia, d2=3, $fn=32);
}

module wheel_assembly() {
    difference() {
        frame();
        
        //central hole
        translate([0,0,-1]) cylinder(hub_thickness+2, d=hub_hole, $fn=32);

        //flange fixing holes
        for(i = [0 : 90 : 360])
         rotate(i) translate([0, -fix_hole_span/2, -1]) cylinder(h=hub_thickness+2, d=fix_hole_dia, $fn=32);
        
    }
}
//assembly
wheel_assembly();