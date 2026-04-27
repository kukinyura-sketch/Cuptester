// ===================================================================
// Slip-Cast Generator v1.6
// Генератор форм для шликерного литья
// ===================================================================
// ПОРЯДОК: Пресет → Масштаб (visual_scale) → Усадка (shrinkage)
// ===================================================================

use <Presets.scad>;

// openscad
// ===================================================================
// 1. ВИДИМЫЕ НАСТРОЙКИ (ТОЛЬКО ЭТО В ПАНЕЛИ CUSTOMIZER)
// ===================================================================

view_mode = "all"; // [catalog:"Каталог форм", mug:"Готовая кружка", master:"Мастер-модель", all:"Вся оснастка"]
cut_view = false; // [true:"Включить разрез", false:"Выключить разрез"]
preset_id = 1; // [1:1:100]
visual_scale = 100; // [50:1:150]
shrinkage = 7.5; // [0:0.5:20]
fixture_width_preset = 160; // [120:"Малая (120мм)", 160:"Средняя (160мм)", 180:"Большая (180мм)", 200:"Макси (200мм)", 0:"Своя"]
show_plaster_calc = false; // [true:"Показать расчёт гипса", false:"Скрыть"]
show_station2 = true; // [true:"Показать станцию 2", false:"Скрыть"]

// ===================================================================
// 2. СКРЫТЫЕ ПАРАМЕТРЫ (НЕ ПОЯВЛЯЮТСЯ В ПАНЕЛИ)
// ===================================================================

/* [Hidden] */

trim_margin = 15;
draft_angle = 5;
sphere_compensation = 1.5;
front_wall_thickness = 3;
back_wall_thickness = 1.6;
yellow_plate_thickness = 15;
max_formwork_height = 150;
master_plate_extra_height = 30;
formwork_base_thickness = 5;
formwork_base_margin = 5;
bottom_case_thickness = 10;
bottom_radius = 3;
bottom_concave = 0.5;
flat_rim = 3;
wall_thickness = 4;
bottom_extra = 2;
p_d = 3;
p_cl = 0.2;
p_th = yellow_plate_thickness;
sphere_radius = 7.5;
sphere_offset_x = 15;
sphere_height_bottom = 7.5;
pyramid_size = 15;
pyramid_height = 5;
pyramid_offset = 20;
dovetail_width = 20;
dovetail_depth = 10;
dovetail_height = 50;
dovetail_angle = 20;
dovetail_gap = 0.2;
fixture_width_custom = 160;
// ===================================================================
// 3. ОПРЕДЕЛЕНИЕ ФОРМЫ ПО ID ПРЕСЕТА
// ===================================================================

function get_shape_from_id(id) =
    (id <= 17) ? "bell" :
    (id <= 34) ? "barrel" :
    (id <= 51) ? "tulip" :
    (id <= 68) ? "straight" :
    (id <= 84) ? "latte" : "camp";

cup_shape = get_shape_from_id(preset_id);

// ===================================================================
// 4. РАСЧЁТ ПАРАМЕТРОВ (Пресет → Масштаб → Усадка)
// ===================================================================

_preset_params = get_preset(preset_id);
h_clean = _preset_params[0];
td_clean = _preset_params[1];
bd_clean = _preset_params[2];
bp_clean = _preset_params[3];
si_clean = _preset_params[4];
br_clean = _preset_params[5];
bc_clean = _preset_params[6];

scale_factor = visual_scale / 100;
h_scaled = h_clean * scale_factor;
td_scaled = td_clean * scale_factor;
bd_scaled = bd_clean * scale_factor;

s = 1 + (shrinkage / 100);
h_m = h_scaled * s;
h_t = (h_scaled + trim_margin) * s;
top_diameter_final = td_scaled * s;
bottom_diameter_final = bd_scaled * s;
belly_pos_final = bp_clean;
shape_intensity_final = si_clean;
bottom_radius_final = br_clean * s;
bottom_concave_final = bc_clean * s;

w_s = wall_thickness * s;
b_s = (wall_thickness + bottom_extra) * s;
BR_S = bottom_radius_final;
eps = 0.05;

// Вывод в консоль
echo(str("═══════════════════════════════════════"));
echo(str("ПРЕСЕТ #", preset_id, " — ", get_preset_family(preset_id)));
echo(str("Форма: ", cup_shape));
echo(str("Масштаб: ", visual_scale, "% → ", round(h_scaled), " мм ДО усадки"));
echo(str("Усадка: ", shrinkage, "% → ИТОГОВАЯ: ", round(h_m), " мм"));
echo(str("═══════════════════════════════════════"));

