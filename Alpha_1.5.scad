// Slip-Cast Hybrid Generator v1.5
// Генератор форм для шликерного литья
// v1.5: Финальная версия с квадратной синей деталью, отступами пирамидок 20 мм
//       и библиотекой 100 архитектурных пресетов

use <presets.scad>;

// ═══════════════════════════════════════════════════════════════════
// 1. РЕЖИМЫ ОТОБРАЖЕНИЯ
// ═══════════════════════════════════════════════════════════════════

view_mode = "all"; // [catalog:Каталог форм, mug:Готовая кружка, master:Мастер-модель, all:Вся оснастка]
cut_view = false; // [true:Включить разрез, false:Выключить разрез]

// ═══════════════════════════════════════════════════════════════════
// 2. ПРОФИЛЬ КРУЖКИ
// ═══════════════════════════════════════════════════════════════════

//cup_shape = "barrel"; // ["straight":"СТАКАН (цилиндр)", "bell":"КОЛОКОЛ (S-образный)", "barrel":"БОЧКА (пузатая)", "latte":"ЛАТТЕ (прямой бортик)", "camp":"КЕМПИНГ (низкий широкий)", "tulip":"ТЮЛЬПАН (ЛФЗ, чайная)"]

// ═══════════════════════════════════════════════════════════════════
// 3. БАЗОВЫЕ РАЗМЕРЫ (из канонической таблицы)
// ═══════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════
// 4. РУЧНЫЕ НАСТРОЙКИ (0 = использовать базовое значение)
// ═══════════════════════════════════════════════════════════════════

manual_height = 0; // [0:50:200] Высота кружки (мм) - 0 = авто
manual_top_dia = 0; // [0:30:150] Верхний диаметр (мм) - 0 = авто
manual_bottom_dia = 0; // [0:20:120] Нижний диаметр (мм) - 0 = авто
manual_belly_pos = 0; // [0:0.2:0.8] Положение "пуза" - 0 = авто
manual_intensity = -1; // [-1:0.1:2.5] Интенсивность изгиба - -1 = авто

//
// ═══════════════════════════════════════════════════════════════════
// 4.5. БИБЛИОТЕКА ПРЕСЕТОВ (из внешнего файла)
// ═══════════════════════════════════════════════════════════════════

use_preset_library = false;  // [true, false]
preset_id = 1;               // [1:1:100]

_use_preset = use_preset_library && manual_height == 0 && manual_top_dia == 0 && manual_bottom_dia == 0;

// Определяем параметры пресета (если включен)
_preset_params = _use_preset ? get_preset(preset_id) : [0,0,0,0,0,0,0];

// Определяем вид кружки через тернарный оператор
_preset_shape = _use_preset ? 
    (preset_id <= 17 ? "bell" :
     preset_id <= 34 ? "barrel" :
     preset_id <= 51 ? "tulip" :
     preset_id <= 68 ? "straight" :
     preset_id <= 84 ? "latte" : "camp") 
    : cup_shape;

// Применяем вид из пресета (если включен)
cup_shape = _preset_shape;

// Выводим информацию (если включен)
if (_use_preset) echo(str("PRESET #", preset_id, " — ", get_preset_family(preset_id)));
// 5. ТЕХНОЛОГИЧЕСКИЕ ПАРАМЕТРЫ
// ═══════════════════════════════════════════════════════════════════

shrinkage = 7.5; // [0:0.5:20] Усадка глины при сушке (%)
wall_thickness = 4; // [1:0.5:10] Толщина стенки кружки (мм)
bottom_extra = 2; // [0:0.5:8] Дополнительная толщина дна (мм)

// ═══════════════════════════════════════════════════════════════════
// 6. ПРЕСЕТЫ ПРОПОРЦИЙ
// ═══════════════════════════════════════════════════════════════════

proportion_preset = "custom"; // ["custom":"РУЧНЫЕ НАСТРОЙКИ", "golden":"ЗОЛОТОЕ СЕЧЕНИЕ", "classic":"КЛАССИЧЕСКАЯ", "espresso":"ЭСПРЕССО", "cappuccino":"КАПУЧИНО"]

