// Slip-Cast Hybrid Generator v15.4 - ПРЕМИУМ ВЕРСИЯ
// FIX v15.4: УДАЛЕНА МЕТКА ОБРЕЗКИ (cut_mark)

// 1. ВЫБОР ВИДА

view_mode = "all"; // [catalog:КАТАЛОГ ВСЕХ ФОРМ, mug:ИЗДЕЛИЕ, master:МАСТЕР-МОДЕЛЬ, all:ВСЯ ОСНАСТКА]
cut_view = false; // [true:ВКЛЮЧИТЬ РАЗРЕЗ, false:ВЫКЛЮЧИТЬ РАЗРЕЗ]

// 2. ПРОФИЛЬ ФОРМЫ

cup_shape = "barrel"; // ["straight":"🥤 СТАКАН (цилиндр)", "bell":"🔔 КОЛОКОЛ (S-образный)", "barrel":"🍺 БОЧКА (пузатая)", "latte":"☕ ЛАТТЕ (прямой бортик)", "camp":"🏕️ КЕМПИНГ (низкий, широкий)", "tulip":"🌷 ТЮЛЬПАН (ЛФЗ, чайная)"]

// 3. БАЗОВЫЕ ПАРАМЕТРЫ ФОРМЫ

function get_shape_canonical(shape) =
    shape == "straight" ? [90, 75, 75, 0.50, 0.0, 8, 2.0, 0] :
    shape == "bell" ?     [95, 72, 52, 0.35, 1.0, 12, 3.5, 0] :
    shape == "barrel" ?   [100, 68, 68, 0.50, 1.5, 10, 3.0, 0] :
    shape == "latte" ?    [85, 88, 58, 0.85, 0.6, 15, 4.0, 0] :
    shape == "camp" ?     [80, 85, 75, 0.45, 0.3, 10, 2.5, 6] :
    shape == "tulip" ?    [73, 92, 47, 0.55, 1.2, 8, 2.5, 9] :
    [90, 75, 65, 0.45, 0.8, 10, 3.0, 0];

_canonical = get_shape_canonical(cup_shape);
mug_height_base = _canonical[0];
top_diameter_base = _canonical[1];
bottom_diameter_base = _canonical[2];
belly_pos_base = _canonical[3];
shape_intensity_base = _canonical[4];
bottom_radius_base = _canonical[5];
bottom_concave_base = _canonical[6];
foot_height_base = _canonical[7];

// 4. РУЧНЫЕ НАСТРОЙКИ

manual_height = 50; // [0:50:200] 0 = использовать базовый
manual_top_dia = 0; // [0:30:150] 0 = использовать базовый
manual_bottom_dia = 0; // [0:20:120] 0 = использовать базовый
manual_belly_pos = 0; // [0:0.2:0.8] 0 = авто-масштабирование
manual_intensity = -1; // [-1:0.1:2.5] -1 = авто-масштабирование

// 5. УСАДКА И ТОЛЩИНА СТЕНКИ

shrinkage = 7.5; // [0:0.5:20] Усадка глины (%)
wall_thickness = 4; // [1:0.5:10] Толщина стенки (мм)
bottom_extra = 2; // [0:0.5:8] Дополнительная толщина дна (мм)

// 6. ПРОПОРЦИИ (ПРЕСЕТЫ)

proportion_preset = "custom"; // ["custom":"🔧 БЕЗ ПРЕСЕТА", "golden":"✨ ЗОЛОТОЕ СЕЧЕНИЕ", "classic":"🏛️ КЛАССИКА", "espresso":"☕ ЭСПРЕССО", "cappuccino":"🍮 КАПУЧИНО"]

// 7. ГЕОМЕТРИЯ ИЗГИБА

belly_pos = 0.50; // [0.2:0.01:0.8] Положение максимальной ширины
shape_intensity = 1.5; // [0:0.1:2.5] Интенсивность изгиба

// 8. ДНО КРУЖКИ (ПРОСТЫЕ РУЧНЫЕ НАСТРОЙКИ)

bottom_radius = 3; // [0:1:15] Скругление дна (мм) - для бочки 50мм ставьте 2-3
bottom_concave = 0.5; // [0:0.5:8] Вогнутость дна (мм) - 0 = плоское
flat_rim = 3; // [0:1:8] Плоский бортик по краю дна (мм)