// Ширина опалубки
fixture_width = (fixture_width_preset == 0) ? fixture_width_custom : fixture_width_preset;

// ===================================================================
// 5. РАСЧЁТЫ ОСНАСТКИ
// ===================================================================

inner_frame_depth = fixture_width / 2;
formwork_total_depth = front_wall_thickness + inner_frame_depth + yellow_plate_thickness + back_wall_thickness;
outer_x_w = fixture_width + (front_wall_thickness * 2);
formwork_height = (max_formwork_height < h_t) ? max_formwork_height : h_t;
yellow_plate_start = front_wall_thickness + inner_frame_depth;
yellow_plate_end = yellow_plate_start + yellow_plate_thickness;
yellow_plate_block_y = yellow_plate_start;
pyramids_y = front_wall_thickness + pyramid_offset + pyramid_size/2;
master_plate_height = h_t + master_plate_extra_height;
sphere_height_top = h_t - sphere_height_bottom;
formwork_y_d = formwork_total_depth;
total_depth = fixture_width;

$fn = $preview ? 180 : 90;

// ===================================================================
// 6. ФУНКЦИИ ГЕОМЕТРИИ
// ===================================================================

function get_radius(t, sh) = 
    let(rt = top_diameter_final / 2, 
        rb = bottom_diameter_final / 2 + BR_S,
        int = shape_intensity_final * 8 * s,
        bp = belly_pos_final)
    sh == "straight" ? rt :
    sh == "bell" ? let(r_max = max(rt, rb) + int, bell_peak = 0.35)
        t <= bell_peak ? rb + (r_max - rb) * sin((t / bell_peak) * 90) :
        r_max - (r_max - rt) * pow((t - bell_peak) / (1 - bell_peak), 1.2) :
    sh == "barrel" ? let(r_max = max(rt, rb) + int * 1.2)
        rb + (r_max - rb) * (1 - pow((t - 0.5) * 2, 2)) :
    sh == "latte" ? let(lip_height = 0.85)
        t >= lip_height ? rt : rb + (rt - rb) * (t / lip_height) * (1 - t * 0.3) :
    sh == "camp" ? let(ring_height = 0.12, ring_thickness = 1.03, body_taper = 0.96)
        t < ring_height ? let(ring_t = t / ring_height, ease = 1 - pow(1 - ring_t, 2))
            rb * (1 + (ring_thickness - 1) * ease) :
            let(body_t = (t - ring_height) / (1 - ring_height), start_r = rb * ring_thickness, end_r = rt * body_taper)
            start_r + (end_r - start_r) * body_t :
    sh == "tulip" ? let(foot_h = 6 / h_m, crown_start = 0.88, flare = 1.06)
        t < foot_h ? let(foot_t = t / foot_h, foot_r = rb * 0.92) foot_r + (rb - foot_r) * pow(foot_t, 1.2) :
        t < crown_start ? let(body_t = (t - foot_h) / (crown_start - foot_h), body_start = rb, body_end = rt * 0.96)
            body_start + (body_end - body_start) * pow(body_t, 1.3) :
            let(crown_t = (t - crown_start) / (1 - crown_start), crown_start_r = rt * 0.96, crown_end_r = rt * flare)
            crown_start_r + (crown_end_r - crown_start_r) * sin(crown_t * 90) :
    rb + (rt - rb) * t;

function calculate_r(z, rt_trim, br, sh) = 
    let(t = min(z / h_m, 1), r_b = get_radius(t, sh),
        c = (z < br && br > 0) ? (br - sqrt(max(0, pow(br, 2) - pow(br - z, 2)))) : 0) 
    r_b - c;

// ===================================================================
// 7. СТРОИТЕЛЬНЫЕ МОДУЛИ
// ===================================================================

module render_body(h_limit, is_inside, sh) {
    steps = $preview ? 60 : 120;
    rt = get_radius(1, sh); 
    z_s = is_inside ? b_s : 0;
    for (i = [0:steps-1]) {
        let(z1 = z_s + (i / steps) * (h_limit - z_s), 
            z2 = z_s + ((i + 1) / steps) * (h_limit - z_s),
            r1 = calculate_r(z1, rt, BR_S, sh) - (is_inside ? w_s : 0), 
            r2 = calculate_r(z2, rt, BR_S, sh) - (is_inside ? w_s : 0))
        if (r1 > 0.01 && r2 > 0.01) 
            hull() {
                translate([0, 0, z1]) cylinder(h = 0.1, r = r1);
                translate([0, 0, z2]) cylinder(h = 0.1, r = r2);
            }
    }
}

