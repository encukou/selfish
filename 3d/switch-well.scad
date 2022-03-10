CHOC_SPACING_X = 18;
CHOC_SPACING_Y = 17;
CHOC_SZ = 13.80;
CHOC_FULL_SZ = 15.00;
CHOC_H = 2.20;
WELL_ANGLE = 20;

BOX_SZ_X = 15;
BOX_SZ_Y = 16;

CAP_SZ = 17;
CAP_CHAMF = 2;

BOTTOM_WALL = 1;

WIRE_R = .5;  // CHECK!
WIRE_N = 4;
WIRE_ORG_T = 1;
WIRE_ORG_W = 2;

DIODEW_R = 0.3;

TOL = 0.25;
RTOL = TOL/2;

INF = 20;
EPS = 0.01;

$fn = 50;

WALL_H = CHOC_H+BOTTOM_WALL;

module box (sizes, centering=[1, 1, 1], extra_negative=[0, 0, 0]) {
    translate ([
        -sizes[0]*centering[0]/2-extra_negative[0],
        -sizes[1]*centering[1]/2-extra_negative[1],
        -sizes[2]*centering[2]/2-extra_negative[2],
    ]) {
        cube ([
            sizes[0]+extra_negative[0],
            sizes[1]+extra_negative[1],
            sizes[2]+extra_negative[2],
        ]);
    }
}

module choc_well (pos=0) {
    difference () {
        union () {
            // Main body
            box ([BOX_SZ_X, BOX_SZ_Y, WALL_H], [1, 1, 0]);
            // Connectors between wells
            for (x=[-1,1]) for (y=[-1,1]) if (y != pos) {
                wall_sz = 1;
                y_sz = 1;
                translate ([x*(BOX_SZ_X/2-wall_sz/2), y*BOX_SZ_Y/2, 0]) {
                    box ([wall_sz, y_sz, WALL_H], [1, 1, 0]);
                }
            }
        }
        // Main body cutout
        translate ([0, 0, BOTTOM_WALL]) {
            box ([CHOC_SZ+TOL, CHOC_SZ+TOL, INF], [1, 1, 0]);
        }
        // Cutout for middle plastic pin of the keyswitch
        translate ([0, 0, -1]) cylinder(INF, r=3.20/2+RTOL);
        // Cutout for side plastic pins
        for (y=[-1,1]) translate ([0, y*11/2, -1]) cylinder(INF, r=1.80/2+RTOL);
        // Contact pins of the keyswitch
        for (xy=[[5.90, 0], [3.80, -5]]) translate ([xy[0], xy[1], -EPS]) {
            cylinder(BOTTOM_WALL+1+EPS, r=2.90/2+RTOL);
            %union () {
                box ([4.55, 5, 1.85], [1,1,2]);
                translate ([0, 0, 0]) box ([1.68, 5+2*1.6, 1.85], [1,1,2]);
            }
        }
        // Diode groove
        for (y=[1, -1]) translate ([-1.5, BOX_SZ_Y/2*y, 0]) rotate ([0, 90, 0]) scale ([2, 1, 1]) {
            cylinder (5, r=.5);
        }
        /* // LED hole
        translate ([-4.70, 0, -1]) box ([2.8+TOL, 3.2+TOL, INF]);
        translate ([-4.70, 0, -1]) box ([2.8+TOL, 5.9+TOL, 1+BOTTOM_WALL-.5], [1, 1, 0]);
        //*/
    }
    %choc_skeleton ();
    // Clip for wires
    scale ([1, 1, -1]) translate ([-BOX_SZ_X/2, -3, 0]) {
        difference () {
            hull () {
                box ([WIRE_R*2*(WIRE_N-1), WIRE_ORG_W, WIRE_R*2+WIRE_ORG_T], [0, 1, 0]);
                box ([WIRE_R*2*(WIRE_N+1)+WIRE_ORG_T+TOL, WIRE_ORG_W, EPS], [0, 1, 0]);
                translate ([WIRE_R*2*(WIRE_N-.5), -WIRE_ORG_W/2, WIRE_R]) {
                    rotate (-90, [1, 0, 0]) intersection () {
                        cylinder (WIRE_ORG_W, r=WIRE_R+WIRE_ORG_T+TOL);
                        box ([INF, INF, INF], [1, 2, 1]);
                    }
                }
            }
            for (x=[0:WIRE_N-1]) translate ([(x*2+1)*WIRE_R, -INF/2, WIRE_R]) {
                rotate (-90, [1, 0, 0]) cylinder (INF, r=WIRE_R+RTOL);
            }
            translate ([0, 0, WIRE_R]) box ([WIRE_R*2*(WIRE_N-.5), WIRE_ORG_W*2, WIRE_R*2-TOL/2], [0, 1, 1], [EPS, 0, 0]);
        }
    }
    // Clip for row wire
    scale ([1, 1, -1]) translate ([1.6, 3.2, 0]) {
        difference () {
            hull () {
                box ([WIRE_R*2+WIRE_ORG_T, WIRE_R*2+WIRE_ORG_T*3, EPS], [0, 1, 0]);
                box ([WIRE_ORG_T, WIRE_R*2+WIRE_ORG_T*2, WIRE_R*3+TOL], [2, 1, 0]);
            }
            translate ([-INF/2, 0, WIRE_R+TOL]) rotate (90, [0, 1, 0]){
                hull () {
                    cylinder (INF, r=WIRE_R+RTOL);
                    translate ([-WIRE_R*2, 0, 0]) cylinder (INF, r=WIRE_R-RTOL);
                }
            }
        }
    }
    // Clip for diode wire
    if (pos != 1) scale ([1, 1, -1]) translate ([-2, BOX_SZ_Y/2-.5, 0]) {
        difference () {
            hull () {
                translate ([-1, 0, 0]) box ([WIRE_ORG_T+DIODEW_R+2, 1, EPS], [0, 2, 0]);
                translate ([-1, 0, WIRE_ORG_T+DIODEW_R+TOL]) box ([1.5, 1, EPS], [0, 2, 0]);
            }
            hull () {
                translate ([0, 1, DIODEW_R]) rotate (90, [1, 0, 0]) cylinder (INF, r=DIODEW_R+RTOL);
                translate ([-1, 1, DIODEW_R]) rotate (90, [1, 0, 0]) cylinder (INF, r=DIODEW_R);
            }
        }
    }
}

