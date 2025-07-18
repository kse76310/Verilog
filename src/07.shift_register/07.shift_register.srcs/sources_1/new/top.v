`timescale 1ns / 1ps

module top(clk, reset, btn, shift_led, led0);
    input clk, reset;
    input [1:0] btn;

    output [6:0] shift_led;
    output led0;

    button_debounce U_btn_debounce(.clk(clk), .reset(reset), .btn(btn), .clean_btn({btnU,btnD}));

    shift_register U_shift_register(.clk(clk), .reset(reset), .btnU(btnU), .btnD(btnD), .dout(led0), .sr7(shift_led));


endmodule

