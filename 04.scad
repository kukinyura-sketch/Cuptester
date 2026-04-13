// Slip-Cast Hybrid Generator v13.9
// СБОРКА: Слияние желтых стенок по центральной оси (Y-middle = 0)
// ИСПРАВЛЕНИЕ: Толщина дна голубой детали увеличена до 10мм для прочности

/* [Основные настройки] */
view_mode = "all"; // [catalog, mug, master, all]
cut_view = true; 

/* [Параметры изделия] */
cup_shape = "camp"; 
mug_height = 95; 
top_diameter = 70; 
bottom_diameter = 50; 

/* [Геометрия и усадка] */
shrinkage = 7.5; 
wall_thickness = 4; 
bottom_extra = 2; 

/* [Тонкая настройка формы] */
belly_pos = 0.45; 
shape_intensity = 1.0; 

/* [Технические параметры формы] */
bottom_radius = 12; 
bottom_concave = 3.5; 
trim_margin = 15; 
draft_angle = 5; 

/* [Скрытые параметры] */
$fn = 40; 
s = 1 + (shrinkage / 100);
h_m = mug_height * s;
h_t = (mug_height + trim_margin) * s;
w_s = wall_thickness * s;
b_s = (wall_thickness + bottom_extra) * s; 
BR_S = bottom_radius * s; 
eps = 0.05; 

shapes = ["straight", "tapered", "bell", "tulip", "barrel", "latte", "camp"];
shape_names = ["ЦИЛИНДР", "КОНУС", "КОЛОКОЛ", "ТЮЛЬПАН", "БОЧКА", "ЛАТТЕ", "КЕМПИНГ"];

// --- 1. МОДУЛИ ---

module pins_lock(d, h_total) {
    translate([0, 3 + d/2, -eps]) cylinder(h = h_total + 2*eps, d = d);
    translate([0, 3 + d + 3 + d/2, -eps]) cylinder(h = h_total + 2*eps, d = d);
}

module plate_with_spheres(pd, pcl, pth, ht, use_extra=false, sh="bell") {
    r_s = 7.5; off = 15;
    difference() {
        union() {
            cube([160, pth, ht]); 
            if (use_extra) {
                translate([off, 0, off]) sphere(r = r_s);
                translate([off, 0, ht - off]) sphere(r = r_s);
                intersection() {
                    translate([80, 0, 0]) color("Goldenrod") union() {
                        render_body(ht, false, sh);
                        translate([0, 0, h_m]) rotate_extrude() {
                            rt = get_radius(1, sh);
                            polygon([[0,0], [rt,0], [rt+trim_margin*tan(draft_angle)*s, trim_margin*s], [0, trim_margin*s]]);
                        }
                    }
                    translate([-20, -150, -5]) cube([200, 150 + eps, ht + 10]);
                }
            }
        }
        translate([0, 0, -eps]) pins_lock(pd + pcl, ht);
        translate([160, 0, -eps]) pins_lock(pd + pcl, ht);
        if (use_extra) {
            translate([160 - off, 0, off]) sphere(r = r_s + 0.2);
            translate([160 - off, 0, ht - off]) sphere(r = r_s + 0.2);
        }
    }
}

module green_frame(pd, pth, ht, gw, xw, yd) {
    union() {
        difference() {
            cube([xw, yd, ht]);
            translate([gw, gw, gw]) cube([160, yd + 1, ht + 1]);
        }
        translate([gw, yd - pth, 0]) union() {
            translate([-3, 0, 0]) cube([3, pth, ht]);
            pins_lock(pd, ht);
        }
        translate([xw - gw, yd - pth, 0]) union() {
            cube([3, pth, ht]);
            mirror([1,0,0]) pins_lock(pd, ht);
        }
    }
}

// --- 2. МАТЕМАТИКА ---