module choc_skeleton () {
    translate ([0, 0, BOTTOM_WALL+5]) {
        difference () {
            union () {
                box ([3, 3, 3.00], [0, 1, 0]);
                box ([4.5, 10, 3.00], [1, 1, 0]);
            }
            for (y=[-1,1]) translate ([0, y*5.70/2, -1]) {
                box ([3.00, 1.20, INF]);
            }
        }
    }
    translate ([0, 0, BOTTOM_WALL+2.20]) {
        box ([CHOC_FULL_SZ, CHOC_FULL_SZ, 0.80], [1, 1, 0]);
    }
    translate ([0, 0, BOTTOM_WALL+8]) {
        rotate (90, [0, 0, 1]) import ("cap-Body.stl");
    }
}

module mount_pad (pos) {
    //rotate ([pos < 0 ? 0 : -90, 0, 0]) translate ([0, pos < 0 ? 0 : 2.5, pos < 0 ? 0 : 1.5])
    difference () {
        thickness = 1.5;
        hole_trans = [0, pos<0 ? 6 : 4, -thickness];
        // Main body
        hull () {
            rotate ([WELL_ANGLE, 0, 0]) box ([BOX_SZ_X, EPS, thickness], [1, 1, 2]);
            translate (hole_trans) cylinder (thickness, r=6/2);
        }
        // Screw hole
        translate (hole_trans) {
            cylinder (INF, r=3/2+RTOL, center=true);
        }
    }
}

for (pos=[-1, 0, 1]) translate ([0, CHOC_SPACING_Y/2*pos, 0]) {
    rotate ([WELL_ANGLE*pos, 0, 0]) {
        translate ([0, CHOC_SPACING_Y/2*pos, 0]) {
            choc_well (pos=pos);
        }
        if (pos != 0) translate ([0, BOX_SZ_Y*pos, WALL_H]) {
            rotate ([-WELL_ANGLE*pos, 0, 0]) scale ([1, pos, 1]) {
                mount_pad (pos=pos);
            }
        }
    }
}
