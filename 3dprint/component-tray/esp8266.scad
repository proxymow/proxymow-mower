/*
    Proxymow Mower - ESP8266 Component Tray
    Print in PLA
    Standoffs:
        Bayonet head suitable for 5-6mm hole diameter
        Maximum panel thickness: 1.8mm
*/
tray_thickness = 1.8;
font_size = 6.5;

standoff_hole_dia = 5.5;//mm
bush_dia = 10;
bush_height = 10;

//Component Hole Spacing
//  name,  horiz,  vert, x, y, hole dia
c = [
        ["c1", 15, 80, 0, 0, 3.5],
        ["i2c", 32, 49, 30, 15, standoff_hole_dia],
        ["L298", 38, 38, 75, 20, standoff_hole_dia],
        ["c2", 0, 50, 130, 10, 3.5],
        ["esp", 43.5, 21, 145, 30, standoff_hole_dia],
        ["_c3", 0, 50, 200, 15, 3.5]
    ];

module north_island() {
    hull() {
        for (i=[0:1:len(c)-1]) {
            h_space = c[i][1];
            v_space = c[i][2];
            x = c[i][3];
            y = c[i][4];
            d = c[i][5];
            //top left
            translate([x, y + v_space, -1]) cylinder(h=tray_thickness, d=standoff_hole_dia*2, $fn=32);
            //top right
            translate([x + h_space, y + v_space, -1]) cylinder(h=tray_thickness, d=standoff_hole_dia*2, $fn=32);
        }
    }
}

module south_island() {
    hull() {
        for (i=[0:1:len(c)-1]) {
            h_space = c[i][1];
            v_space = c[i][2];
            x = c[i][3];
            y = c[i][4];
            d = c[i][5];
            //bottom left
            translate([x, y, -1]) cylinder(h=tray_thickness, d=standoff_hole_dia*2, $fn=32);
            //bottom right
            translate([x + h_space, y, -1]) cylinder(h=tray_thickness, d=standoff_hole_dia*2, $fn=32);
        }
    }
}

module west_island() {
    h_space = c[0][1];
    v_space = c[0][2];
    x = c[0][3];
    y = c[0][4];
    d = standoff_hole_dia;
    difference() {
        union() {
            //bush
            translate([x, y + (v_space/2), 0]) cylinder(h=bush_height, d=bush_dia, $fn=32);
            hull() {
                //bottom left
                translate([x, y, -1]) cylinder(h=tray_thickness, d=d*2, $fn=32);
                //top left
                translate([x, y + v_space, -1]) cylinder(h=tray_thickness, d=d*2, $fn=32);
            }
        }
        //fixing hole
        translate([x, y + (v_space/2), -1.5]) cylinder(h=bush_height+tray_thickness+1, d=standoff_hole_dia, $fn=32);
    }
}

module east_island() {
    last_index = len(c) - 1;
    h_space = c[last_index][1];
    v_space = c[last_index][2];
    x = c[last_index][3];
    y = c[last_index][4];
    d = standoff_hole_dia;
    difference() {
        union() {
            //bush
            translate([x + h_space, y + (v_space/2), 0]) cylinder(h=bush_height, d=bush_dia, $fn=32);
            hull() {
                //bottom right
                translate([x + h_space, y, -1]) cylinder(h=tray_thickness, d=d*2, $fn=32);
                //top right
                translate([x + h_space, y + v_space, -1]) cylinder(h=tray_thickness, d=d*2, $fn=32);
            }
        }
        //fixing hole
        translate([x + h_space, y + (v_space/2), -1.5]) cylinder(h=bush_height+tray_thickness+1, d=standoff_hole_dia, $fn=32);
    }
}

module tray() {
    //color("red") substrate();
    difference() {
        //draw tray
        union() {
            north_island();
            south_island();
            east_island();
            west_island();
        }
        //Loop through components
        for (i=[0:1:len(c)-1]) {
            name = c[i][0];
            h_space = c[i][1];
            v_space = c[i][2];
            x = c[i][3];
            y = c[i][4];
            d = c[i][5];
            //bottom left
            translate([x, y, -1.5]) cylinder(h=tray_thickness + 1, d=d, $fn=32);
            //bottom right
            translate([x + h_space, y, -1.5]) cylinder(h=tray_thickness + 1, d=d, $fn=32);
            //top left
            translate([x, y + v_space, -1.5]) cylinder(h=tray_thickness + 1, d=d, $fn=32);
            //top right
            translate([x + h_space, y + v_space, -1.5]) cylinder(h=tray_thickness + 1, d=d, $fn=32);
            //label?
            if (name[0] != "_") {
                if (h_space > 0) {
                    translate([x + (2*h_space/3), y - d/2, -0.5]) rotate([0, 180, 0]) linear_extrude(0.5) text(name, font_size);
                } else {
                    translate([x + d, y + d, -0.5]) rotate([0, 180, 0]) linear_extrude(0.5) text(name, font_size);
                }
            }
        }
    }
}
tray();