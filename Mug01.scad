// Slip-Cast Hybrid Generator v4.0
// Добавлен вертикальный бортик для формы Latte

/* [1. Глобальные настройки] */
gap_factor = 1.5; 
shrinkage = 12; 
wall_thickness = 4; 

/* [2. Габариты готовой кружки (мм)] */
mug_height = 95; 
top_diameter = 100; 
bottom_diameter = 50; 

/* [3. Тюнинг формы] */
cup_shape = "latte"; // [straight, tapered, bell, tulip, barrel, latte, camp]
shape_intensity = 1.0; 
curve_pos = 0.45; 
// Для LATTE: отвечает за крутизну изгиба перед прямым бортиком
curve_smoothness = 2.0; 

/* [4. Дно и Припуски] */
bottom_radius = 12; 
bottom_concave = 2.5; 
trim_margin = 15; 
draft_angle = 15; 
trim_mark_depth = 0.8; 

/* [Служебные] */
$fn = 80;
s = 1 + (shrinkage / 100);
h_m = mug_height * s;
h_t = (mug_height + trim_margin) * s;
dynamic_gap = (top_diameter * s * gap_factor);

///////////////////////////////////////////////////
// ФУНКЦИЯ ПРОФИЛЯ
///////////////////////////////////////////////////
function get_radius(t) = 
    let(
        r_t = (top_diameter * s) / 2,
        r_b_base = (bottom_diameter * s) / 2 + (bottom_radius * s),
        base_r = r_b_base + (r_t - r_b_base) * t,
        int = shape_intensity * 10 * s,
        cp = curve_pos
    )
    cup_shape == "straight" ? r_t :
    cup_shape == "tapered"  ? base_r :
    
    // ОБНОВЛЕННЫЙ LATTE С ПРЯМЫМ БОРТИКОМ
    cup_shape == "latte" ? 
        let(
            border_start = 0.85, // Прямая часть начинается на 85% высоты
            // Если мы выше границы - берем финальный радиус (стенка прямая)
            // Если ниже - считаем изгиб, но масштабируем t к border_start
            t_adj = t > border_start ? 1 : t / border_start,
            r_final = r_b_base + (r_t - r_b_base) * pow(t_adj, curve_smoothness)
        ) 
        r_final : 
    
    cup_shape == "bell" ? 
        let(dist = t < cp ? (cp - t) / cp : (t - cp) / (1 - cp))
        base_r + int * cos(dist * 90) :
        
    cup_shape == "tulip" ? 
        let(phase = (t - cp) * 180)
        base_r + sin(phase) * int :
        
    cup_shape == "barrel" ? 
        let(dist = 1 - abs(t - cp) / (t < cp ? cp : 1 - cp))
        base_r + int * sin(dist * 90) :
        
    cup_shape == "camp" ? 
        (t < cp ? r_b_base + (int * sin((t/cp)*90)) : r_t) :
    base_r;

///////////////////////////////////////////////////
// ГЕОМЕТРИЯ
///////////////////////////////////////////////////

// 1. КРУЖКА
translate([-dynamic_gap/2, 0, 0]) {
    color("LightGray") difference() {
        render_body(h_limit = h_m, apply_draft = false);
        translate([0, 0, wall_thickness * s])
            render_body(h_limit = h_m + 1, offset = -wall_thickness * s, apply_draft = false);
    }
}

// 2. МАСТЕР-МОДЕЛЬ
translate([dynamic_gap/2, 0, 0]) {
    color("Goldenrod") difference() {
        render_body(h_limit = h_t, apply_draft = true);
        if (bottom_concave > 0) {
            translate([0, 0, -0.1])
                cylinder(h = bottom_concave * s, r1 = (bottom_diameter * s)/2, r2 = 0);
        }
        translate([0, 0, h_m])
            rotate_extrude() 
                translate([get_radius(1), 0, 0])
                    circle(r = trim_mark_depth, $fn=3); 
    }
}

module render_body(h_limit, offset = 0, apply_draft = false) {
    layers = 120; // Увеличил для четкости перехода
    br = bottom_radius * s;
    r_at_trim = get_radius(1); 
    for (i = [0 : layers - 1]) {
        let(
            z1 = (i / layers) * h_limit,
            z2 = ((i + 1) / layers) * h_limit,
            r1 = calculate_r(z1, r_at_trim, br, apply_draft),
            r2 = calculate_r(z2, r_at_trim, br, apply_draft)
        )
        if (r1 + offset > 0 && r2 + offset > 0)
        hull() {
            translate([0, 0, z1]) cylinder(h = 0.01, r = r1 + offset);
            translate([0, 0, z2]) cylinder(h = 0.01, r = r2 + offset);
        }
    }
}

function calculate_r(z, r_trim, br, draft_on) = 
    (z >= h_m && draft_on) ? 
        r_trim + (z - h_m) * tan(draft_angle) :
        let(
            t = min(z / h_m, 1),
            r_base = get_radius(t),
            corner = (z < br && br > 0) ? 
                (br - sqrt(max(0, pow(br, 2) - pow(br - z, 2)))) : 0
        ) 
        max((bottom_diameter * s)/2, r_base - corner);
