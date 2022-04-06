// Upper row angle
angle1 = 30;  // [20:30]
// Lower row angle
angle2 = 80;  // [20:95]
// Middle row angle (i.e. mounting tab angle)
TAB_ANGLE = 17.5; // [-60:60]

assert (angle2 - TAB_ANGLE <= 95, "Middle row angle too negative");

// Color for switch preview
SWITCH_COLOR = [.5, .3, 0];

module _end_customizer () {}

CHOC_SZ = 13.80;
CHOC_FULL_SZ = 15.00;
CHOC_H = 2.20;
WELL_ANGLES = [angle1, angle2];
CAP_SPACE = 13;
KEY_DEPTH = 10.5;

BOX_SZ_X = 15;
BOX_SZ_Y = 16;

CAP_SZ = 17;
CAP_CHAMF = 2;

BOTTOM_WALL = 1;

WIRE_R = .5;  // CHECK!
WIRE_N = 2;
WIRE_ORG_T = 1;
WIRE_ORG_W = 2;

DIODEW_R = 0.3;

// M3 screws
SCREW_R = 3/2;

TOL = 0.25;
RTOL = TOL/2;

INF = 22;
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

module choc_well (pos=0, angle=0) translate ([0, 0, -KEY_DEPTH]) {
    difference () {
        union () {
            // Main body
            box ([BOX_SZ_X, BOX_SZ_Y-.5, WALL_H], [1, 1, 0]);
            // Connector between wells
            for (x=[-1,1]) for (y=[-1,1]) if (y == pos) scale ([x, 1, 1]) {
                rotate ([0, 90, 0]) {
                    translate ([-KEY_DEPTH, -CAP_SPACE/2*y, -BOX_SZ_X/2]) {
                        scale ([1, y, 1]) difference () {
                            $fn = $fn*5;
                            union () {
                                cylinder (BOX_SZ_X/6, r=KEY_DEPTH);
                                translate ([0, 0, BOX_SZ_X/6-EPS]) cylinder (
                                    BOX_SZ_X/6,
                                    r1=KEY_DEPTH,
                                    r2=KEY_DEPTH-WALL_H/2);
                                cylinder (BOX_SZ_Y/2, r=KEY_DEPTH-WALL_H/2);
                            }
                            translate ([0, 0, -EPS]) {
                                cylinder (BOX_SZ_Y, r=KEY_DEPTH-WALL_H);
                            }
                            box ([INF, INF, INF], [1, 0, 1], [0, 1, 0]);
                            rotate ([0, 0, -angle]) translate ([0, 1-EPS, 0]) {
                                box ([INF, INF, INF], [1, 2, 1]);
                            }
                        }
                    }
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
        /* // LED hole
        translate ([-4.70, 0, -1]) box ([2.8+TOL, 3.2+TOL, INF]);
        translate ([-4.70, 0, -1]) box ([2.8+TOL, 5.9+TOL, 1+BOTTOM_WALL-.5], [1, 1, 0]);
        //*/
    }
    //%choc_skeleton ();
    // Clip for wires
    positions = pos == 1 ? [0] : [BOX_SZ_Y/2-WIRE_ORG_W];
    scale ([1, 1, -1]) for (y=positions) translate ([-BOX_SZ_X/2, y, 0]) {
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
            for (x=[-1:WIRE_N-1]) translate ([(x*2+1)*WIRE_R, -INF/2, WIRE_R]) {
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
    for (y=[-1,1]) if (pos != 1 || y==1) scale ([1, 1, -1]) {
        r = pos == 1 ? angle : 0;
        scale ([1, y, 1]) translate ([-2, (-BOX_SZ_Y/2+1), -.5]) rotate ([r, 0, 0]) difference () {
            translate ([0, 0, 0]) hull () {
                rotate ([0, 90, 0]) translate ([0, 0, -1]) cylinder (4, r=1/2);
                translate ([-1, 0, 0]) box ([WIRE_ORG_T+DIODEW_R+2, 1, EPS], [0, 1, 0]);
                translate ([-1, 0, WIRE_ORG_T+DIODEW_R+TOL+.5]) box ([1.5, 1, EPS], [0, 1, 0]);
            }
            translate ([0, 0, 1]) hull () {
                translate ([0, 1, DIODEW_R-.5]) rotate (90, [1, 0, 0]) cylinder (INF, r=DIODEW_R+RTOL);
                translate ([-1, 1, DIODEW_R-.5]) rotate (90, [1, 0, 0]) cylinder (INF, r=DIODEW_R);
            }
        }
    }
}

module choc_skeleton () {
    translate ([0, 0, BOTTOM_WALL+5]) color (SWITCH_COLOR) {
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

module mount_pad (pos, angle) scale ([1, pos, -1]) {
    prot = 2;
    ang = angle-TAB_ANGLE*pos;
    hole_dist = 3;
    hole_r = 3/2-TOL;
    difference () {
        box ([BOX_SZ_X, INF, WALL_H], [1, 0, 0]);
        hull () {
            box ([BOX_SZ_X*2/6, INF, INF], [1, 0, 0], [0, 0, -1]);
            translate ([0, 0, WALL_H-1]) box ([BOX_SZ_X*4/6, INF, INF], [1, 0, 0], [0, 0, -1]);
        }
        translate ([0, prot, 0]) rotate ([ang, 0, 0]) box ([INF, INF*3, INF*3], [1, 1, 2]);
    }
    translate ([0, prot, 0]) rotate ([ang-90, 0, 0]) {
        top_prot = WALL_H/sin(ang);
        difference () {
            hull () {
                box ([BOX_SZ_X, 1, top_prot], [1, 2, 0]);
                translate ([0, 0, top_prot+hole_dist]) {
                    rotate ([90, 0, 0]) cylinder (1, r=hole_dist);
                }
            }
            translate ([0, EPS, top_prot+hole_dist]) {
                rotate ([90, 0, 0]) cylinder (INF, r=hole_r);
            }
        }
    }
}

rotate ([-TAB_ANGLE, 0, 0]) for (pos=[-1, 0, 1]) translate ([0, CAP_SPACE/2*pos, 0]) {
    angle = (pos == -1) ? WELL_ANGLES[0]
          : (pos == 1) ? WELL_ANGLES[1]
          : 0;
    rotate ([angle*pos, 0, 0]) {
        translate ([0, CAP_SPACE/2*pos, 0]) {
            choc_well (pos=pos, angle=angle);
        }
        if (pos != 0) translate ([0, (CAP_SPACE+1)*pos, -KEY_DEPTH+WALL_H]) {
            mount_pad (pos=pos, angle=angle);
        }
    }
}
