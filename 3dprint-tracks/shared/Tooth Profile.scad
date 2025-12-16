//Simple Trapezoid Tooth Profile - used by Belt - don't print
use <Chamfer-Fillet-Machine.scad>
pressure_angle = 14.5;//degrees
tooth_pitch = 16;//mm
half_tooth_pitch = tooth_pitch/2;
root_fillet_radius = 2;//mm
tooth_height = 5;//mm

function tooth_points(
    pressure_angle=14.5,
    tooth_pitch=16,
    root_fillet_radius=2,
    tooth_height=12,
    descent=0.1) = 
    let(
        //half pitch
        half_tooth_pitch = tooth_pitch/2,
        
        //find the tangent contact points
        x_fact = cos(pressure_angle),
        y_fact = sin(pressure_angle),
        
        //find the x and y distance from circle centre
        dx_radial = x_fact * root_fillet_radius,
        dy_radial = y_fact * root_fillet_radius,

        //find the tangent coordinates
        x_tang = -half_tooth_pitch + dx_radial,
        y_tang = root_fillet_radius - dy_radial,

        //find gradient of the radial
        radial_gradient = -dy_radial / dx_radial,

        //find gradient of tangent
        tangent_gradient = -1 / radial_gradient,

        //calculate intersection point on baseline (y = 0)
        x_base_disp = y_tang / tangent_gradient,
        x_base = x_tang - x_base_disp,

        //calculate intersection point on top (y = height)
        y_top_disp = (tooth_height - y_tang),
        x_top_disp = y_top_disp / tangent_gradient,
        x_top = x_tang + x_top_disp,
        pts = [
            //[0, -descent, 0],
            [-(half_tooth_pitch + root_fillet_radius), -descent, 0],
            [-(half_tooth_pitch + root_fillet_radius), 0, 0],
            [x_base, 0, root_fillet_radius],
            [x_top, tooth_height, 1],
            [-x_top, tooth_height, 1],
            [-x_base, 0, root_fillet_radius],
            [half_tooth_pitch + root_fillet_radius, 0, 0],
            [half_tooth_pitch + root_fillet_radius, -descent, 0],
            [-(half_tooth_pitch + root_fillet_radius), -descent, 0]
            //[0, -descent, 0]
        ]
    ) pts;

module tooth_pitch_debug(
    pressure_angle=14.5,
    tooth_pitch=16,
    root_fillet_radius=2,
    tooth_height=12) {

    //draw 2 circles to represent the root fillets, and space them apart by the pitch
    translate([-tooth_pitch/2, root_fillet_radius]) circle(root_fillet_radius, $fn=32);
    translate([tooth_pitch/2, root_fillet_radius]) circle(root_fillet_radius, $fn=32);

    //simulate a zero degree pressure angle
    %translate([0, tooth_height/2]) square([tooth_pitch - (2 * root_fillet_radius), tooth_height], center=true);

    //find the tangent contact points
    x_fact = cos(pressure_angle);
    y_fact = sin(pressure_angle);
    echo("x_fact: ", x_fact, "y_fact: ", y_fact);
    //find the x and y distance from circle centre
    dx_radial = x_fact * root_fillet_radius;
    dy_radial = y_fact * root_fillet_radius;
    echo("dx_radial: ", dx_radial, "dy_radial: ", dy_radial);

    x_tang = -half_tooth_pitch + dx_radial;
    y_tang = root_fillet_radius - dy_radial;
    echo("x_tang: ", x_tang, "y_tang: ", y_tang);

    //annotate tangent contact points
    color("black", 0.25) translate([x_tang, y_tang]) circle(0.5, $fn=32);
    color("black", 0.25) translate([-x_tang, y_tang]) circle(0.5, $fn=32);

    //annotate radial
    color("blue") translate([-half_tooth_pitch, root_fillet_radius]) vector_arrow([dx_radial, -dy_radial]);

    //find gradient of the radial
    radial_gradient = -dy_radial / dx_radial;
    echo("radial_gradient: ", radial_gradient);

    //find gradient of tangent
    tangent_gradient = -1 / radial_gradient;
    echo("tangent_gradient: ", tangent_gradient);

    //calculate intersection point on baseline (y = 0)
    x_base_disp = y_tang / tangent_gradient;
    x_base = x_tang - x_base_disp;
    echo("x_base_disp: ", x_base_disp, "x_base: ", x_base);

    //annotate triangle
    color("yellow", 0.25) polygon([
        [x_tang, y_tang],
        [x_tang, 0],
        [x_base, 0]
    ]);

    //annotate base contact points
    color("black", 0.25) translate([x_base, 0]) circle(0.5, $fn=32);

    //create tangent line vector
    Vtang = [dy_radial, dx_radial];
    Vtangex = extend_vect(Vtang, 20);
    echo("Vtang: ", Vtang);

    //annotate tangents
    color("red") translate([x_base, 0]) vector_line(Vtangex);

    //label pressure angle
    color("black") translate([-half_tooth_pitch, tooth_height + 1]) text(str("Pressure Angle: ", pressure_angle, " degrees"), size=0.5);

    //calculate intersection point on top (y = height)
    y_top_disp = (tooth_height - y_tang);
    x_top_disp = y_top_disp / tangent_gradient;
    echo("y_top_disp: ", y_top_disp, "x_top_disp: ", x_top_disp);
    x_top = x_tang + x_top_disp;
    echo("x_top: ", x_top);

    //annotate triangle
    color("yellow", 0.35) polygon([
        [x_tang, y_tang],
        [x_tang, tooth_height],
        [x_top, tooth_height]
    ]);

    //annotate top contact points
    color("black", 0.25) translate([x_top, tooth_height]) circle(0.5, $fn=32);
}
*tooth_pitch_debug();