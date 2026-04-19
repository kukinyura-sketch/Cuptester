// =============================================================
// ПРЕСС-ФОРМА ДЛЯ КЕРАМИЧЕСКОЙ ПЛИТКИ (V11.9 - RESTORED & FIXED)
// =============================================================

/* [1. ОСНОВНЫЕ ПАРАМЕТРЫ] */
tile_target     = 50;       
shrinkage       = 7.5;      
total_h         = 50;       
$fn             = 40; 

/* [2. ТЕСТ ДОПУСКОВ (Cross Test)] */
cross_test_offset = 0.00; // [-1:0.05:1]

/* [3. ГЕОМЕТРИЯ МАТРИЦЫ] */
wall_thick      = 3.2;      
blade_h         = 30;       
blade_edge      = 0.8;      
transition_h    = 5;        
corner_r        = 2.5; 

/* [4. ПУАНСОН И ВСТАВКА] */
p_h             = 10;       
press_gap       = 0.15;     
rim_h           = 1.5;      
plunger_top_taper = 2.0;    
vent_d          = 1.2; 
vent_top_d      = 6.0;

// ПАРАМЕТРЫ КРЕСТА
cross_w         = 5;     
cross_L         = 15;    
cross_h_top     = 5;       
cross_h_total   = p_h + cross_h_top; 
cross_straight_h = 3.0;   
cross_fit_gap   = 0.15;   
cross_top_chamfer = 0.8;  

/* [5. ПЕРЕКЛАДИНА, РУЧКА И ШТОК] */
bar_h           = 14;    
bar_slot_h      = 5;
main_w          = 22;    
rod_d           = 10;       
dist            = 38;       
comp            = 0.3;     
play            = 0.2;      
top_round_r     = 2.0;   

/* [6. РЕЖИМЫ ПРОСМОТРА] */
view_mode       = "assembly"; // [assembly, section, all, matrix, plunger, cap, bar, handle, rods, test_fit]
section_axis    = "X"; // [X, Y]

// =============================================================
// СЛУЖЕБНЫЕ РАСЧЕТЫ
// =============================================================
inner_size        = tile_target / (1 - shrinkage / 100);
plunger_size      = inner_size - (press_gap * 2); 
outer_size        = inner_size + (wall_thick * 2);
actual_slot_depth = wall_thick * 0.7;
bar_z_pos         = total_h/2 - bar_slot_h/2; 
cap_base_h        = 2.0;

safe_r_matrix  = max(corner_r, 0.42 * 1.5);
safe_r_plunger = max(0.1, safe_r_matrix - press_gap); 

module rounded_square(s, r) {
    offset(r = r) square(max(0.1, s - 2*r), center = true);
}

module cross_core(gap = 0, with_chamfer = false, extra_offset = 0) {
    cw = cross_w + gap * 2 + extra_offset;
    cl = cross_L + gap * 2 + extra_offset;
    ch = cross_top_chamfer;
    for(a = [0, 90]) rotate([0, 0, a]) {
        hull() {
            cube([cl, cw, 0.01], center = true);
            translate([0, 0, cross_straight_h]) cube([cl, cw, 0.01], center = true);
        }
        hull() {
            translate([0, 0, cross_straight_h - 0.01]) cube([cl, cw, 0.01], center = true);
            if (with_chamfer) {
                translate([0, 0, cross_h_total - ch]) cube([cl - 1.5, cw - 1.5, 0.01], center = true);
                translate([0, 0, cross_h_total]) cube([cl - 1.5 - ch*2, cw - 1.5 - ch*2, 0.01], center = true);
            } else {
                translate([0, 0, cross_h_total]) cube([cl - 1.5, cw - 1.5, 0.01], center = true);
            }
        }
    }
}

// --- МОДУЛИ ---

