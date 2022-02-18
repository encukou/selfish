CHOC_SPACING_X = 18;
CHOC_SPACING_Y = 17;
CHOC_SZ = 13.80;
CHOC_FULL_SZ = 15.00;
CHOC_H = 2.20;

BOX_SZ_X = 16;
BOX_SZ_Y = 16;

CAP_SZ = 17;
CAP_CHAMF = 2;

BOTTOM_WALL = 1;

TOL = 0.25;
RTOL = TOL/2;

INF = 20;
EPS = 0.01;

$fn = 50;

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

module choc_well () {
    difference () {
        union () {
            box ([BOX_SZ_X, BOX_SZ_Y, CHOC_H+BOTTOM_WALL], [1, 1, 0]);
            for (r=[0,180]) rotate (r, [0, 0, 1]) {
                translate ([-BOX_SZ_X/2, 0, 0]) {
                    box ([
                        (BOX_SZ_X-CHOC_SZ-TOL)/2,
                         CHOC_SPACING_Y,
                         CHOC_H+BOTTOM_WALL
                    ], [0, 1, 0]);
                }
            }
        }
        translate ([0, 0, BOTTOM_WALL]) {
            box ([CHOC_SZ+TOL, CHOC_SZ+TOL, INF], [1, 1, 0]);
        }
        // Middle plastic pin
        translate ([0, 0, -1]) cylinder(INF, r=3.20/2+RTOL);
        // Side plastic pins
        for (y=[-1,1]) translate ([0, y*11/2, -1]) cylinder(INF, r=1.80/2+RTOL);
        // Contact pins
        for (xy=[[0, 5.90], [-5, 3.80]]) translate ([xy[1], xy[0], -1]) {
            cylinder(BOTTOM_WALL+1+EPS, r=2.90/2+RTOL);
        }
        /* // LED hole
        translate ([-4.70, 0, -1]) box ([2.8+TOL, 3.2+TOL, INF]);
        translate ([-4.70, 0, -1]) box ([2.8+TOL, 5.9+TOL, 1+BOTTOM_WALL-.5], [1, 1, 0]);
        */
    }
    //choc_skeleton ();
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
        *hull () {
            box ([CAP_SZ, CAP_SZ, 0.50], [1, 1, 0]);
            box ([CAP_SZ-CAP_CHAMF, CAP_SZ-CAP_CHAMF, 3.50], [1, 1, 0]);
        }
    }
}

choc_well ();

translate ([0, -CHOC_SPACING_Y+CHOC_SZ/2, 0]) rotate (-20, [1, 0, 0]) {
    translate ([0, -CHOC_SZ/2, 0.6]) {
        choc_well ();
    }
}
translate ([0, CHOC_SPACING_Y-CHOC_SZ/2, 0]) rotate (20, [1, 0, 0]) {
    translate ([0, CHOC_SZ/2, 0.6]) {
        choc_well ();
    }
}
