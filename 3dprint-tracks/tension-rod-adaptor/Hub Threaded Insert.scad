include <../shared/Constants.scad>
use <threadlib/threadlib.scad>

module hub_insert() {
    num_turns = 19;
    x_factor = 1.04;
    y_factor = 1.04;
    z_factor = 1.0;
    corner_dim = tube_dim - 0.566;//0.0 too tight, 0.5 fitted well, 0.566 => 10.0 id
    effective_dim = corner_dim / sqrt(2);
    shrinkage = (100 * (tube_dim - 0.566)) / tube_dim;
    expansion = 100 / shrinkage;
    //echo("corner_dim: ", corner_dim, "effective_dim: ", effective_dim, "shrinkage: ", shrinkage, "%", "expansion: ", expansion, "%");
    difference() {
        cylinder(h=tube_insertion, d=corner_dim, $fn=4, center=true);
        cylinder(h=tube_insertion+2, d=9.3, $fn=32, center=true);
    }
    translate([0, 0, -11.85]) scale([x_factor, y_factor, z_factor]) nut("M8", turns=num_turns, Douter=9, $fn=6);
}

hub_insert();