module matrix() {
    module base_shape() { rounded_square(inner_size, safe_r_matrix); }
    difference() {
        union() {
            translate([0, 0, (blade_h + transition_h)/2]) linear_extrude(height = total_h - (blade_h + transition_h), center = true) offset(r = wall_thick) base_shape();
            translate([0, 0, -total_h/2 + blade_h]) hull() { linear_extrude(0.1) offset(r = blade_edge) base_shape(); translate([0,0,transition_h]) linear_extrude(0.1) offset(r = wall_thick) base_shape(); }
            translate([0, 0, -total_h/2 + blade_h/2]) linear_extrude(height = blade_h, center = true) offset(r = blade_edge) base_shape();
        }
        linear_extrude(height = total_h + 10, center = true) base_shape();
        for(i=[-1,1]) translate([0, i*(outer_size/2 - actual_slot_depth/2), bar_z_pos]) cube([main_w + comp, actual_slot_depth + 0.1, bar_slot_h + 0.1], center = true);
    }
}

module plunger_plate() {
    module vent_hole() {
        translate([0,0,-p_h/2 - 0.1]) cylinder(h=2.5, d=vent_d, $fn=16);
        translate([0,0, -p_h/2 + 2.1]) cylinder(h=p_h + 1, d1=vent_d, d2=vent_top_d, $fn=24);
    }
    difference() {
        union() {
            translate([0, 0, -p_h/2 + rim_h/2]) linear_extrude(height = rim_h, center = true) rounded_square(plunger_size, safe_r_plunger);
            hull() { translate([0, 0, -p_h/2 + rim_h - 0.1]) linear_extrude(0.1) rounded_square(plunger_size, safe_r_plunger); translate([0, 0, p_h/2]) linear_extrude(0.1) rounded_square(plunger_size - 4, safe_r_plunger); }
        }
        translate([0, 0, -p_h/2 - 0.1]) cross_core(gap = cross_fit_gap, with_chamfer = false);
        for(i=[-1,1]) translate([0, i*dist/2, p_h/2 - 7.5]) cylinder(h=8, d=rod_d + comp, $fn=32);
        
        safe_margin = 2.5; work_area = plunger_size - (safe_margin + vent_top_d/2) * 2;
        count = floor(work_area / 8.5); 
        if (count > 0) {
            step = work_area / count;      
            for(ix = [0 : count], iy = [0 : count]) {
                x = -work_area/2 + ix * step; y = -work_area/2 + iy * step;
                in_cross = (abs(x) < (cross_L/2 + 3) && abs(y) < (cross_w/2 + 3)) || (abs(y) < (cross_L/2 + 3) && abs(x) < (cross_w/2 + 3));
                d1 = sqrt(pow(x, 2) + pow(y - dist/2, 2)); d2 = sqrt(pow(x, 2) + pow(y + dist/2, 2));
                if (!in_cross && d1 > (rod_d/2 + 2) && d2 > (rod_d/2 + 2)) translate([x, y, 0]) vent_hole();
            }
        }
    }
}

module plunger_cap(extra_off = 0) {
    union() {
        minkowski() { linear_extrude(height = cap_base_h - 1) rounded_square(plunger_size - 2, safe_r_plunger - 1); sphere(r = 1, $fn=16); }
        translate([0, 0, cap_base_h - 1]) cross_core(gap = 0, with_chamfer = true, extra_offset = extra_off);
    }
}

