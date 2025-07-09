`timescale 1ns / 1ps

module button_debounce(clk, reset, btn, clean_btn);
    input clk, reset;
    input [1:0] btn;
    output [1:0] clean_btn;

    wire w_out_clk;
    wire [1:0] w_Q1, w_Q2;

    clock_8Hz U_8Hz(.clk(clk), .reset(reset), .clk_8Hz(w_out_clk));

    D_FF U_dff1(.clk(w_out_clk), .reset(reset), .d(btn), .q(w_Q1));

    D_FF U_dff2(.clk(w_out_clk), .reset(reset), .d(w_Q1), .q(w_Q2));

    assign clean_btn = w_Q1 & ~w_Q2;
endmodule
