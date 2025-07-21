`timescale 1ns / 1ps

module top(
    input clk, reset,
    input enable, // New enable port
    input [7:0] sw,
    // Button inputs
    input btnC, btnU, btnD, btnL,
    
    input echo_pin,
    output trig_pin,
    
    output fan_pwm_out,
    output fan_in1,
    output fan_in2,
    
    output buzzer_out,
    
    inout dht11_data_pin, // DHT11 Data Pin
    
    output RsTx, // UART TX output
    output [7:0] seg, // FND segment output
    output [3:0] an // FND anode output
    );

    // --- Wires ---
    wire [15:0] w_distance_cm;
    wire [39:0] w_dht11_out_data;
    wire [3:0] w_bcd_d1000, w_bcd_d100, w_bcd_d10, w_bcd_d1;
    wire w_tick_1s;
    wire w_btnC_clean, w_btnU_clean, w_btnD_clean, w_btnL_clean;
    wire [6:0] w_duty;
    wire w_buzzer_enable;

    // --- Sub-module Instantiations ---

    tick_generator #(
        .INPUT_FREQ(100_000_000), // Corrected to 100MHz
        .TICK_HZ(3)
    ) u_tick_generateor (
       .clk(clk),
       .reset(reset || !enable),
       .tick(w_tick_1s)
    );   

    ultrasonic u_ultrasonic(
        .clk(clk),
        .reset(reset || !enable),
        .start(w_tick_1s),
        .echo(echo_pin),
        .trig(trig_pin),
        .distance_cm(w_distance_cm),
        .measure_done()
    );

    pwm_controller u_pwm_controller(
        .clk(clk),
        .reset(reset || !enable),
        .duty(w_duty),
        .pwm_out(fan_pwm_out)
    );

    buzzer_driver u_buzzer_driver(
        .clk(clk),
        .reset(reset || !enable),
        .enable(w_buzzer_enable),
        .buzzer_out(buzzer_out)
    );

    uart_controller u_uart_controller(
        .clk(clk),
        .reset(reset || !enable),
        .send_data({w_bcd_d1000, w_bcd_d100, w_bcd_d10, w_bcd_d1}),
        .rx(1'b0),
        .rx_data(),
        .rx_done(),
        .tx(RsTx)
    );

    dht11_controller u_dht11_controller(
        .clk(clk),
        .reset(reset || !enable),
        .start_trigger(w_tick_1s),
        .dht11(dht11_data_pin),
        .out_dht11_data(w_dht11_out_data)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset || !enable),
        .bcd_minutes_tens(w_bcd_d1000),
        .bcd_minutes_ones(w_bcd_d100),
        .bcd_seconds_tens(w_bcd_d10),
        .bcd_seconds_ones(w_bcd_d1),
        .seg_data(seg),
        .an(an)
    );
    
    button_debounce u_btnC_debounce(.i_clk(clk), .i_reset(reset || !enable), .i_btn(btnC), .o_btn_clean(w_btnC_clean));
    button_debounce u_btnU_debounce(.i_clk(clk), .i_reset(reset || !enable), .i_btn(btnU), .o_btn_clean(w_btnU_clean));
    button_debounce u_btnD_debounce(.i_clk(clk), .i_reset(reset || !enable), .i_btn(btnD), .o_btn_clean(w_btnD_clean));
    button_debounce u_btnL_debounce(.i_clk(clk), .i_reset(reset || !enable), .i_btn(btnL), .o_btn_clean(w_btnL_clean));

    // --- Main Air Controller ---
    air_controller u_air_controller(
        .clk(clk),
        .reset(reset || !enable),
        .sw(sw),
        .w_btnC_clean(w_btnC_clean),
        .w_btnU_clean(w_btnU_clean),
        .w_btnD_clean(w_btnD_clean),
        .w_btnL_clean(w_btnL_clean),
        .distance_cm(w_distance_cm),
        .dht11_out_data(w_dht11_out_data),
        .duty(w_duty),
        .buzzer_enable(w_buzzer_enable),
        .o_bcd_d1000(w_bcd_d1000),
        .o_bcd_d100(w_bcd_d100),
        .o_bcd_d10(w_bcd_d10),
        .o_bcd_d1(w_bcd_d1)
    );

    // Fan direction control (fixed)
    assign fan_in1 = 1'b1;
    assign fan_in2 = 1'b0;

endmodule