// ═══════════════════════════════════════════════════════════════════
// 7. ТОЧНЫЕ НАСТРОЙКИ ФОРМЫ (если пресет = РУЧНЫЕ)
// ═══════════════════════════════════════════════════════════════════

belly_pos = 0.50; // [0.2:0.01:0.8] Положение максимальной ширины
shape_intensity = 1.5; // [0:0.1:2.5] Интенсивность изгиба стенки

// ═══════════════════════════════════════════════════════════════════
// 8. КОНСТРУКЦИЯ ДНА
// ═══════════════════════════════════════════════════════════════════

bottom_radius = 3; // [0:1:15] Радиус скругления дна (мм)
bottom_concave = 0.5; // [0:0.5:8] Глубина вогнутости дна (мм)
flat_rim = 3; // [0:1:8] Плоский бортик по краю дна (мм)

// ═══════════════════════════════════════════════════════════════════
// 9. ОСНАСТКА И ТЕХНИЧЕСКИЕ ПАРАМЕТРЫ
// ═══════════════════════════════════════════════════════════════════

trim_margin = 15; // [5:1:30] Запас на обрезку сверху формы (мм)
draft_angle = 5; // [0:1:15] Угол уклона для извлечения из формы (градусы)
sphere_compensation = 1.5; // [0:0.1:3] Компенсация для сферических фиксаторов

// Пресеты ширины опалубки
fixture_width_preset = 160; // [120:Малая (120мм), 160:Средняя (160мм), 180:Большая (180мм), 200:Макси (200мм), 0:Своя]
fixture_width_custom = 160; // [80:10:300] Ширина монтажной пластины (мм) - используется только при fixture_width_preset=0

// Толщина стенок ОПАЛУБКИ
front_wall_thickness = 3; // [1:1:10] Толщина передней стенки (мм)
back_wall_thickness = 1.6; // [0.8:0.2:5] Толщина задней стенки (мм)

// Толщина пластины
yellow_plate_thickness = 15; // [5:1:30] Толщина пластины (мм)

// ═══════════════════════════════════════════════════════════════════
// 10. ПАРАМЕТРЫ ПИРАМИДОК
// ═══════════════════════════════════════════════════════════════════

pyramid_size = 15; // [5:1:25] Размер основания пирамидки (мм)
pyramid_height = 5; // [2:1:10] Высота пирамидки (мм)
pyramid_offset = 20; // [10:1:50] Отступ пирамидки от края (мм)

// ═══════════════════════════════════════════════════════════════════
// 11. ПАРАМЕТРЫ ЛАСТОЧКИНА ХВОСТА (ГЛАВНАЯ ОСНАСТКА)
// ═══════════════════════════════════════════════════════════════════

dovetail_width = 20;        // [5:1:50] Ширина широкой части (мм)
dovetail_depth = 10;        // [3:1:30] Глубина ласточкина хвоста (мм)
dovetail_height = 50;       // [5:1:150] Высота направляющей (мм)
dovetail_angle = 20;        // [10:1:45] Угол ласточкина хвоста (градусы)
dovetail_gap = 0.2;         // [0:0.05:1] Зазор (ширина паза = ширина шипа + зазор)

// ═══════════════════════════════════════════════════════════════════
// 12. ДОПОЛНИТЕЛЬНЫЕ ПАРАМЕТРЫ ОСНАСТКИ
// ═══════════════════════════════════════════════════════════════════

master_plate_extra_height = 30;  // [0:5:100] Высота выступа мастер-пластины над опалубкой (мм)
formwork_base_thickness = 5;     // [0:2:20] Толщина бортика опалубки (мм)
formwork_base_margin = 5;        // [0:2:20] Расширение бортика опалубки во все стороны (мм)

// ═══════════════════════════════════════════════════════════════════
// 13. КАЛИБРОВКА И ОТЛАДКА
// ═══════════════════════════════════════════════════════════════════

