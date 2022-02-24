tamp_radius=27;
tamp_depth=9;
tamp_tolerance=1;
stand_radius=tamp_radius+5;
stand_height=15;

groove_width=3;
groove_height=3;
groove_distance=10;
groove_depth=10;

groove_initial_x=(stand_radius-12); // 10 is the opening of the well to the groove
groove_initial_y=-(stand_radius-6); // 8 is the opening from the groove to the back of the well
groove_x_offset=12.5;

show_guides=false;

module tamp_stand(guide_shift) {
    difference(){
        // outer stand
        cylinder(h=stand_height,r=stand_radius);

        // hole for the tamp
        translate([0,0,stand_height-tamp_depth])
            cylinder(h=tamp_depth+10,r=tamp_radius+tamp_tolerance);

        // grooves for the breville top
        // y sets the depth the grooves, reamining space is solid for the back opening
        //   depth of the opening (back side of the platform) - stand_radius = y offset
        // x sets the edge to the first groove
        //   depth of the opening (left side of the platform) - stand_radius = x offset
        // each successive groove, needs to be groove_depth away on the x-axis
        translate([groove_initial_x+guide_shift,groove_initial_y,-1]) {
            cube([groove_width,100, groove_height+1]);
            translate([-15+groove_width,0,0]) cube([groove_width, 100, groove_height+1]);
            translate([-27.5+groove_width,0,0]) cube([groove_width,100, groove_height+1]);
            translate([-40+groove_width,0,0]) cube([groove_width,100, groove_height+1]);
            translate([-52.5+groove_width,0,0]) cube([groove_width,100, groove_height+1]);
        }
    }
}

module tamp_guides(guide_shift) {

    color("red")
    translate([groove_initial_x+guide_shift,groove_initial_y,-2]) {
        cube([groove_width,100, groove_height]);
        translate([-15+groove_width,0,0]) cube([groove_width, 100, groove_height]);
        translate([-27.5+groove_width,0,0]) cube([groove_width,100, groove_height]);
        translate([-40+groove_width,0,0]) cube([groove_width,100, groove_height]);
        translate([-52.5+groove_width,0,0]) cube([groove_width,100, groove_height]);
    }

    translate([guide_shift,0,0])
    {
        // back spacer
        color("green") translate([-stand_radius*2,-stand_radius,-1]) cube([100,6,1]);
        
        // between different grooves (go from left side to right)
        color("orange") {
            translate([8,0,-3]) {
                cube([15,5,1]);
                translate([-12.5,5,0]) cube([27.5, 5,1]);
                translate([-25,10,0]) cube([40,5,1]);
                translate([-37.5,15,0]) cube([52.5,5,1]);
            }
        }
    }

    // these should not move

    // shifted for side edge
    //color("blue") translate([stand_radius-10,-stand_radius,-1]) cube([10,100,1]);

    // grooves centered on stand
    color("blue") translate([stand_radius-5.75,-stand_radius,-1]) cube([5.75,100,1]);
    color("blue") translate([-stand_radius,-stand_radius,-1]) cube([5.75,100,1]);

}

shift=groove_width/2+1.75;

// normal print
tamp_stand(shift);
// if (show_guides) tamp_guides(shift);


// difference() {
//     tamp_stand(shift);
//     translate([-stand_radius,0,-1]) cube([stand_radius*2,stand_radius,21]);
//     translate([-stand_radius,-stand_radius,5]) cube([stand_radius*2,stand_radius*2,20]);    
//     // color("orange") translate([-stand_radius,-stand_radius/2,-1]) cube([stand_radius*2,stand_radius*1.5,20]);
// }