function get_radius(t, sh) = 
    let(rt=(top_diameter*s)/2, rb=(bottom_diameter*s)/2+BR_S, base_r=rb+(rt-rb)*t, int=shape_intensity*12*s, bp=belly_pos, r_max=max(rt,rb)+int)
    sh=="straight"?rt:sh=="tapered"?base_r:
    sh=="bell"?(t<bp?rb+(rb+int-rb)*sin((t/bp)*90):rt+(r_max-rt)*pow(cos(((t-bp)/(1-bp))*90),0.7)):
    sh=="tulip"?(base_r)+sin(t*180)*int*0.7:sh=="barrel"?(base_r)+int*sin(t*180):
    sh=="latte"?let(lh=0.85)(t<lh?rb+(rt*0.92-rb)*pow(t/lh,1.5):rt*0.92+(rt-rt*0.92)*sin(((t-lh)/(1-lh))*90)):
    sh=="camp"?(t<bp?rb+(r_max-rb)*sin((t/bp)*90):rt+(r_max-rt)*cos(((t-bp)/(1-bp))*90)):base_r;

function calculate_r(z, rt_trim, br, sh) = 
    let(t = min(z/h_m, 1), r_b = get_radius(t, sh), 
        c = (z < br && br > 0) ? (br - sqrt(max(0, pow(br, 2) - pow(br - z, 2)))) : 0) r_b - c;

module render_body(h_limit, is_inside, sh) {
    steps=40; rt=get_radius(1,sh); z_s=is_inside?b_s:0;
    for (i=[0:steps-1]) {
        let(z1=z_s+(i/steps)*(h_limit-z_s), z2=z_s+((i+1)/steps)*(h_limit-z_s),
            r1=calculate_r(z1,rt,BR_S,sh)-(is_inside?w_s:0), r2=calculate_r(z2,rt,BR_S,sh)-(is_inside?w_s:0))
        if(r1>0) hull(){translate([0,0,z1])cylinder(h=0.1,r=r1); translate([0,0,z2])cylinder(h=0.1,r=r2);}
    }
}

module single_mug(sh, name) {
    difference(){
        union(){
            difference(){render_body(h_m, false, sh); translate([0,0,-eps]) concave_bottom(); render_body(h_m+2, true, sh);}
            translate([0, -bottom_diameter*s - 45, 0]) color("Black") text(name, size=8*s, halign="center", font="Golos UI:style=Bold");
        }
        if (cut_view) translate([-200, -200, -eps]) cube([400, 200, h_m + 50]);
    }
}

module concave_bottom() {
    rc=(bottom_diameter*s)/2-BR_S*0.4; hc=bottom_concave*s;
    if(hc>0) intersection(){cylinder(h=hc+eps,r=rc*1.5); translate([0,0,-hc*0.15]) scale([1,1,hc/rc]) sphere(r=rc);}
}

// --- 3. ГЛАВНАЯ ЛОГИКА ---