show_calibration_points = false; // [true:ПОКАЗАТЬ ТОЧКИ, false:СКРЫТЬ ТОЧКИ]
show_axes = false;               // [true:ПОКАЗАТЬ ОСИ, false:СКРЫТЬ ОСИ]
show_station2 = false;           // [true:ПОКАЗАТЬ СТАНЦИЮ 2, false:СКРЫТЬ СТАНЦИЮ 2]
show_plaster_calc = true;        // [true:ПОКАЗАТЬ РАСЧЁТ ГИПСА, false:СКРЫТЬ]

// Качество визуализации
$fn = $preview ? 180 : 90;

// ═══════════════════════════════════════════════════════════════════
// РАСЧЁТ ПАРАМЕТРОВ (НЕ МЕНЯТЬ!)
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

// Применяем пресет к базовым значениям (если пресет включен)
h_base = use_manual ? manual_height : (_use_preset ? _preset_params[0] : mug_height_base);
td_base = use_manual_dia ? manual_top_dia : (_use_preset ? _preset_params[1] : top_diameter_base);
bd_base = use_manual_bottom ? manual_bottom_dia : (_use_preset ? _preset_params[2] : bottom_diameter_base);

height_ratio = h_base / mug_height_base;
safe_ratio = max(height_ratio, 0.3);
scaled_intensity = shape_intensity_base * (1 / safe_ratio) * 0.7;

bp_base = manual_belly_pos > 0 ? manual_belly_pos : (_use_preset ? _preset_params[3] : belly_pos_base);
si_base = manual_intensity >= 0 ? manual_intensity : (_use_preset ? _preset_params[4] : scaled_intensity);

_preset_applied = proportion_preset != "custom" ? 
    apply_proportion_preset(proportion_preset, h_base, td_base, bd_base, bp_base, si_base) :
    [h_base, td_base, bd_base, bp_base, si_base];

mug_height_final = _preset_applied[0];
top_diameter_final = _preset_applied[1];
bottom_diameter_final = _preset_applied[2];
belly_pos_final = _preset_applied[3];
shape_intensity_final = _preset_applied[4];

// Параметры дна
bottom_radius_final = _use_preset ? _preset_params[5] : max(1, min(12, bottom_radius));
bottom_concave_final = _use_preset ? _preset_params[6] : max(0, min(6, bottom_concave));
foot_height_final = foot_height_base;

s = 1 + (shrinkage / 100);
h_m = mug_height_final * s;
h_t = (mug_height_final + trim_margin) * s;
w_s = wall_thickness * s;
b_s = (wall_thickness + bottom_extra) * s; 
BR_S = bottom_radius_final * s; 
eps = 0.05; 

// Определение ширины опалубки (из пресета или ручной)
fixture_width = (fixture_width_preset == 0) ? fixture_width_custom : fixture_width_preset;

// Определение высоты опалубки по пресету
formwork_height_preset = 150;
formwork_height = (formwork_height_preset < h_t) ? formwork_height_preset : h_t;

// Новая логика: внутренняя глубина = половина ширины
inner_frame_depth = fixture_width / 2;

// Общая глубина ОПАЛУБКИ
formwork_total_depth = front_wall_thickness + inner_frame_depth + yellow_plate_thickness + back_wall_thickness;

// Внешняя ширина (с учетом бортика)
outer_x_w = fixture_width + (front_wall_thickness * 2);

// Ширина и глубина опалубки с бортиком
formwork_base_x = outer_x_w + (formwork_base_margin * 2);
formwork_base_y = formwork_total_depth + (formwork_base_margin * 2);

// Положение пластины (начало - в конце полости)
yellow_plate_start = front_wall_thickness + inner_frame_depth;
yellow_plate_end = yellow_plate_start + yellow_plate_thickness;

// Координата для фиксирующих блоков (там же, где пластина)
yellow_plate_block_y = yellow_plate_start;

// Положение пирамидок (в полости, у передней стенки) - центр по Y
pyramids_y = front_wall_thickness + pyramid_offset + pyramid_size/2;

// Высота мастер-пластины с учетом выступа
master_plate_height = h_t + master_plate_extra_height;