module crossbar() {
    bar_w_total = outer_size + (28 * 2); 
    difference() {
        union() {
            minkowski() {
                hull() {
                    translate([0, 0, (bar_h - top_round_r)/2]) cube([main_w - 2*top_round_r, outer_size - 2*top_round_r, bar_h - top_round_r], center=true);
                    for(i=[-1,1]) translate([0, i * (bar_w_total/2 - 5), bar_h - top_round_r - 1]) cylinder(r=main_w/2 - top_round_r, h=1, center=true, $fn=64);
                }
                sphere(r=top_round_r, $fn=32);
            }
        }
        translate([0, 0, -5.1]) cube([main_w + 10, bar_w_total + 10, 10], center=true);
        for(i=[-1,1]) translate([0, i*dist/2, -0.5]) {
            cylinder(h = bar_h + 2, d = rod_d + comp + play, $fn=64);
            cylinder(h = 4, d1 = rod_d + 4, d2 = rod_d + comp + play, $fn=64); 
            translate([0,0, bar_h - 3]) cylinder(h = 4.5, d1 = rod_d + comp + play, d2 = rod_d + 4, $fn=64); 
        }
        for(i=[-1,1]) translate([0, i*(inner_size/2 + (wall_thick - actual_slot_depth)/2), bar_slot_h/2 - 0.1])
            cube([main_w + 5, (wall_thick - actual_slot_depth) + comp, bar_slot_h + 0.2], center=true);
        translate([0, 0, -0.1]) cylinder(h = cross_h_top + 2.1, d = cross_L + 2, $fn=64); 
    }
}

module handle() {
    r_s = 2; h_l = 80;
    difference() {
        union() {
            minkowski() {
                hull() { 
                    translate([0,0,0.1]) cube([18-2*r_s, h_l-2*r_s, 0.1], center=true); 
                    translate([0,0,9]) rotate([0, 90, 0]) scale([1, h_l/18, 1]) cylinder(h=18-2*r_s, d=16, center=true); 
                }
                sphere(r=r_s, $fn=16);
            }
            for(i=[-1,1]) translate([0, i*dist/2, 0]) cylinder(h=1.5, d=rod_d + 4, $fn=32);
        }
        // Глухие отверстия
        for(i=[-1,1]) translate([0, i*dist/2, -5]) cylinder(h=19, d=rod_d + comp, $fn=32);
    }
}

module d_rod() {
    rotate([90, 90, 0]) intersection() {
        cylinder(h=115, d=rod_d, center=true, $fn=64);
        translate([0, 1.3, 0]) cube([rod_d, rod_d, 120], center=true);
    }
}

// --- ВЫВОД ---

module full_assembly() {
    matrix(); 
    translate([0, 0, bar_z_pos]) color("indianred") crossbar();
    translate([0, 0, bar_z_pos - 15]) { 
        color("silver") plunger_plate(); 
        translate([0, 0, -p_h/2 - cap_base_h + 1.2]) color("orange") plunger_cap(extra_off = cross_test_offset); 
    }
    for(i = [-1, 1]) translate([0, i*dist/2, bar_z_pos + 45]) rotate([0,-90,90]) color("gray") d_rod();
    translate([0, 0, bar_z_pos + 95]) color("darkslategray") handle();
}

if (view_mode == "assembly") {
    full_assembly();
} else if (view_mode == "section") {
    difference() { 
        full_assembly(); 
        rotate([0, 0, (section_axis == "X") ? 0 : 90]) 
            translate([150, 0, 0]) cube([300, 300, 300], center=true); 
    }
} else if (view_mode == "test_fit") {
    intersection() { plunger_plate(); cube([20,20,30], center=true); }
    translate([40,0,0]) intersection() { plunger_cap(extra_off = cross_test_offset); cube([20,20,30], center=true); }
} else if (view_mode == "all") {
    matrix(); 
    translate([outer_size + 80, 0, 0]) crossbar(); 
    translate([-outer_size - 80, 0, 5]) plunger_plate();
    translate([outer_size + 80, outer_size + 50, 0]) plunger_cap(extra_off = cross_test_offset);
    translate([0, -outer_size - 100, 0]) handle();
    for(i=[-1,1]) translate([i*25, outer_size + 80, 50]) rotate([0,-90,0]) d_rod();
} else {
    if(view_mode=="matrix") matrix();
    if(view_mode=="plunger") plunger_plate();
    if(view_mode=="cap") plunger_cap(extra_off = cross_test_offset);
    if(view_mode=="bar") crossbar();
    if(view_mode=="handle") handle();
    if(view_mode=="rods") for(i=[-1,1]) translate([i*25, 0, 50]) rotate([0,-90,0]) d_rod();
}
