// Parametric Pottery Mug Cutter Generator v2
// MakerWorld / OpenSCAD friendly version
//
// Generates printable slab-building cutters for mugs:
// - body cutter
// - bottom cutter
// - handle cutter
//
// Designed to be shared online with simple dropdowns and safe parameters.

/////////////////////////////
// OUTPUT
/////////////////////////////

/* [Output] */
part_to_render = "all";          // [all, body, bottom, handle]
show_labels = true;
layout_gap = 20;

/////////////////////////////
// MUG SIZE
/////////////////////////////

/* [Mug Size] */
mug_height = 95;
mug_top_diameter = 88;
mug_bottom_diameter = 82;
clay_shrink_pct = 7.5;
seam_overlap = 4;

/////////////////////////////
// BODY STYLE
/////////////////////////////

/* [Body Style] */
body_style = "bell";             // [straight, tapered, bell, camp, latte]
body_curve_steps = 36;

/* [Body Shape Tuning] */
body_top_inset = 7;               // narrower top (per side) for tapered / bell / camp / latte
body_base_inset = 4;              // narrower base (per side) for bell / camp / latte
body_belly_amount = 8;            // widest bulge amount for bell / camp
body_belly_height = 0.45;         // 0.20 to 0.75
body_corner_radius = 10;          // used for straight body
latte_softness = 0.65;            // 0.1 to 0.95, higher = softer latte flare
camp_shoulder = 0.28;             // 0.10 to 0.45, where camp mug starts to straighten

/////////////////////////////
// BOTTOM
/////////////////////////////

/* [Bottom] */
bottom_shape = "circle";         // [circle, oval]
bottom_oval_scale = 0.88;
foot_ring_mode = "none";         // [none, guide]
foot_ring_diameter = 58;
foot_ring_width = 7;

/////////////////////////////
// HANDLE
/////////////////////////////

/* [Handle] */
handle_style = "arched";         // [arched, strap, block]
handle_length = 118;
handle_width = 22;
handle_inner_length = 82;
handle_inner_width = 11;
handle_slot_radius = 8;
handle_block_depth = 22;

/////////////////////////////
// CUTTER GEOMETRY
/////////////////////////////

/* [Cutter Geometry] */
cutter_height = 15;
cutting_wall = 0.9;
rim_wall = 2.4;
rim_height = 4;
label_size = 6;
$fn = 72;

/////////////////////////////
// DERIVED VALUES
/////////////////////////////

scale_factor = 1 + clay_shrink_pct / 100;
scaled_height = mug_height * scale_factor;
scaled_top_d = mug_top_diameter * scale_factor;
scaled_bottom_d = mug_bottom_diameter * scale_factor;
scaled_handle_length = handle_length * scale_factor;
scaled_handle_width = handle_width * scale_factor;
scaled_handle_inner_length = handle_inner_length * scale_factor;
scaled_handle_inner_width = handle_inner_width * scale_factor;
scaled_slot_radius = handle_slot_radius * scale_factor;
scaled_corner_radius = body_corner_radius * scale_factor;
scaled_top_inset = body_top_inset * scale_factor;
scaled_base_inset = body_base_inset * scale_factor;
scaled_belly_amount = body_belly_amount * scale_factor;
scaled_seam_overlap = seam_overlap * scale_factor;
scaled_handle_block_depth = handle_block_depth * scale_factor;
scaled_foot_ring_diameter = foot_ring_diameter * scale_factor;
scaled_foot_ring_width = foot_ring_width * scale_factor;

bottom_major = scaled_bottom_d;
bottom_minor = scaled_bottom_d * bottom_oval_scale;

// For slab cutters, body width is approximate wrap width.
// This is intentionally simple and user-friendly for shared online tools.
body_width = ((PI * scaled_top_d) + (PI * scaled_bottom_d)) / 2 + scaled_seam_overlap;
body_height = scaled_height;

/////////////////////////////
// MAIN
/////////////////////////////

if (part_to_render == "body") {
    body_cutter();
} else if (part_to_render == "bottom") {
    bottom_cutter();
} else if (part_to_render == "handle") {
    handle_cutter();
} else {
    layout_all();
}

/////////////////////////////
// HELPERS
/////////////////////////////

function clamp01(v) = v < 0 ? 0 : (v > 1 ? 1 : v);
function lerp(a, b, t) = a + (b - a) * t;

module layout_all() {
    translate([0, 0, 0])
        body_cutter();

    translate([body_width/2 + max(bottom_major, scaled_foot_ring_diameter)/2 + layout_gap, 0, 0])
        bottom_cutter();

    translate([0, -(max(body_height, scaled_handle_length)/2 + 42), 0])
        handle_cutter();
}

module cutter_profile() {
    difference() {
        offset(delta = cutting_wall/2) children();
        offset(delta = -cutting_wall/2) children();
    }
}

module cutter_from_child(label="") {
    union() {
        linear_extrude(height = cutter_height)
            cutter_profile() children(0);

        translate([0, 0, cutter_height - rim_height])
            linear_extrude(height = rim_height)
                difference() {
                    offset(delta = rim_wall/2) children(0);
                    offset(delta = -rim_wall/2) children(0);
                }