// Параметры сфер
sphere_radius = 7.5;
sphere_offset_x = 15;
sphere_offset_y_plus = sphere_compensation;
sphere_offset_y_minus = -sphere_compensation;
sphere_height_bottom = 7.5;
sphere_height_top = h_t - sphere_height_bottom;

// ═══════════════════════════════════════════════════════════════════
// ОБЩИЕ ПЕРЕМЕННЫЕ ДЛЯ ВСЕХ РЕЖИМОВ
// ═══════════════════════════════════════════════════════════════════

bottom_case_thickness = 10;
p_d = 3;
p_cl = 0.2;
p_th = yellow_plate_thickness;
r_base_mug = get_radius(0, cup_shape); 

// Для красной опалубки
formwork_y_d = formwork_total_depth;

// Синяя деталь — квадратная, внутренний размер = fixture_width
total_depth = fixture_width;

// ═══════════════════════════════════════════════════════════════════
// РАСЧЁТ СВОБОДНОГО ОБЪЁМА И ГИПСА
// ═══════════════════════════════════════════════════════════════════

// Расчёт внутреннего объёма кружки (готовое изделие)
function get_inner_volume() = 
    let(outer_radius = (bottom_diameter_final * s) / 2,
        inner_radius = max(0, outer_radius - w_s),
        inner_height = max(0, h_m - b_s))
    inner_height > 0 && inner_radius > 0 ? 3.14159 * pow(inner_radius, 2) * inner_height : 0;

// Расчёт свободного объёма в опалубке (для заливки гипса)
free_volume_mm3 = (fixture_width * inner_frame_depth * formwork_height) - 
                  (fixture_width * yellow_plate_thickness * master_plate_height) - 
                  (3.14159 * pow((bottom_diameter_final * s) / 2, 2) * h_m);

free_volume_cm3 = free_volume_mm3 / 1000;

// Три режима воды/гипса (на 900 г гипса)
gypsum_base = 900;

// Режим Низкий (В/Г = 0.36)
water_low = gypsum_base * 0.36;
friplast_low = gypsum_base * 0.0055;

// Режим Средний (В/Г = 0.38)
water_mid = gypsum_base * 0.38;
friplast_mid = gypsum_base * 0.0055;

// Режим Высокий (В/Г = 0.41)
water_high = gypsum_base * 0.41;
friplast_high = gypsum_base * 0.0055;

// Объём гипсовой смеси (плотность ~1.4 г/см³)
mix_volume_cm3 = free_volume_cm3;
mix_weight_grams = mix_volume_cm3 * 1.4;

// Расчёт гипса по объёму формы (для среднего режима)
gypsum_by_volume = mix_weight_grams / (1 + 0.38 + 0.0055);
water_by_volume = gypsum_by_volume * 0.38;
friplast_by_volume = gypsum_by_volume * 0.0055;

// ═══════════════════════════════════════════════════════════════════
// ПРОВЕРКИ КОЛЛИЗИЙ
// ═══════════════════════════════════════════════════════════════════

// Функция для получения радиуса кружки на заданной высоте
function get_radius_at_height(z) = 
    let(t = min(z / h_m, 1))
    get_radius(t, cup_shape);

// Радиус кружки на высоте нижних сфер (всегда в пределах кружки)
radius_at_bottom_spheres = get_radius_at_height(min(sphere_height_bottom, h_m));

// Радиус кружки на высоте верхних сфер
radius_at_top_spheres = (sphere_height_top <= h_m) ? get_radius_at_height(sphere_height_top) : 0;

// Максимальный радиус кружки
max_radius = get_radius_at_height(min(belly_pos_final * h_m, h_m));

// Положение сфер
sphere_center_right = fixture_width - sphere_offset_x;
sphere_center_left = sphere_offset_x;

// Расчет минимальной необходимой ширины
required_width_bottom = (radius_at_bottom_spheres * 2) + (sphere_radius * 2) + 25;
required_width_top = (radius_at_top_spheres * 2) + (sphere_radius * 2) + 25;
required_width_wall = (max_radius * 2) + 40;

// Итоговая требуемая ширина
required_width = max(required_width_bottom, required_width_top, required_width_wall) + 5;

