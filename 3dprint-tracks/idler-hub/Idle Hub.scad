include <../shared/Constants.scad>

//idler hub

/*
    idle tube stop is the distance from axle to tube
    we need it to cut the wheelbase tubes to length
*/
idle_tube_stop = radial_spacing + hub_thickness + (idler_dia/2) - tube_insertion;
echo("idle_tube_stop:", idle_tube_stop);

module bear(shaft_dia) {
    //make child object accept a slot-in bearing 
    rotate([0, 0, 0]) difference() {
        children();
        //bearing seat
        rotate([90, 0, 0]) cylinder(h=idle_bearing_thickness, d=idle_bearing_fit_dia, $fn=32, center=true);
        //side bearing access
        translate([-idle_bearing_fit_dia/2, 0, 0]) cube([idle_bearing_fit_dia, idle_bearing_thickness, idle_bearing_fit_dia], center=true);
        //shaft access
        rotate([90, 0, 0]) translate([0, 0, 0]) cylinder(h=hub_thickness*2, d=shaft_dia, $fn=32, center=true);
        //inner bearing recess
        rotate([90, 0, 0]) translate([0, 0, 0]) cylinder(h=hub_thickness/2, d=3*shaft_dia/2, $fn=32, center=true);        
    }        
}
module idler_side() {
    echo("Idler Side Offset: ",  idler_spacing + (hub_thickness + idler_width)/2);
    translate([0, idler_spacing + (hub_thickness + idler_width)/2, 0]) {
        difference() {
            bear(idle_shaft_hole_dia) hull() {
                //hub disc
                rotate([90, 0, 0]) cylinder(h=hub_thickness, d=hub_dia, $fn=32, center=true);
                //tube shroud
                translate([radial_spacing + (idler_dia + hub_thickness)/2, 0, 0]) cube(hub_thickness, center=true);
            }
            //tube socket
            translate([radial_spacing + hub_thickness + (idler_dia/2) - (tube_insertion/2) + 0.1, 0, 0]) rotate([0, 90, 0]) rotate([0, 0, 45]) cylinder(h=tube_insertion, d=tube_dim, $fn=4, center=true);
            //bearing ejector hole
            rotate([0, 90, 0]) cylinder(h=idler_dia, d=tube_dim/4, $fn=32, center=true);
        }
    }
}
module idler_end() {
    union() {
        idler_side();
        mirror([0, 1, 0]) idler_side();
        //rotate and lower bracing to edge
        translate([radial_spacing + hub_thickness + (idler_dia/2) - (tube_dim/2), 0, -1.35]) rotate([0, -5, 0]) difference() {
            rotate([90, -22.5, 0]) cylinder(h=idler_width + (2*idler_spacing) + 1, d=tube_dim, $fn=8, center=true);
            rotate([0, 0, -22.5]) cylinder(h=tube_dim, d=scraper_fix_hole_dia, $fn=32, center=true);
        }
    }
}

//Note: slice rotated 'lay-flat' without support touching buildplate
idler_end();