//Roof Socket Plug - insert & glue pair into 10mm holes in top of control box to support roof
//Socket hole tapers from 22.7 to 25.2 = 2.5mm
plug_dia = 22.7 + (2.5/2);
echo("Plug Dia:", plug_dia);
plug_height = 10;//mm
spigot_height = 2.5;//mm
spigot_dia = 10;//mm
clearance_height = 7.5;//mm
clearance_dia = 6;//mm

module plug() {
    difference() {
        union() {
            cylinder(h=plug_height, d=plug_dia, $fn=32, center=true);
            translate([0, 0, (plug_height + spigot_height)/2]) cylinder(h=spigot_height, d=spigot_dia, $fn=32, center=true);
        }
        translate([0, 0, -(plug_height - clearance_height + 0.1)/2]) cylinder(h=clearance_height, d=clearance_dia, $fn=32, center=true);
    }
}

plug();