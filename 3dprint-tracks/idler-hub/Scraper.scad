//Scraper to keep idler wheels clear

module scraper() {
    difference() {
        translate([0, 0, -1]) linear_extrude(height=2) polygon([
            [-5, 4],
            [18, 5],
            [18, -5],
            [-5, -4]
        ]);
        translate([9, 0, 0]) hull() {
            cylinder(h=10, d=4.5, $fn=32, center=true);
            translate([6, 0, 0]) cylinder(h=10, d=4.5, $fn=32, center=true);
        }
        rotate([0, 6, -6]) translate([0, 0, -15.5]) cube(30, center=true);
    }
}

rotate([180, 0, 0]) scraper();