        if (show_labels && label != "")
            translate([0, 0, cutter_height - 0.5])
                linear_extrude(height = 0.5)
                    text(label, size = label_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
}

module rounded_rect_2d(w, h, r) {
    rr = min(r, min(w, h) / 2 - 0.01);
    hull() {
        translate([-(w/2-rr), -(h/2-rr)]) circle(r = rr);
        translate([ (w/2-rr), -(h/2-rr)]) circle(r = rr);
        translate([-(w/2-rr),  (h/2-rr)]) circle(r = rr);
        translate([ (w/2-rr),  (h/2-rr)]) circle(r = rr);
    }
}

/////////////////////////////
// BODY PROFILES
/////////////////////////////

function bell_width(t) =
    let(
        tt = clamp01(t),
        base_w = body_width - 2 * scaled_base_inset,
        top_w = body_width - 2 * scaled_top_inset,
        belly_w = body_width + scaled_belly_amount,
        yh = clamp01(body_belly_height)
    )
    tt <= yh
        ? lerp(base_w/2, belly_w/2, sin((tt / max(yh, 0.001)) * 90))
        : lerp(belly_w/2, top_w/2, sin(((tt - yh) / max(1 - yh, 0.001)) * 90));

function tapered_width(t) =
    let(
        tt = clamp01(t),
        base_w = body_width,
        top_w = max(body_width - 2 * scaled_top_inset, body_width * 0.72)
    )
    lerp(base_w/2, top_w/2, tt);

function camp_width(t) =
    let(
        tt = clamp01(t),
        base_w = body_width - 2 * scaled_base_inset,
        belly_w = body_width + scaled_belly_amount * 0.35,
        top_w = body_width - 2 * scaled_top_inset,
        shoulder = clamp01(camp_shoulder)
    )
    tt < shoulder
        ? lerp(base_w/2, belly_w/2, sin((tt / max(shoulder, 0.001)) * 90))
        : lerp(belly_w/2, top_w/2, (tt - shoulder) / max(1 - shoulder, 0.001));

function latte_width(t) =
    let(
        tt = clamp01(t),
        base_w = body_width - 2 * scaled_base_inset,
        top_w = body_width - 2 * scaled_top_inset + scaled_belly_amount * 0.25,
        s = clamp01(latte_softness)
    )
    lerp(base_w/2, top_w/2, pow(tt, 1 - s * 0.75));

function straight_width(t) = body_width / 2;

function profile_half_width(t) =
    body_style == "straight" ? straight_width(t) :
    body_style == "tapered" ? tapered_width(t) :
    body_style == "camp" ? camp_width(t) :
    body_style == "latte" ? latte_width(t) :
    bell_width(t);

module body_profile_2d() {
    if (body_style == "straight") {
        rounded_rect_2d(body_width, body_height, scaled_corner_radius);
    } else {
        curved_body_2d();
    }
}

module curved_body_2d() {
    steps = max(12, body_curve_steps);
    h = body_height;

    pts_right = [
        for (i = [0 : steps])
            [ profile_half_width(i / steps), -h/2 + (i / steps) * h ]
    ];

    pts_left = [
        for (i = [steps : -1 : 0])
            [ -profile_half_width(i / steps), -h/2 + (i / steps) * h ]
    ];

    polygon(points = concat(pts_right, pts_left));
}

/////////////////////////////
// PARTS
/////////////////////////////

module body_cutter() {
    cutter_from_child(str("BODY ", round(body_width), "x", round(body_height)))
        body_profile_2d();
}

module bottom_cutter() {
    union() {
        if (bottom_shape == "circle") {
            cutter_from_child(str("BOTTOM ", round(bottom_major), " DIA"))
                circle(d = bottom_major);
        } else {
            cutter_from_child(str("BOTTOM ", round(bottom_major), "x", round(bottom_minor)))
                scale([1, bottom_minor / bottom_major]) circle(d = bottom_major);
        }

        if (foot_ring_mode == "guide") {
            translate([0, 0, 0])
                linear_extrude(height = 1.2)
                    difference() {
                        circle(d = scaled_foot_ring_diameter);
                        circle(d = max(1, scaled_foot_ring_diameter - 2 * scaled_foot_ring_width));
                    }
        }
    }
}

module handle_cutter() {
    if (handle_style == "strap") {
        cutter_from_child(str("HANDLE ", round(scaled_handle_length), "x", round(scaled_handle_width)))
            square([scaled_handle_length, scaled_handle_width], center = true);
    } else if (handle_style == "block") {
        cutter_from_child("HANDLE BLOCK")
            rounded_rect_2d(scaled_handle_block_depth, scaled_handle_width, scaled_handle_width * 0.22);
    } else {
        cutter_from_child("HANDLE")
            handle_arch_2d();
    }
}

/////////////////////////////
// HANDLE SHAPES
/////////////////////////////

module rounded_slot_2d(len, wid, rad) {
    rr = min(rad, min(len, wid) / 2 - 0.01);
    hull() {
        translate([-(len/2-rr), 0]) circle(r = rr);
        translate([ (len/2-rr), 0]) circle(r = rr);
    }
}

module handle_arch_2d() {
    difference() {
        hull() {
            translate([-(scaled_handle_length/2 - scaled_handle_width/2), 0])
                circle(d = scaled_handle_width);
            translate([(scaled_handle_length/2 - scaled_handle_width/2), 0])
                circle(d = scaled_handle_width);
        }
        rounded_slot_2d(scaled_handle_inner_length, scaled_handle_inner_width, scaled_slot_radius);
    }
}