// 9. ТЕХНИЧЕСКИЕ ПАРАМЕТРЫ

trim_margin = 15; // [5:1:30] Запас на обрезку (мм)
draft_angle = 5; // [0:1:15] Угол уклона (градусы)
$fn = $preview ? 48 : 80;

// 10. КОМПЕНСАЦИЯ СФЕР
sphere_compensation = 1.5; // [0:0.1:3]

// ═══════════════════════════════════════════════════════════════════
// РАСЧЁТ ПАРАМЕТРОВ
// ═══════════════════════════════════════════════════════════════════

function apply_proportion_preset(preset, h, td, bd, bp, si) = 
    preset == "golden" ? [h, td, td/1.618, 0.382, 0.8] :
    preset == "classic" ? [h, td, td/1.4, 0.45, 0.5] :
    preset == "espresso" ? [h*1.2, td, td/1.8, 0.3, 0.4] :
    preset == "cappuccino" ? [h, td, td/1.5, 0.42, 0.6] :
    [h, td, bd, bp, si];

use_manual = manual_height > 0;
use_manual_dia = manual_top_dia > 0;
use_manual_bottom = manual_bottom_dia > 0;

h_base = use_manual ? manual_height : mug_height_base;
td_base = use_manual_dia ? manual_top_dia : top_diameter_base;
bd_base = use_manual_bottom ? manual_bottom_dia : bottom_diameter_base;

height_ratio = h_base / mug_height_base;
safe_ratio = max(height_ratio, 0.3);

scaled_intensity = shape_intensity_base * (1 / safe_ratio) * 0.7;

bp_base = manual_belly_pos > 0 ? manual_belly_pos : belly_pos_base;
si_base = manual_intensity >= 0 ? manual_intensity : scaled_intensity;

// Применяем пресет пропорций
_preset_applied = proportion_preset != "custom" ? 
    apply_proportion_preset(proportion_preset, h_base, td_base, bd_base, bp_base, si_base) :
    [h_base, td_base, bd_base, bp_base, si_base];

mug_height_final = _preset_applied[0];
top_diameter_final = _preset_applied[1];
bottom_diameter_final = _preset_applied[2];
belly_pos_final = _preset_applied[3];
shape_intensity_final = _preset_applied[4];

// Параметры дна (простые, без авто-логики)
bottom_radius_final = bottom_radius;
bottom_concave_final = bottom_concave;
foot_height_final = foot_height_base;

s = 1 + (shrinkage / 100);
h_m = mug_height_final * s;
h_t = (mug_height_final + trim_margin) * s;
w_s = wall_thickness * s;
b_s = (wall_thickness + bottom_extra) * s; 
BR_S = bottom_radius_final * s; 
eps = 0.05; 

// ГЕОМЕТРИЯ ФОРМ

function get_radius(t, sh) = 
    let(rt = (top_diameter_final * s) / 2, 
        rb = (bottom_diameter_final * s) / 2 + BR_S,
        int = shape_intensity_final * 8 * s,
        bp = belly_pos_final)
    
    sh == "straight" ? 
        rt :
        
    sh == "bell" ? 
        let(r_max = max(rt, rb) + int,
            bell_peak = 0.35)
        t <= bell_peak ? 
            rb + (r_max - rb) * sin((t / bell_peak) * 90) :
            r_max - (r_max - rt) * pow((t - bell_peak) / (1 - bell_peak), 1.2) :
        
    sh == "barrel" ? 
        let(r_max = max(rt, rb) + int * 1.2)
        rb + (r_max - rb) * (1 - pow((t - 0.5) * 2, 2)) :
        
    sh == "latte" ? 
        let(lip_height = 0.85)
        t >= lip_height ?
            rt :
            rb + (rt - rb) * (t / lip_height) * (1 - t * 0.3) :
        
    sh == "camp" ? 
        let(ring_height = 0.12,
            ring_thickness = 1.03,
            body_taper = 0.96)
        t < ring_height ?
            let(ring_t = t / ring_height,
                ease = 1 - pow(1 - ring_t, 2))
            rb * (1 + (ring_thickness - 1) * ease) :
            let(body_t = (t - ring_height) / (1 - ring_height),
                start_r = rb * ring_thickness,
                end_r = rt * body_taper)
            start_r + (end_r - start_r) * body_t :
        
    sh == "tulip" ? 
        let(foot_h = foot_height_final / mug_height_final,
            crown_start = 0.88,
            flare = 1.06)
        t < foot_h ?
            let(foot_t = t / foot_h,
                foot_r = rb * 0.92)
            foot_r + (rb - foot_r) * pow(foot_t, 1.2) :
        t < crown_start ?
            let(body_t = (t - foot_h) / (crown_start - foot_h),
                body_start = rb,
                body_end = rt * 0.96)
            body_start + (body_end - body_start) * pow(body_t, 1.3) :
            let(crown_t = (t - crown_start) / (1 - crown_start),
                crown_start_r = rt * 0.96,
                crown_end_r = rt * flare)
            crown_start_r + (crown_end_r - crown_start_r) * sin(crown_t * 90) :
        
    rb + (rt - rb) * t;

