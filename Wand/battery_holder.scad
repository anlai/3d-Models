use <threads.scad>

render_lower_wand = true;
render_lower_wand_door = true;
render_lower_wand_cap = true;
render_upper_wand = true;

// Diameter of bottom
wand_lower_diameter=22;
// Diameter of middle (where bottom and top join)
wand_middle_diameter=20;
// Diameter of top
wand_top_diameter=10;

// Height of the lower portion
wand_lower_height=140;
// Height of the upper portion
wand_upper_height=125;

fudge_factor=1;

// Include ghost of electronics
include_ghost=true;

/* [Hidden] */

// measurements of the battery holder
holder_height=12;   //11.61; // (actual measured dimensions)
holder_width=13;    //12.73; // (actual measured dimensions)
holder_length=94;

// measurements of the power switch
switch_width=8;     
switch_length=12;   // 11.77; // (actual measured dimensions)
switch_height=4;    // 3.88;  // (actual measured dimensions)
switch_button_base_diameter=7; // 6.8; // (actual measured dimensions)
switch_button_base_height=2;
switch_button_diameter=4.5;    // 4.3; // (actual measured dimensions)
switch_button_height=2;

//measurements of the led
led_light_diameter=6;
led_light_height=4; // check this

// how round are all the cylinders
roundness=360;

// =========================================
// Placeholders
// =========================================

module oval(w,h, height, center = false) {
    scale([1, h/w, 1]) cylinder(h=height, r=w, center=center, $fn=40);
}

module trapezoid(bottom, top, height, length) {
    top_diff=(bottom-top)/2;
    rotate([0,270,0])
        linear_extrude(length) {
            polygon([[0,0],[0,bottom],[height,bottom-top_diff],[height,top_diff]]);
        }
}

module prism(l, w, h){
    polyhedron(
            points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
            faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
            );
    

}

// shape of the battery holder to cut out
module battery_holder() {
    trapezoid_bottom_width=12.75;
    trapezoid_top_width=12.3;
    trapezoid_height=7.7;
    trapezoid_length=94;

    translate([-holder_length,(holder_width/2)-.1,trapezoid_height])
        rotate([0,90,0])
            oval((holder_height-trapezoid_height),(trapezoid_top_width/2),holder_length);

    trapezoid(trapezoid_bottom_width,trapezoid_top_width,trapezoid_height,trapezoid_length);
}

module battery_switch() {
    cube([switch_width,switch_length,switch_height]);
    translate([switch_width/2,switch_length/2,switch_height]){
        cylinder(d=switch_button_base_diameter,h=switch_button_base_height,$fn=roundness);
        translate([0,0,switch_button_base_height]) {
            cylinder(d=switch_button_diameter,h=switch_button_height,$fn=roundness);
        }
    } 
}

// =========================================
// Main modules
// =========================================

module wand_handle() {
    // screw threads for the bottom
    rotate([180,0,0])
    RodStart(wand_lower_diameter,0);

    // main shell with cutouts for components
    difference() {
        cylinder(r1=wand_lower_diameter/2, r2=wand_middle_diameter/2, h=wand_lower_height, $fn=roundness);
       
        // cut out cavities for the components
        translate([-holder_height/2+1.5,-holder_width/2,2]) 
            rotate([0,90,0]) 
            scale([1.02,1.1,1.1])
            battery_holder();
        
        // switch + support structure
        translate([4.1,-4,holder_length+29]) 
            rotate([90,0,90]) 
            battery_switch();

        // channel under the battery holder for wires
        translate([-7,-holder_width/2,2]) {
            cube([10,holder_width,10]);
            cube([10,5,holder_length+5]);
        }

        // tunnel for wire from button to upper section
        translate([4,0,wand_lower_height-7]) 
            rotate(a=[0,-15,0]) 
            cylinder(h=10,r=3, $fn=roundness);        

        // lower the shelf below the switch
        translate([4,-4.5,holder_length+2]) cube([2,switch_width+1,40]); 

        // ramp from the battery holder to the button
        translate([-5,(switch_width+1)/2,holder_length+2])
            rotate([0,0,-90])
            prism(switch_width+1,10,27);

    }

    //translate([0,0,wand_lower_height]) RodEnd(wand_middle_diameter,9);
    if (include_ghost) {
        %translate([-holder_height/2+1.5,-holder_width/2,2]) 
            rotate([0,90,0]) 
            battery_holder();
        
        %translate([4.1,-4,holder_length+29]) rotate([90,0,90]) battery_switch();
    } 

    // screw threads for the top
    difference() {
        translate([0,0,wand_lower_height]) RodStart(wand_middle_diameter,0);
        translate([0,0,wand_lower_height-20]) cylinder(h=40,r=wand_middle_diameter/4,$fn=roundness);
    }

    
}

// cut out shape for the battery door
module handle_door_cuts() {

    thread_length=15;

    // main door
    translate([0,-20,-thread_length]) {
        cube([20,40,holder_length+thread_length]);
    }
    
    // notches to hold the handle
    // translate([0,-8.25,holder_length-2]) cube([1.5,1.5,4]);
    // translate([0,7,holder_length-2]) cube([1.5,1.5,4]);
    
    // tracks for the battery door
    translate([5,-5,holder_length]) cube([2,1,20]);
    translate([5,4,holder_length]) cube([2,1,20]);

    // door to button
    doorToSwitch=35;
    translate([5,-4,holder_length]) cube([switch_width+2,8,doorToSwitch]);

    // round opening for power button
    translate([8,0,holder_length+doorToSwitch-.5])
        rotate([0,90,0]) cylinder(r=3.4,h=2,$fn=50);

}

module lower_cap() {
    translate([-25,0,1])
    union(){
        RodEnd(wand_lower_diameter, 10);    
        translate([0,0,-1]) cylinder(r=wand_lower_diameter/2,h=1,$fn=roundness);
    }
}

module upper_wand() {
    translate([0,25,0]){

        difference(){
            // main body
            cylinder(r1=wand_middle_diameter/2, r2=wand_top_diameter/2, h=wand_upper_height, $fn=roundness);
            // channel for wire
            translate([0,0,-1]) cylinder(r=wand_top_diameter/4,h=wand_lower_height+2,$fn=roundness);

            // carve out holder for led
            translate([0,0,wand_upper_height-led_light_height/3]) cylinder(r=led_light_diameter/2,h=10,$fn=roundness);
        }

        // threads to screw into the bottom portion        
        rotate([180,0,0])
        RodEnd(wand_middle_diameter,9);    
    }
}

// =========================================
// Render the pieces
// =========================================

// lower wand
if (render_lower_wand) {
    difference() {
        wand_handle();
        handle_door_cuts();
    }

    // color("blue") 
    //     translate([9,0,wand_lower_height-20]) 
    //     rotate(a=[0,-15,0]) cylinder(h=40,r=3, $fn=roundness);
}

// lower wand door
if (render_lower_wand_door) {
    translate([20,0,0])
    intersection() {
        wand_handle();
        handle_door_cuts();
    }
}

if (render_lower_wand_cap) {
    lower_cap();
}

if (render_upper_wand) {
    upper_wand();
}