`timescale 1ns / 1ps

module my_top(
    input clk,
    input reset,
    input enable, // New enable port
    input [2:0] btn, //
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0] w_btn_debounce;
    wire [3:0] w_bcd_d1000, w_bcd_d100, w_bcd_d10, w_bcd_d1;
    wire w_tick;

    wire [4:0] w_hour_count;
    wire [5:0] w_min_count;
    wire [12:0] w_sec_count;
    wire [13:0] w_stopwatch_count;
    wire w_clear;
    wire w_run_stop;
    wire w_anim_mode;
    
    stopwatch_core u_stopwatch_core(
        .clear(w_clear),
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop & enable), // Only run if enabled
        .hour_count(w_hour_count),
        .min_count(w_min_count),
        .sec_count(w_sec_count),
        .stopwatch_count(w_stopwatch_count)
    );

    // Debounce each button individually
    button_debounce u_btn0_debounce(
        .i_clk(clk),
        .i_reset(reset || !enable), // Reset if module is disabled
        .i_btn(btn[0]),
        .o_btn_clean(w_btn_debounce[0])
    );

    button_debounce u_btn1_debounce(
        .i_clk(clk),
        .i_reset(reset || !enable), // Reset if module is disabled
        .i_btn(btn[1]),
        .o_btn_clean(w_btn_debounce[1])
    );

    button_debounce u_btn2_debounce(
        .i_clk(clk),
        .i_reset(reset || !enable), // Reset if module is disabled
        .i_btn(btn[2]),
        .o_btn_clean(w_btn_debounce[2])
    );

    tick_generator #(
        .TICK_HZ(100) // Generate 100Hz tick for stopwatch
    ) u_tick_generator(    
        .clk(clk),
        .reset(reset || !enable), // Reset if module is disabled
        .tick(w_tick)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset || !enable), // Reset if module is disabled
        .bcd_minutes_tens(w_bcd_d1000),
        .bcd_minutes_ones(w_bcd_d100),
        .bcd_seconds_tens(w_bcd_d10),
        .bcd_seconds_ones(w_bcd_d1),
        .seg_data(seg),
        .an(an)
    );

    btn_command_controller u_btn_command_controller(
        .clk(clk),
        .reset(reset || !enable), // Reset if module is disabled
        .btn(w_btn_debounce),
        .sw(sw),
        .hour_count(w_hour_count),
        .min_count(w_min_count),
        .sec_count(w_sec_count),
        .stopwatch_count(w_stopwatch_count),
        .o_bcd_d1000(w_bcd_d1000),
        .o_bcd_d100(w_bcd_d100),
        .o_bcd_d10(w_bcd_d10),
        .o_bcd_d1(w_bcd_d1),
        .led(led),
        .clear(w_clear),
        .run_stop(w_run_stop),
        .anim_mode(w_anim_mode)
    );    

endmodule