if (view_mode == "catalog") {
    spacing = 180 * s;
    for (i = [0:len(shapes)-1]) translate([i*spacing - (3*spacing), 0, 0]) single_mug(shapes[i], shape_names[i]);
} 
else if (view_mode == "mug") {
    single_mug(cup_shape, "ИЗДЕЛИЕ");
}
else {
    p_d = 3; p_cl = 0.2; p_th = 15; gw = 3; 
    bottom_case_thickness = 10; // Толщина дна синей детали увеличена до 10мм
    
    outer_x_w = 160 + (gw * 2); 
    r_base_mug = get_radius(0, cup_shape); 
    green_y_d = p_th + r_base_mug + 30;
    cast_depth = green_y_d - p_th;    
    total_depth = cast_depth * 2; 

    // СТАНЦИЯ 0 (Мастер-модель)
    if (view_mode == "all" || view_mode == "master") color("Goldenrod") difference() {
        union() { render_body(h_t, false, cup_shape); translate([0, 0, h_m]) rotate_extrude() { rt = get_radius(1, cup_shape); polygon([[0,0], [rt,0], [rt+trim_margin*tan(draft_angle)*s, trim_margin*s], [0, trim_margin*s]]); } }
        translate([0, 0, -eps]) concave_bottom();
        if (cut_view) translate([-200, 0, -eps]) cube([400, 200, h_t + 50]);
    }

    if (view_mode == "all") {
        // СТАНЦИЯ 1 (X=300)
        translate([300 - 80, 0, 0]) color("IndianRed") plate_with_spheres(p_d, p_cl, p_th, h_t, false, cup_shape);
        translate([300 - 80 - gw, -200, 0]) color("Green") green_frame(p_d, p_th, h_t, gw, outer_x_w, green_y_d);

        // СТАНЦИЯ 2 (X=600)
        translate([600 - 80, 0, 0]) color("Yellow") plate_with_spheres(p_d, p_cl, p_th, h_t, true, cup_shape);
        translate([600 - 80 - gw, -200, 0]) color("RoyalBlue") green_frame(p_d, p_th, h_t, gw, outer_x_w, green_y_d);

        // СТАНЦИЯ 3 (X=900): ГОЛУБОЙ КЕЙС (ПУСТОЙ)
        translate([900 - outer_x_w/2, -total_depth/2, 0]) color("Cyan") difference() {
            cube([outer_x_w, total_depth, 30 + (bottom_case_thickness-gw)]); 
            translate([gw, gw, bottom_case_thickness]) cube([160, total_depth - gw*2, 40]); 
        }

        // СТАНЦИЯ 4 (X=1250): СБОРКА
        translate([1250, 0, 0]) difference() {
            union() {
                translate([-outer_x_w/2, -total_depth/2, 0]) color("Cyan") difference() {
                    cube([outer_x_w, total_depth, 30 + (bottom_case_thickness-gw)]);
                    translate([gw, gw, bottom_case_thickness]) cube([160, total_depth - gw*2, 40]);
                }
                translate([-outer_x_w/2, -p_th/2 - cast_depth, 30 + (bottom_case_thickness-gw)]) color("RoyalBlue") green_frame(p_d, p_th, h_t, gw, outer_x_w, green_y_d);
                translate([-80, -p_th/2, 30 + (bottom_case_thickness-gw)]) color("Yellow") plate_with_spheres(p_d, p_cl, p_th, h_t, true, cup_shape);
                translate([outer_x_w/2, p_th/2 + cast_depth, 30 + (bottom_case_thickness-gw)]) rotate([0, 0, 180]) {
                    color("RoyalBlue") green_frame(p_d, p_th, h_t, gw, outer_x_w, green_y_d);
                    translate([gw, cast_depth, 0]) color("Yellow") plate_with_spheres(p_d, p_cl, p_th, h_t, true, cup_shape);
                }
            }
            if (cut_view) translate([0, -total_depth, -eps]) cube([300, total_depth*2, h_t + 100]);
        }

        // СТАНЦИЯ 5 (X=1650): ДЕТАЛЬ ДНА (ДНО 10мм)
        translate([1650 - outer_x_w/2, -total_depth/2, 0]) color("Cyan") difference() {
            cube([outer_x_w, total_depth, 30 + (bottom_case_thickness-gw)]); 
            translate([gw, gw, bottom_case_thickness]) cube([160, total_depth - gw*2, 40]); 
            translate([outer_x_w/2, total_depth/2, bottom_case_thickness - eps]) {
                rc = (bottom_diameter * s) / 2 - BR_S * 0.4;
                hc = bottom_concave * s;
                if(hc > 0) scale([1, 1, hc / rc]) sphere(r = rc + 0.2);
            }
        }

        // СТАНЦИЯ 6 (X=2050): РАЗРЕЗ ДЕТАЛИ ДНА
        translate([2050 - outer_x_w/2, -total_depth/2, 0]) color("DeepSkyBlue") difference() {
            union() {
                difference() {
                    cube([outer_x_w, total_depth, 30 + (bottom_case_thickness-gw)]); 
                    translate([gw, gw, bottom_case_thickness]) cube([160, total_depth - gw*2, 40]); 
                    translate([outer_x_w/2, total_depth/2, bottom_case_thickness - eps]) {
                        rc = (bottom_diameter * s) / 2 - BR_S * 0.4;
                        hc = bottom_concave * s;
                        if(hc > 0) scale([1, 1, hc / rc]) sphere(r = rc + 0.2);
                    }
                }
            }
            translate([-eps, total_depth/2, -eps]) cube([outer_x_w + 2*eps, total_depth, 50]);
        }
    }
}
