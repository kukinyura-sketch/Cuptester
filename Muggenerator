// Slip-Cast Master Generator v2.0
// Профессиональный генератор форм для литья шликером

/* [1. Общие габариты и Усадка] */
// Тип рендера
render_mode = "mold_master"; // [mug:Готовая кружка, mold_master:Мастер-модель (цельная)]
// Высота готовой кружки (мм)
mug_height = 95;
// Диаметр верха (мм)
top_diameter = 85;
// Диаметр дна (мм)
bottom_diameter = 65;
// Усадка глины (%)
shrinkage = 12;
// Толщина стенки шликера (мм)
wall_thickness = 4;

/* [2. Выбор формы] */
// Основной архетип формы
cup_shape = "bell"; // [straight:Цилиндр, tapered:Конус, bell:Колокол/Пузатая, tulip:Тюльпан, barrel:Бочка, latte:Латте (V-образная), camp:Кемпинг (с плечиками)]

/* [3. Тюнинг формы (Профиль)] */
// Насколько сильно форма отклоняется от прямой линии
shape_intensity = 1.0; // [0.1:0.1:2.0]
// Высота изгиба (0.1 - снизу, 0.9 - сверху)
curve_height = 0.45; 
// Плавность перехода (только для сложных форм)
curve_smoothness = 0.8; 

/* [4. Геометрия дна] */
// Глубина вогнутости дна (мм) - чтобы кружка не качалась
bottom_concave = 2.5;
// Радиус скругления нижнего ребра (мм)
bottom_radius = 5;

/* [5. Параметры для Молдов (Припуск)] */
// Высота припуска под обрезку (мм)
trim_margin = 15;
// Угол расширения припуска (градусы) - для легкого выхода из гипса
draft_angle = 3; 
// Индикатор линии реза (канавка)
show_trim_mark = true;

/* [Внутренние настройки] */
$fn = 120;
s_factor = 1 + (shrinkage / 100);

/////////////////////////////
// ЛОГИКА ГЕНЕРАЦИИ ПРОФИЛЯ
/////////////////////////////

function get_profile_radius(t) =
    let(
        r_t = (top_diameter * s_factor) / 2,
        r_b = (bottom_diameter * s_factor) / 2,
        base_r = r_b + (r_t - r_b) * t, // Линейный конус
        int = shape_intensity * 10 * s_factor,
        h_f = curve_height
    )
    cup_shape == "straight" ? r_t :
    cup_shape == "tapered"  ? base_r :
    
    cup_shape == "bell" ? 
        let(dist = t < h_f ? (h_f - t) / h_f : (t - h_f) / (1 - h_f))
        base_r + int * cos(dist * 90) :
        
    cup_shape == "tulip" ? 
        let(curve = sin(t * 180 - 45) * int)
        base_r + curve :
        
    cup_shape == "barrel" ? 
        base_r + int * sin(t * 180) :
        
    cup_shape == "latte" ? 
        r_b + (r_t - r_b) * pow(t, 1/curve_smoothness) :
        
    cup_shape == "camp" ? 
        let(edge = h_f, transition = 0.1)
        t < edge ? r_b + (int * sin((t/edge)*90)) : r_t :
        
    base_r; // Default

/////////////////////////////
// СБОРКА МОДЕЛИ
/////////////////////////////

h_total = (mug_height + trim_margin) * s_factor;
h_main = mug_height * s_factor;

if (render_mode == "mug") {
    difference() {
        full_body();
        translate([0, 0, wall_thickness * s_factor])
            body_geometry(offset = -wall_thickness * s_factor);
    }
} else {
    full_body();
}

module full_body() {
    difference() {
        body_geometry(offset = 0);
        
        // Вогнутое дно
        if (bottom_concave > 0) {
            translate([0, 0, -0.1])
                cylinder(h = bottom_concave * s_factor, r1 = (bottom_diameter * s_factor)/2 - bottom_radius, r2 = 0);
        }
        
        // Индикатор обрезки (канавка)
        if (show_trim_mark && render_mode == "mold_master") {
            translate([0, 0, h_main])
                difference() {
                    cylinder(h = 1, r = top_diameter * s_factor);
                    cylinder(h = 1.1, r = (top_diameter * s_factor)/2 - 0.5);
                }
        }
    }
}

module body_geometry(offset = 0) {
    steps = 100;
    rotate_extrude() {
        hull() { // Для скругления дна
            // Основной профиль
            polygon(concat(
                [[0, 0]], 
                [for (i = [0 : steps]) 
                    let(
                        t_main = i/steps,
                        z = t_main * h_total,
                        // Если выше линии реза - делаем расширение (draft angle)
                        is_trim = z > h_main,
                        r_main = get_profile_radius(min(z/h_main, 1)),
                        r_final = is_trim ? r_main + (z - h_main) * tan(draft_angle) : r_main
                    )
                    [r_final + offset, z]
                ],
                [[0, h_total]]
            ));
            
            // Скругление нижнего ребра
            if (offset == 0) {
                translate([(bottom_diameter * s_factor)/2 - bottom_radius + bottom_radius/2, bottom_radius])
                    circle(r = bottom_radius);
            }
        }
    }
}