// ФЛАГ РЕАЛЬНОЙ КОЛЛИЗИИ:
has_collision = (sphere_height_top <= h_m) && (required_width > fixture_width);

// Предупреждения в консоль (только если реальная коллизия)
if (has_collision) {
    echo("===========================================================================");
    echo("ПРЕДУПРЕЖДЕНИЕ: Обнаружена коллизия! Требуется увеличить ширину опалубки.");
    echo("Текущая ширина: ", fixture_width, " мм");
    echo("Рекомендуемая минимальная ширина: ", required_width, " мм");
    echo("Диаметр кружки на уровне верхних сфер: ", radius_at_top_spheres * 2, " мм");
    if (fixture_width_preset != 0) {
        echo("Попробуйте выбрать больший пресет ширины или переключитесь на 'Своя'");
    }
    echo("===========================================================================");
}

// Расчёт гипса (вывод в консоль)
if (show_plaster_calc && free_volume_cm3 > 0) {
    inner_volume_ml = get_inner_volume();
    
    echo("===========================================================================");
    echo("РАСЧЁТ ГИПСА (Черкесский Г-16)");
    echo("===========================================================================");
    
    if (inner_volume_ml > 0) {
        echo("Объём готовой кружки: ", round(inner_volume_ml/1000 ), " мл");
    }
    
    echo("Полезный объём формы: ", round(free_volume_cm3), " см³");
    echo("");
    echo("На ", round(free_volume_cm3), " см³ смеси (на всю форму):");
    echo("");
    echo("Режим       Гипс     Вода    Фрипласт");
    echo("─────────────────────────────────────");
    echo("Низкий     ", round(gypsum_by_volume * 0.36/0.38), " г   ", round(water_by_volume * 0.36/0.38), " г   ", round(friplast_by_volume * 0.36/0.38 * 10) / 10, " г");
    echo("Средний    ", round(gypsum_by_volume), " г   ", round(water_by_volume), " г   ", round(friplast_by_volume * 10) / 10, " г");
    echo("Высокий    ", round(gypsum_by_volume * 0.41/0.38), " г   ", round(water_by_volume * 0.41/0.38), " г   ", round(friplast_by_volume * 0.41/0.38 * 10) / 10, " г");
    echo("===========================================================================");
}

// ═══════════════════════════════════════════════════════════════════
// ГЕОМЕТРИЯ ФОРМЫ (НЕ МЕНЯТЬ!)
// ═══════════════════════════════════════════════════════════════════