module concave_bottom() {
    outer_r = bottom_diameter_final / 2;
    rim_r = outer_r - flat_rim * s;
    hc = bottom_concave_final;
    br = bottom_radius_final;
    translate([0, 0, -eps]) cylinder(r = outer_r, h = 0.2);
    if (hc > 0.3 && rim_r > 2) {
        translate([0, 0, -eps]) difference() {
            cylinder(r = rim_r, h = hc);
            translate([0, 0, -hc * 0.5]) scale([1, 1, 0.6]) sphere(r = rim_r);
        }
    }
    if (br > 0.5) {
        translate([0, 0, -eps]) difference() {
            cylinder(r = outer_r, h = br);
            translate([0, 0, -br]) cylinder(r = outer_r - br, h = br * 2);
        }
    }
}

module pins_lock(pd, pcl, h_total, is_yellow = false) {
    pin_height_boost = is_yellow ? 1.5 : 1.0;
    translate([0, 3 + pd/2, -eps]) cylinder(h = h_total + 2*eps + pin_height_boost, d = pd);
    translate([0, 3 + pd + 3 + pd/2, -eps]) cylinder(h = h_total + 2*eps + pin_height_boost, d = pd);
}

module plate_with_spheres(pd, pcl, pth, ht, use_extra=false, sh="bell") {
    r_s = 7.5;
    off = 15;
    comp = sphere_compensation;
    difference() {
        union() {
            cube([fixture_width, pth, ht]);
            if (use_extra) {
                translate([off, +comp, off]) sphere(r = r_s);
                translate([off, +comp, ht - off]) sphere(r = r_s);
                intersection() {
                    translate([fixture_width/2, 0, 0]) color("Goldenrod") union() {
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
        translate([0, 0, -eps]) pins_lock(pd + pcl, pcl, ht, true);
        translate([fixture_width, 0, -eps]) pins_lock(pd + pcl, pcl, ht, true);
        if (use_extra) {
            translate([fixture_width - off, -comp, off]) sphere(r = r_s + 0.3);
            translate([fixture_width - off, -comp, ht - off]) sphere(r = r_s + 0.3);
        }
    }
}

module truncated_pyramid(base_size, top_size, height) {
    polyhedron(points = [
        [-base_size/2, -base_size/2, 0], [ base_size/2, -base_size/2, 0],
        [ base_size/2,  base_size/2, 0], [-base_size/2,  base_size/2, 0],
        [-top_size/2, -top_size/2, height], [ top_size/2, -top_size/2, height],
        [ top_size/2,  top_size/2, height], [-top_size/2,  top_size/2, height]],
        faces = [[0,1,2,3], [4,5,1,0], [5,6,2,1], [6,7,3,2], [7,4,0,3], [4,5,6,7]]);
}

module inverted_pyramid(base_size, top_size, height) {
    polyhedron(points = [
        [-base_size/2, -base_size/2, 0], [ base_size/2, -base_size/2, 0],
        [ base_size/2,  base_size/2, 0], [-base_size/2,  base_size/2, 0],
        [-top_size/2, -top_size/2, -height], [ top_size/2, -top_size/2, -height],
        [ top_size/2,  top_size/2, -height], [-top_size/2,  top_size/2, -height]],
        faces = [[0,1,2,3], [4,5,1,0], [5,6,2,1], [6,7,3,2], [7,4,0,3], [4,5,6,7]]);
}

module formwork(pd, pcl, pth, ht, xw, yd) {
    top_size = pyramid_size * 0.6;
    union() {
        if (formwork_base_thickness > 0) {
            translate([-formwork_base_margin, -formwork_base_margin, -formwork_base_thickness])
                color("Red") cube([xw + (formwork_base_margin * 2), yd + (formwork_base_margin * 2), formwork_base_thickness]);
        }
        difference() {
            cube([xw, yd, ht]);
            translate([front_wall_thickness, front_wall_thickness, front_wall_thickness]) 
                cube([fixture_width, yd - back_wall_thickness, ht + 1]);
        }
        translate([front_wall_thickness, yellow_plate_block_y, 0]) union() {
            translate([-3, 0, 0]) cube([3, yellow_plate_thickness, ht]);
            pins_lock(pd, pcl, ht, false);
        }
        translate([xw - front_wall_thickness, yellow_plate_block_y, 0]) union() {
            cube([3, yellow_plate_thickness, ht]);
            mirror([1,0,0]) pins_lock(pd, pcl, ht, false);
        }
        translate([0, yellow_plate_end, 0]) cube([xw, back_wall_thickness, ht]);
        translate([front_wall_thickness + pyramid_offset + pyramid_size/2, pyramids_y, 0])
            truncated_pyramid(pyramid_size, top_size, pyramid_height);
        translate([front_wall_thickness + fixture_width - pyramid_offset - pyramid_size/2, pyramids_y, 0])
            truncated_pyramid(pyramid_size, top_size, pyramid_height);
    }
}

module standalone_master_model(shape, h_m, h_t, s, draft_angle, trim_margin) {
    union() { 
        render_body(h_t, false, shape); 
        translate([0, 0, h_m]) rotate_extrude() { 
            rt = get_radius(1, shape); 
            polygon([[0,0], [rt,0], [rt+trim_margin*tan(draft_angle)*s, trim_margin*s], [0, trim_margin*s]]); 
        } 
    }
}

module dovetail_rail_vertical(width, depth, height, angle) {
    linear_extrude(height = height)
        polygon(points = [
            [-width/2, 0], [width/2, 0],
            [width/2 + depth * tan(angle), -depth],
            [-width/2 - depth * tan(angle), -depth]
        ]);
}

module master_plate(pd, pcl, pth, ht, use_extra=false) {
    r_s = 7.5;
    off = 15;
    comp = sphere_compensation;
    ht_original = h_t;
    difference() {
        union() {
            cube([fixture_width, pth, master_plate_height]);
            translate([off, +comp, off]) sphere(r = r_s);
            translate([off, +comp, ht_original - off]) sphere(r = r_s);
            translate([fixture_width - off, -comp, off]) sphere(r = r_s);
            translate([fixture_width - off, -comp, ht_original - off]) sphere(r = r_s);
        }
        translate([0, 0, -0.01]) pins_lock(pd + pcl, pcl, master_plate_height, true);
        translate([fixture_width, 0, -0.01]) pins_lock(pd + pcl, pcl, master_plate_height, true);
        if (use_extra) {
            translate([fixture_width - off, -comp, off]) sphere(r = r_s + 0.3);
            translate([fixture_width - off, -comp, ht_original - off]) sphere(r = r_s + 0.3);
        }
    }
}

// ===================================================================
// 8. РЕЖИМ ALL - ПОЛНАЯ ОСНАСТКА
// ===================================================================

if (view_mode == "all") {
    translate([0, 0, 0]) color("Goldenrod") difference() {
        union() { 
            render_body(h_t, false, cup_shape); 
            translate([0, 0, h_m]) rotate_extrude() { 
                rt = get_radius(1, cup_shape); 
                polygon([[0,0], [rt,0], [rt+trim_margin*tan(draft_angle)*s, trim_margin*s], [0, trim_margin*s]]); 
            } 
        }
        translate([0, 0, -eps]) concave_bottom();
        if (cut_view) translate([-200, 0, -eps]) cube([400, 200, h_t + 50]);
    }
    
    if (show_station2) {
        translate([300, 0, 0]) color("Yellow") plate_with_spheres(p_d, p_cl, p_th, h_t, true, cup_shape);
    }
    
    translate([600, 0, 0]) color("Red") formwork(p_d, p_cl, p_th, formwork_height, outer_x_w, formwork_y_d);
    
    translate([900, -(total_depth + front_wall_thickness*2)/2, 0]) color("DeepSkyBlue") difference() {
        union() {
            difference() {
                cube([outer_x_w, total_depth + front_wall_thickness*2, 30 + (bottom_case_thickness - front_wall_thickness)]); 
                translate([front_wall_thickness, front_wall_thickness, bottom_case_thickness]) 
                    cube([fixture_width, total_depth, 40]); 
                translate([outer_x_w/2, (total_depth + front_wall_thickness*2)/2, bottom_case_thickness - eps]) {
                    rc = bottom_diameter_final / 2 - BR_S * 0.4;
                    hc = bottom_concave_final;
                    if(hc > 0) scale([1, 1, hc / rc]) sphere(r = rc + 0.2);
                }
            }
        }
        top_size = pyramid_size * 0.6;
        translate([front_wall_thickness + pyramid_offset + pyramid_size/2, 
                   front_wall_thickness + pyramid_offset + pyramid_size/2, bottom_case_thickness + 0.1])
            inverted_pyramid(pyramid_size, top_size, pyramid_height);
        translate([front_wall_thickness + fixture_width - pyramid_offset - pyramid_size/2, 
                   front_wall_thickness + pyramid_offset + pyramid_size/2, bottom_case_thickness + 0.1])
            inverted_pyramid(pyramid_size, top_size, pyramid_height);
        translate([front_wall_thickness + pyramid_offset + pyramid_size/2, 
                   front_wall_thickness + total_depth - pyramid_offset - pyramid_size/2, bottom_case_thickness + 0.1])
            inverted_pyramid(pyramid_size, top_size, pyramid_height);
        translate([front_wall_thickness + fixture_width - pyramid_offset - pyramid_size/2, 
                   front_wall_thickness + total_depth - pyramid_offset - pyramid_size/2, bottom_case_thickness + 0.1])
            inverted_pyramid(pyramid_size, top_size, pyramid_height);
    }
    
    translate([-800, 0, 0]) {
        render() difference() {
            color("Orange") intersection() {
                standalone_master_model(cup_shape, h_m, h_t, s, draft_angle, trim_margin);
                translate([0, 500, h_t/2]) cube([1000, 1000, h_t + 200], center = true);
            }
            translate([0, 0, -1]) mirror([0, 1, 0])
                color("DarkOrange") dovetail_rail_vertical(width = dovetail_width + dovetail_gap, depth = dovetail_depth, height = dovetail_height + 1, angle = dovetail_angle);
        }
    }
    
    translate([-450, 0, 0]) {
        color("LightGreen") master_plate(p_d, p_cl, p_th, h_t, true);
        translate([fixture_width/2, 0, 0]) 
            color("Lime") dovetail_rail_vertical(width = dovetail_width, depth = dovetail_depth, height = dovetail_height, angle = dovetail_angle);
    }
}

// ===================================================================
// 9. РЕЖИМ CATALOG - КАТАЛОГ ФОРМ
// ===================================================================

else if (view_mode == "catalog") {
    shapes_list = ["straight", "bell", "barrel", "latte", "camp", "tulip"];
    names_list = ["СТАКАН", "КОЛОКОЛ", "БОЧКА", "ЛАТТЕ", "КЕМПИНГ", "ТЮЛЬПАН"];
    spacing = 110;
    for (i = [0:len(shapes_list)-1]) {
        current_shape = shapes_list[i];
        temp_height = 80;
        temp_bottom = 60;
        translate([i * spacing - (2.5 * spacing), 0, 0]) {
            color("Goldenrod") render_body(temp_height * s, false, current_shape);
            translate([0, -temp_bottom * s - 35, -5]) color("Black") text(names_list[i], size = 7 * s, halign = "center");
            translate([0, -temp_bottom * s - 55, -5]) color("Gray") text(str(temp_height, "мм"), size = 5 * s, halign = "center");
        }
    }
}

// ===================================================================
// 10. РЕЖИМ MUG - ГОТОВАЯ КРУЖКА
// ===================================================================

else if (view_mode == "mug") {
    total_height = h_m;
    if (!cut_view) {
        color("SandyBrown", 0.9) {
            difference() {
                render_body(total_height, false, cup_shape);
                render_body(total_height + 2, true, cup_shape);
            }
        }
        color("Goldenrod") translate([0, 0, -eps]) concave_bottom();
    }
    if (cut_view) {
        intersection() {
            color("SandyBrown", 0.9) {
                difference() {
                    render_body(total_height, false, cup_shape);
                    render_body(total_height + 2, true, cup_shape);
                }
            }
            translate([0, -500, -500]) cube([500, 1000, 1000]);
        }
        intersection() {
            color("Goldenrod") translate([0, 0, -eps]) concave_bottom();
            translate([0, -500, -500]) cube([500, 1000, 1000]);
        }
    }
}

// ===================================================================
// 11. РЕЖИМ MASTER - МАСТЕР-МОДЕЛЬ
// ===================================================================

else if (view_mode == "master") {
    color("Goldenrod") difference() {
        union() { 
            render_body(h_t, false, cup_shape); 
            translate([0, 0, h_m]) rotate_extrude() { 
                rt = get_radius(1, cup_shape); 
                polygon([[0,0], [rt,0], [rt+trim_margin*tan(draft_angle)*s, trim_margin*s], [0, trim_margin*s]]); 
            } 
        }
        if (cut_view) translate([-200, 0, -eps]) cube([400, 200, h_t + 50]);
    }
}