function calculate_r(z, rt_trim, br, sh) = 
    let(t = min(z / h_m, 1), 
        r_b = get_radius(t, sh),
        c = (z < br && br > 0) ? (br - sqrt(max(0, pow(br, 2) - pow(br - z, 2)))) : 0) 
    r_b - c;

// ОСНОВНЫЕ МОДУЛИ

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
    outer_r = (bottom_diameter_final * s) / 2;
    rim_r = outer_r - flat_rim * s;
    hc = bottom_concave_final * s;
    br = bottom_radius_final * s;
    
    // Плоский бортик
    translate([0, 0, -eps])
        cylinder(r = outer_r, h = 0.2);
    
    // Вогнутость
    if (hc > 0.3 && rim_r > 2) {
        translate([0, 0, -eps])
            difference() {
                cylinder(r = rim_r, h = hc);
                translate([0, 0, -hc * 0.5])
                    scale([1, 1, 0.6])
                        sphere(r = rim_r);
            }
    }
    
    // Скругление края
    if (br > 0.5) {
        translate([0, 0, -eps])
            difference() {
                cylinder(r = outer_r, h = br);
                translate([0, 0, -br])
                    cylinder(r = outer_r - br, h = br * 2);
            }
    }
}

// МОДУЛИ ОСНАСТКИ

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
            cube([160, pth, ht]);
            
            if (use_extra) {
                translate([off, +comp, off]) sphere(r = r_s);
                translate([off, +comp, ht - off]) sphere(r = r_s);
                
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
        
        translate([0, 0, -eps]) pins_lock(pd + pcl, pcl, ht, true);
        translate([160, 0, -eps]) pins_lock(pd + pcl, pcl, ht, true);
        
        if (use_extra) {
            translate([160 - off, -comp, off]) sphere(r = r_s + 0.3);
            translate([160 - off, -comp, ht - off]) sphere(r = r_s + 0.3);
        }
    }
}

module green_frame(pd, pcl, pth, ht, gw, xw, yd) {
    back_wall_offset = 15;
    
    union() {
        difference() {
            cube([xw, yd, ht]);
            translate([gw, gw, gw]) cube([160, yd + 1, ht + 1]);
        }
        
        translate([gw, yd - pth, 0]) union() {
            translate([-3, 0, 0]) cube([3, pth, ht]);
            pins_lock(pd, pcl, ht, false);
        }
        
        translate([xw - gw, yd - pth, 0]) union() {
            cube([3, pth, ht]);
            mirror([1,0,0]) pins_lock(pd, pcl, ht, false);
        }
        