function get_radius(t, sh) = 
    let(rt = (top_diameter_final * s) / 2, 
        rb = (bottom_diameter_final * s) / 2 + BR_S,
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
    sh == "tulip" ? let(foot_h = foot_height_final / mug_height_final, crown_start = 0.88, flare = 1.06)
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

// ═══════════════════════════════════════════════════════════════════
// ОСНОВНЫЕ СТРОИТЕЛЬНЫЕ МОДУЛИ
// ═══════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════
// МОДУЛИ ОСНАСТКИ (ПИНЫ, ШАРИКИ)
// ═══════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════
// МОДУЛЬ: УСЕЧЕННАЯ ПИРАМИДКА (выступ вверх)
// ═══════════════════════════════════════════════════════════════════

module truncated_pyramid(base_size, top_size, height) {
    polyhedron(
        points = [
            [-base_size/2, -base_size/2, 0], [ base_size/2, -base_size/2, 0],
            [ base_size/2,  base_size/2, 0], [-base_size/2,  base_size/2, 0],
            [-top_size/2, -top_size/2, height], [ top_size/2, -top_size/2, height],
            [ top_size/2,  top_size/2, height], [-top_size/2,  top_size/2, height]
        ],
        faces = [
            [0,1,2,3], [4,5,1,0], [5,6,2,1], [6,7,3,2], [7,4,0,3], [4,5,6,7]
        ]
    );
}

// ═══════════════════════════════════════════════════════════════════
// МОДУЛЬ: ПЕРЕВЁРНУТАЯ ПИРАМИДКА (углубление вниз) - для синей опалубки
// ═══════════════════════════════════════════════════════════════════

module inverted_pyramid(base_size, top_size, height) {
    polyhedron(
        points = [
            [-base_size/2, -base_size/2, 0], [ base_size/2, -base_size/2, 0],
            [ base_size/2,  base_size/2, 0], [-base_size/2,  base_size/2, 0],
            [-top_size/2, -top_size/2, -height], [ top_size/2, -top_size/2, -height],
            [ top_size/2,  top_size/2, -height], [-top_size/2,  top_size/2, -height]
        ],
        faces = [
            [0,1,2,3], [4,5,1,0], [5,6,2,1], [6,7,3,2], [7,4,0,3], [4,5,6,7]
        ]
    );
}

// ═══════════════════════════════════════════════════════════════════
// ОПАЛУБКА (красная рамка, с бортиком внизу)
// ═══════════════════════════════════════════════════════════════════

module formwork(pd, pcl, pth, ht, xw, yd) {
    top_size = pyramid_size * 0.6;
    
    union() {
        // Бортик основания (расширение дна)
        if (formwork_base_thickness > 0) {
            translate([-formwork_base_margin, -formwork_base_margin, -formwork_base_thickness])
                color("Red") cube([xw + (formwork_base_margin * 2), yd + (formwork_base_margin * 2), formwork_base_thickness]);
        }
        
        // Основной короб
        difference() {
            cube([xw, yd, ht]);
            translate([front_wall_thickness, front_wall_thickness, front_wall_thickness]) 
                cube([fixture_width, yd - back_wall_thickness, ht + 1]);
        }
        
        // Левый фиксирующий блок (у начала пластины)
        translate([front_wall_thickness, yellow_plate_block_y, 0]) union() {
            translate([-3, 0, 0]) cube([3, yellow_plate_thickness, ht]);
            pins_lock(pd, pcl, ht, false);
        }
        
        // Правый фиксирующий блок (у начала пластины)
        translate([xw - front_wall_thickness, yellow_plate_block_y, 0]) union() {
            cube([3, yellow_plate_thickness, ht]);
            mirror([1,0,0]) pins_lock(pd, pcl, ht, false);
        }
        
        // ЦЕЛЬНАЯ ЗАДНЯЯ СТЕНКА (после пластины)
        translate([0, yellow_plate_end, 0]) {
            cube([xw, back_wall_thickness, ht]);
        }
        
        // ПИРАМИДКИ В ПОЛОСТИ (у передней стенки) - ВЫСТУПЫ ВВЕРХ
        // Левая пирамидка (отступ от левой СТЕНКИ ПОЛОСТИ = pyramid_offset)
        translate([front_wall_thickness + pyramid_offset + pyramid_size/2, 
                   pyramids_y, 0])
            truncated_pyramid(pyramid_size, top_size, pyramid_height);
        
        // Правая пирамидка (отступ от правой СТЕНКИ ПОЛОСТИ = pyramid_offset)
        translate([front_wall_thickness + fixture_width - pyramid_offset - pyramid_size/2, 
                   pyramids_y, 0])
            truncated_pyramid(pyramid_size, top_size, pyramid_height);
    }
}

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ ALL - ПОЛНАЯ СБОРКА ОСНАСТКИ
// ═══════════════════════════════════════════════════════════════════

if (view_mode == "all") {

    // СТАНЦИЯ 1: Оранжевая мастер-модель
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

    // СТАНЦИЯ 2: Желтая пластина с шариками (отображение по чекбоксу)
    if (show_station2) {
        translate([300, 0, 0]) 
            color("Yellow") plate_with_spheres(p_d, p_cl, p_th, h_t, true, cup_shape);
    }

    // СТАНЦИЯ 3: ОПАЛУБКА (красная, с бортиком)
    translate([600, 0, 0]) 
        color("Red") formwork(p_d, p_cl, p_th, formwork_height, outer_x_w, formwork_y_d);
    
    // СТАНЦИЯ 4: ОПАЛУБКА ДНА (синяя нижняя форма, 4 гнезда под пирамидки)
    translate([900, -(total_depth + front_wall_thickness*2)/2, 0]) 
        color("DeepSkyBlue") difference() {
            union() {
                difference() {
                    // Наружный размер (квадрат)
                    cube([outer_x_w, total_depth + front_wall_thickness*2, 30 + (bottom_case_thickness - front_wall_thickness)]); 
                    // Внутренняя полость (квадрат)
                    translate([front_wall_thickness, front_wall_thickness, bottom_case_thickness]) 
                        cube([fixture_width, total_depth, 40]); 
                    // Углубление под дно кружки
                    translate([outer_x_w/2, (total_depth + front_wall_thickness*2)/2, bottom_case_thickness - eps]) {
                        rc = (bottom_diameter_final * s) / 2 - BR_S * 0.4;
                        hc = bottom_concave_final * s;
                        if(hc > 0) scale([1, 1, hc / rc]) sphere(r = rc + 0.2);
                    }
                }
            }
            // 4 ГНЕЗДА ПОД ПИРАМИДКИ (отступ от всех стенок = pyramid_offset)
            top_size = pyramid_size * 0.6;
            
            // Передние гнезда
            translate([front_wall_thickness + pyramid_offset + pyramid_size/2, 
                       front_wall_thickness + pyramid_offset + pyramid_size/2, 
                       bottom_case_thickness + 0.1])
                inverted_pyramid(pyramid_size, top_size, pyramid_height);
            
            translate([front_wall_thickness + fixture_width - pyramid_offset - pyramid_size/2, 
                       front_wall_thickness + pyramid_offset + pyramid_size/2, 
                       bottom_case_thickness + 0.1])
                inverted_pyramid(pyramid_size, top_size, pyramid_height);
            
            // Задние гнезда
            translate([front_wall_thickness + pyramid_offset + pyramid_size/2, 
                       front_wall_thickness + total_depth - pyramid_offset - pyramid_size/2, 
                       bottom_case_thickness + 0.1])
                inverted_pyramid(pyramid_size, top_size, pyramid_height);
            
            translate([front_wall_thickness + fixture_width - pyramid_offset - pyramid_size/2, 
                       front_wall_thickness + total_depth - pyramid_offset - pyramid_size/2, 
                       bottom_case_thickness + 0.1])
                inverted_pyramid(pyramid_size, top_size, pyramid_height);
        }
}

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ CATALOG - ПРОСМОТР ВСЕХ ПРОФИЛЕЙ
// ═══════════════════════════════════════════════════════════════════

else if (view_mode == "catalog") {
    shapes_list = ["straight", "bell", "barrel", "latte", "camp", "tulip"];
    names_list = ["СТАКАН", "КОЛОКОЛ", "БОЧКА", "ЛАТТЕ", "КЕМПИНГ", "ТЮЛЬПАН"];
    spacing = 110;
    
    for (i = [0:len(shapes_list)-1]) {
        current_shape = shapes_list[i];
        canon = get_shape_canonical(current_shape);
        temp_height = canon[0];
        temp_bottom = canon[2];
        
        translate([i * spacing - (2.5 * spacing), 0, 0]) {
            color("Goldenrod") 
                render_body(temp_height * s, false, current_shape);
            
            translate([0, -temp_bottom * s - 35, -5]) 
                color("Black") text(names_list[i], size = 7 * s, halign = "center");
            translate([0, -temp_bottom * s - 55, -5]) 
                color("Gray") text(str(temp_height, "мм"), size = 5 * s, halign = "center");
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ MUG - ГОТОВАЯ КРУЖКА
// ═══════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════
// РЕЖИМ MASTER - МАСТЕР-МОДЕЛЬ
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
        if (cut_view) translate([-200, 0, -eps]) cube([400, 200, h_t + 50]);
    }
}

// ═══════════════════════════════════════════════════════════════════
// ГЛАВНАЯ ОСНАСТКА: Ласточкин хвост
// ═══════════════════════════════════════════════════════════════════

eps_global = 0.01;

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
        translate([0, 0, -eps_global]) pins_lock(pd + pcl, pcl, master_plate_height, true);
        translate([fixture_width, 0, -eps_global]) pins_lock(pd + pcl, pcl, master_plate_height, true);
        if (use_extra) {
            translate([fixture_width - off, -comp, off]) sphere(r = r_s + 0.3);
            translate([fixture_width - off, -comp, ht_original - off]) sphere(r = r_s + 0.3);
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// ЛАСТОЧКИН ХВОСТ (только в режиме ALL)
// ═══════════════════════════════════════════════════════════════════

if (view_mode == "all") {

    // МАСТЕР-МОДЕЛЬ С ПАЗОМ
    translate([-800, 0, 0]) {
        render() difference() {
            color("Orange") intersection() {
                standalone_master_model(cup_shape, h_m, h_t, s, draft_angle, trim_margin);
                translate([0, 500, h_t/2]) cube([1000, 1000, h_t + 200], center = true);
            }
            
            translate([0, 0, -1]) 
                mirror([0, 1, 0])
                color("DarkOrange") dovetail_rail_vertical(width = dovetail_width + dovetail_gap, depth = dovetail_depth, height = dovetail_height + 1, angle = dovetail_angle);
        }
        
        if (show_calibration_points) {
            color("Red") translate([-(dovetail_width + dovetail_gap)/2, 0, dovetail_height]) sphere(r = 1.5);
            color("Green") translate([+(dovetail_width + dovetail_gap)/2, 0, dovetail_height]) sphere(r = 1.5);
            color("Blue") translate([-(dovetail_width + dovetail_gap)/2, 0, 0]) sphere(r = 1.5);
            color("Yellow") translate([+(dovetail_width + dovetail_gap)/2, 0, 0]) sphere(r = 1.5);
        }
        
        if (show_axes) {
            translate([0, 0, dovetail_height / 2]) {
                color("Yellow") sphere(r = 2);
                color("Red")   translate([-15, 0, 0]) cube([30, 0.5, 0.5]);
                color("Green") translate([0, -15, 0]) cube([0.5, 30, 0.5]);
                color("Blue")  translate([0, 0, -15]) cube([0.5, 0.5, 30]);
            }
            translate([0, 0, 0]) color("Cyan") sphere(r = 1.5);
            translate([0, 0, dovetail_height]) color("Magenta") sphere(r = 1.5);
        }
    }

    // МАСТЕР-ПЛАСТИНА С ШИПОМ
    translate([-450, 0, 0]) {
        color("LightGreen") master_plate(p_d, p_cl, yellow_plate_thickness, h_t, true);
        translate([fixture_width/2, 0, 0]) 
            color("Lime") dovetail_rail_vertical(width = dovetail_width, depth = dovetail_depth, height = dovetail_height, angle = dovetail_angle);
        
        if (show_calibration_points) {
            color("Red") translate([fixture_width/2 - dovetail_width/2, 0, dovetail_height]) sphere(r = 1.5);
            color("Green") translate([fixture_width/2 + dovetail_width/2, 0, dovetail_height]) sphere(r = 1.5);
            color("Blue") translate([fixture_width/2 - dovetail_width/2, 0, 0]) sphere(r = 1.5);
            color("Yellow") translate([fixture_width/2 + dovetail_width/2, 0, 0]) sphere(r = 1.5);
        }
        
        if (show_axes) {
            translate([fixture_width/2, 0, dovetail_height / 2]) {
                color("Yellow") sphere(r = 2);
                color("Red")   translate([-15, 0, 0]) cube([30, 0.5, 0.5]);
                color("Green") translate([0, -15, 0]) cube([0.5, 30, 0.5]);
                color("Blue")  translate([0, 0, -15]) cube([0.5, 0.5, 30]);
            }
            translate([fixture_width/2, 0, 0]) color("Cyan") sphere(r = 1.5);
            translate([fixture_width/2, 0, dovetail_height]) color("Magenta") sphere(r = 1.5);
        }
    }
}

module test_axes(size = 20, thickness = 1) {
    color("Red") cube([size, thickness, thickness]);
    color("Green") cube([thickness, size, thickness]);
    color("Blue") cube([thickness, thickness, size]);
}