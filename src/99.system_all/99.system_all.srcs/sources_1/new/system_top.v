`timescale 1ns / 1ps
//********************************************************************************
//
// Module: system_top.v
//
// Description:
//   - 최종 최상위 모듈
//   - sw[1:0] 입력에 따라 전자레인지, 스톱워치, 공조기 모드를 선택합니다.
//   - 00: 대기 (아무것도 안함)
//   - 01: 전자레인지 (top_micro)
//   - 10: 스톱워치 (my_top)
//   - 11: 공조기 (top)
//
//********************************************************************************

module system_top (
    //-- Global Signals from MY_BASYS3.xdc
    input clk,
    input reset,

    //-- User Inputs from MY_BASYS3.xdc
    input [7:0] sw,
    input btnU, btnL, btnC, btnD, // Individual buttons from XDC

    //-- User Outputs from MY_BASYS3.xdc
    output [15:0] led,
    output [7:0] seg,
    output [3:0] an,
    output buzzer_out,
    
    //-- UART from MY_BASYS3.xdc
    output RsTx,
    input  RsRx, // Note: RsRx is not used in any sub-module

    //-- Air Controller I/O from MY_BASYS3.xdc
    output fan_pwm_out,
    output fan_in1,
    output fan_in2,
    output trig_pin, // for ultrasonic
    input  echo_pin, // for ultrasonic

    //-- I/O for dht11 sensor
    inout  dht11_data_pin
);

    //================================================================
    // Wires and Registers
    //================================================================
    // Create a 3-bit vector for sub-modules that need it.
    // Mapping: btn[0]=btnL, btn[1]=btnC, btn[2]=btnD (Right button)
    wire [2:0] btn_vec = {btnD, btnC, btnL};

    //-- Sub-module output wires
    wire [7:0] micro_seg, stopwatch_seg, air_seg;
    wire [3:0] micro_an, stopwatch_an, air_an;
    wire [15:0] stopwatch_led;
    wire micro_buzzer, air_buzzer;
    wire micro_pwm_out;
    wire air_fan_pwm, air_fan_in1, air_fan_in2;
    wire air_trig, air_RsTx;

    //================================================================
    // Mode Controller
    //================================================================
    mode_controller u_mode_controller (
        .sw(sw[1:0]),
        .mode(mode)
    );

    //================================================================
    // Sub-module Instantiations
    //================================================================

    //-- 1. Microwave (top_micro)
    // Note: This module requires 5 buttons. We map them as follows:
    // btnL, btnC, btnR(->btnD), btnU, btnD(->GND)
    top_micro u_microwave (
        .clk(clk),
        .reset(reset),
        .enable(mode == 2'b01), // Enable only when in Microwave mode
        .btnL(btnL),
        .btnC(btnC),
        .btnR(btnD), // Map Right button to btnD
        .btnU(btnU),
        .btnD(1'b0), // Tie one of the microwave's down buttons to ground
        .door_is_open(sw[2]),
        .led(), // Microwave LEDs are not connected to top-level LEDs
        .seg(micro_seg),
        .an(micro_an),
        .fan_in1(), // Microwave fan control is internal
        .fan_in2(),
        .fan_ena(),
        .pwm_out(micro_pwm_out),
        .buzzer_out(micro_buzzer)
    );

    //-- 2. Stopwatch (my_top)
    my_top u_stopwatch (
        .clk(clk),
        .reset(reset),
        .enable(mode == 2'b10), // Enable only when in Stopwatch mode
        .btn(btn_vec), // Pass the 3-bit button vector
        .sw(sw),   // Pass all 8 switches
        .seg(stopwatch_seg),
        .an(stopwatch_an),
        .led(stopwatch_led)
    );

    //-- 3. Air Controller (top)
    // Note: This module is named `top` in `top_air.v`
    top u_air_controller (
        .clk(clk),
        .reset(reset),
        .enable(mode == 2'b11), // Enable only when in Air Controller mode
        .sw(sw),
        // Mapping: btnC->btn[0], btnU->btn[1], btnD->btn[2], btnL->not connected
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .echo_pin(echo_pin),
        .trig_pin(air_trig),
        .fan_pwm_out(air_fan_pwm),
        .fan_in1(air_fan_in1),
        .fan_in2(air_fan_in2),
        .buzzer_out(air_buzzer),
        .dht11_data_pin(dht11_data_pin),
        .RsTx(air_RsTx),
        .seg(air_seg),
        .an(air_an)
    );

    //================================================================
    // Output Assignments & Multiplexing
    //================================================================

    //-- FND Output Mux
    assign an = (mode == 2'b01) ? micro_an :
                (mode == 2'b10) ? stopwatch_an :
                (mode == 2'b11) ? air_an :
                4'hF; // Off in idle mode

    assign seg = (mode == 2'b01) ? micro_seg :
                 (mode == 2'b10) ? stopwatch_seg :
                 (mode == 2'b11) ? air_seg :
                 8'hFF; // Off in idle mode

    //-- Buzzer Output Mux
    assign buzzer_out = (mode == 2'b01) ? micro_buzzer :
                        (mode == 2'b11) ? air_buzzer :
                        1'b0; // Off for stopwatch and idle

    //-- Dedicated Outputs based on mode
    assign led = (mode == 2'b10) ? stopwatch_led : 16'h0000; // Only stopwatch uses LEDs
    assign RsTx = (mode == 2'b11) ? air_RsTx : 1'bz; // Only air_con uses UART TX

    assign fan_pwm_out = (mode == 2'b01) ? micro_pwm_out : 
                       (mode == 2'b11) ? air_fan_pwm : 
                       1'b0; // Off otherwise
    assign fan_in1 = (mode == 2'b11) ? air_fan_in1 : 1'b0;
    assign fan_in2 = (mode == 2'b11) ? air_fan_in2 : 1'b0;
    
    assign trig_pin = (mode == 2'b11) ? air_trig : 1'b0;
    

endmodule