        translate([0, yd - pth + back_wall_offset, 0]) {
            difference() {
                cube([xw, 2, ht - 1]);
                translate([15, -1.5, 10])
                    cube([xw - 30, 5, ht + 1]);
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ ALL - ПОЛНАЯ ОСНАСТКА
// ═══════════════════════════════════════════════════════════════════

if (view_mode == "all") {
    p_d = 3; p_cl = 0.2; p_th = 15; gw = 3; bottom_case_thickness = 10;
    
    outer_x_w = 160 + (gw * 2); 
    r_base_mug = get_radius(0, cup_shape); 
    green_y_d = p_th + r_base_mug + 30;
    cast_depth = green_y_d - p_th;    
    total_depth = cast_depth * 2; 

    translate([0, 0, 0]) 
        color("Goldenrod") difference() {
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

    translate([300, 0, 0]) 
        color("Yellow") plate_with_spheres(p_d, p_cl, p_th, h_t, true, cup_shape);

    translate([600, 0, 0]) 
        color("RoyalBlue") green_frame(p_d, p_cl, p_th, h_t, gw, outer_x_w, green_y_d);
    
    translate([900, -total_depth/2, 0]) 
        color("DeepSkyBlue") difference() {
            union() {
                difference() {
                    cube([outer_x_w, total_depth, 30 + (bottom_case_thickness-gw)]); 
                    translate([gw, gw, bottom_case_thickness]) cube([160, total_depth - gw*2, 40]); 
                    translate([outer_x_w/2, total_depth/2, bottom_case_thickness - eps]) {
                        rc = (bottom_diameter_final * s) / 2 - BR_S * 0.4;
                        hc = bottom_concave_final * s;
                        if(hc > 0) scale([1, 1, hc / rc]) sphere(r = rc + 0.2);
                    }
                }
            }
        }
}

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ CATALOG
// ═══════════════════════════════════════════════════════════════════

else if (view_mode == "catalog") {
    shapes_list = ["straight", "bell", "barrel", "latte", "camp", "tulip"];
    names_list = ["СТАКАН", "КОЛОКОЛ", "БОЧКА", "ЛАТТЕ", "КЕМПИНГ", "ТЮЛЬПАН"];
    spacing = 110;
    
    for (i = [0:len(shapes_list)-1]) {
        current_shape = shapes_list[i];
        canon = get_shape_canonical(current_shape);
        temp_height = canon[0];
        temp_top = canon[1];
        temp_bottom = canon[2];
        
        translate([i * spacing - (2.5 * spacing), 0, 0]) {
            color("Goldenrod") difference() {
                union() {
                    render_body(temp_height * s, false, current_shape);
                    translate([0, 0, temp_height * s]) rotate_extrude() { 
                        rt = (temp_top * s) / 2;
                        polygon([[0,0], [rt,0], [rt+trim_margin*tan(draft_angle)*s, trim_margin*s], [0, trim_margin*s]]);
                    }
                }
                if (cut_view) translate([-200, 0, -eps]) cube([400, 200, temp_height * s + 50]);
            }
            
            translate([0, -temp_bottom * s - 35, -5])
                color("Black") text(names_list[i], size = 7 * s, halign = "center");
            
            translate([0, -temp_bottom * s - 55, -5])
                color("Gray") text(str(temp_height, "мм"), size = 5 * s, halign = "center");
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ MUG
// ═══════════════════════════════════════════════════════════════════

else if (view_mode == "mug") {
    difference() {
        union() {
            difference() {
                render_body(h_m, false, cup_shape); 
                translate([0, 0, -eps]) concave_bottom(); 
                render_body(h_m + 2, true, cup_shape);
            }
        }
        if (cut_view) translate([-200, -200, -eps]) cube([400, 200, h_m + 50]);
    }
}

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ MASTER
// ═══════════════════════════════════════════════════════════════════

else if (view_mode == "master") {
    color("Goldenrod") difference() {
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
}
// ═══════════════════════════════════════════════════════════════════
// ГЛОБАЛЬНЫЕ ПАРАМЕТРЫ
// ═══════════════════════════════════════════════════════════════════
eps = 0.01;
p_d = 3;
p_cl = 0.2;
p_th = 15;
dovetail_gap = 0.2; // Зазор для сборки

// ═══════════════════════════════════════════════════════════════════
// МОДУЛЬ 1: ОРАНЖЕВАЯ МАСТЕР-МОДЕЛЬ (СЛЕВА, X = -800)
// ═══════════════════════════════════════════════════════════════════

module standalone_master_model(shape, h_m, h_t, s, draft_angle, trim_margin) {
    difference() {
        union() { 
            render_body(h_t, false, shape); 
            translate([0, 0, h_m]) rotate_extrude() { 
                rt = get_radius(1, shape); 
                polygon([[0,0], [rt,0], [rt+trim_margin*tan(draft_angle)*s, trim_margin*s], [0, trim_margin*s]]); 
            } 
        }
        translate([0, 0, -eps]) concave_bottom();
    }
}

translate([-800, 0, 0]) {
    difference() {
        // 1. Тело детали со срезом
        color("Orange") 
            intersection() {
                standalone_master_model(cup_shape, h_m, h_t, s, draft_angle, trim_margin);
                
                // РЕЖУЩИЙ КУБ: Оставляем часть детали, которая находится в +Y
                // Сдвиг на 500 гарантирует, что плоскость среза пройдет ровно по Y=0
                translate([0, 500, h_t/2]) 
                    cube([1000, 1000, h_t + 200], center = true);
            }

        // 2. ВНУТРЕННИЙ ПАЗ (ВЫРЕЗ)
        // rotate([0,0,180]) разворачивает "хвост" внутрь оранжевой детали
        translate([0, 0, h_t/2])
            rotate([0, 0, 180]) 
                dovetail_rail_vertical(
                    width = 15 + dovetail_gap, 
                    depth = 10, 
                    height = h_t + 12, 
                    angle = 20
                );
    }

    // Тестовые оси (центр разреза)
    test_axes(size = 40, thickness = 2);
    translate([0, 0, h_t]) test_axes(size = 40, thickness = 2);
}

// ═══════════════════════════════════════════════════════════════════
// МОДУЛЬ 2: ЗЕЛЕНАЯ ПЛИТА (СПРАВА, X = -450)
// ═══════════════════════════════════════════════════════════════════

module standalone_plate_only(pd, pcl, pth, ht, use_extra=false) {
    r_s = 7.5;
    off = 15;
    comp = sphere_compensation;
    
    difference() {
        union() {
            cube([160, pth, ht]);
            
            translate([off, +comp, off]) sphere(r = r_s);
            translate([off, +comp, ht - off]) sphere(r = r_s);
            translate([160 - off, -comp, off]) sphere(r = r_s);
            translate([160 - off, -comp, ht - off]) sphere(r = r_s);
        }
        
        translate([0, 0, -eps]) pins_lock(pd + pcl, pcl, ht, true);
        translate([160, 0, -eps]) pins_lock(pd + pcl, pcl, ht, true);
        
        if (use_extra) {
            translate([160 - off, -comp, off]) sphere(r = r_s + 0.3);
            translate([160 - off, -comp, ht - off]) sphere(r = r_s + 0.3);
        }
    }
}

translate([-450, 0, 0]) {
    // 1. Плита
    color("LightGreen") 
        standalone_plate_only(p_d, p_cl, p_th, h_t, true);
    
    // 2. ВЫСТУПАЮЩИЙ РЕЛЬС
    translate([80, 0, h_t/2])
        color("LightGreen")
            dovetail_rail_vertical(
                width = 15,
                depth = 10,
                height = h_t,
                angle = 20
            );

    // Тестовые оси (центр рельса на фронтальной плоскости)
    translate([80, 0, 0]) test_axes(size = 30, thickness = 1.5);
    translate([80, 0, h_t]) test_axes(size = 30, thickness = 1.5);
}

// ═══════════════════════════════════════════════════════════════════
// ВСПОМОГАТЕЛЬНЫЕ ГЕОМЕТРИЧЕСКИЕ МОДУЛИ
// ═══════════════════════════════════════════════════════════════════

module dovetail_rail_vertical(width, depth, height, angle=30) {
    translate([0, 0, -height/2])
        linear_extrude(height = height)
            polygon(points = [
                [-width/2, 0],
                [ width/2, 0],
                [ width/2 + depth * tan(angle), -depth],
                [-width/2 - depth * tan(angle), -depth]
            ]);
}

module test_axes(size = 20, thickness = 1) {
    color("Red") cube([size, thickness, thickness]);     // X
    color("Green") cube([thickness, size, thickness]);   // Y
    color("Blue") cube([thickness, thickness, size]);    // Z
}
