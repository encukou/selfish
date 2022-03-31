
OFFCENTER = 0;  // [-2.5:.1:2.5]

module _end_customizer () {}

CAP_SIZE = 12.5;
TOP_HEIGHT = 2;
CURVE_IN = 1;
STEM_BASE = 0.25;
STEM_CYLOUT = 0.2;

BORDER_W = 0.4;
BORDER_H = 0.25;

EPS = 0.001;
INF = 100;
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

module round_slab (dims, r, rd=0) {
    w = dims[0];
    h = dims[1];
    d = dims[2];
    if (r <= rd) {
        box ([w, h, d], [1, 1, 0]);
    } else {
        hull () for (x=[-1,1]) for (y=[-1,1]) scale ([x, y, 1]) {
            translate ([w/2-r, h/2-r, 0]) cylinder (d, r=r-rd);
        }
    }
}

// x^2 + diag^2 = (x+CURVE_IN)²
function cdist (base, inset) = (base^2 - inset^2) / (2 * inset);

rotate ([90, 0, 0]) union () {
    translate ([0, 0, -EPS]) difference () {
        // Main body
        hull () for (x=[-1,1]) for (y=[-1,1]) scale ([x, y, 1]) {
            fillet = TOP_HEIGHT;
            r = TOP_HEIGHT/2;
            disp = CAP_SIZE / 2 - r - r/sqrt(2);
            translate ([disp, disp, 0]) {
                rotate ([0, 0, 45]) rotate ([90, 0, 0]) {
                    rotate_extrude (angle=90) {
                        translate ([r, 0, 0]) circle (r=r);
                    }
                }
            }
        }

        // Spherical groove
        diag = sqrt(2) * CAP_SIZE/2;
        x = cdist(diag, CURVE_IN);
        intersection () {
            translate ([0, 0, x + TOP_HEIGHT]) rotate ([90, 0, 0]) {
                sphere (r=(x+CURVE_IN), $fn=300);
            }
            box ([CAP_SIZE, CAP_SIZE, TOP_HEIGHT+EPS], [1, 1, 0]);
        }
    }
    // Stem
    translate ([0, OFFCENTER, 0]) scale ([1, 1, -1]) {
        hull () {
            box ([10, 4.5, EPS], [1, 1, 0]);
            box ([10-STEM_BASE*2, 4.5-STEM_BASE*2, STEM_BASE], [1, 1, 0]);
        }
        // Stem legs
        for (x=[-1, 1]) scale ([x, 1, 1]) translate ([2.85, 0, 0]) {
            xsz = 0.95 - /* tolerance */ 0.15;
            ysz = 2.75;
            zsz = 3.9+STEM_BASE;
            w = cdist(ysz/4, STEM_CYLOUT);
            box ([xsz, ysz, zsz], [1, 1, 0]);
            for (r=[-1,1]) scale ([r, r, 1]) intersection () {
                translate ([-xsz/2, 0, 0]) box ([INF, INF, INF], [2, 1, 1]);
                translate ([w-xsz/2, ysz/4, 0]) {
                    cylinder (zsz, r=w+STEM_CYLOUT);
                }
            }
        }
    }
    // Rim
    scale ([1, 1, -1]) {
        r = TOP_HEIGHT/2;
        difference () {
            round_slab ([CAP_SIZE, CAP_SIZE, BORDER_H], r);
            hull () {
                sz = CAP_SIZE - BORDER_W;
                round_slab ([CAP_SIZE, CAP_SIZE, EPS], r, BORDER_W * 1.75);
                translate ([0, 0, BORDER_H+EPS]) {
                    round_slab ([CAP_SIZE, CAP_SIZE, EPS], r, BORDER_W);
                }
            }
        }
    }
}
