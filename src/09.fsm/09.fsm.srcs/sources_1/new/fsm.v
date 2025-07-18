`timescale 1ns / 1ps

module fsm(
    input clk,reset,
    input btnU,
    input btnD,
    output reg [15:0] led // LED 출력
    );

    reg[15:0] r_led;
    reg[6:0] sr7;
    wire[1:0] w_btn_debounce;
    reg prev_btn_U = 0;
    reg prev_btn_D = 0;
    wire btn_U_pulse = w_btn_debounce[0] & ~prev_btn_U;
    wire btn_D_pulse = w_btn_debounce[1] & ~prev_btn_D;

    parameter IDLE          = 3'b000;
    parameter GOT_ONE       = 3'b001;
    parameter GOT_ZERO      = 3'b010;
    parameter  DETECT_00    = 3'b011;
    parameter DETECT_11     = 3'b100;

    reg [2:0] state, next_state;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            btnU_d1 <= 1'b0;
            btnU_d2 <= 1'b0;
            btnD_d1 <= 1'b0;
            btnD_d2 <= 1'b0;
        end else begin
            btnU_d1 <= btnU;
            btnU_d2 <= btnU_d1;
            btnD_d1 <= btnD;
            btnD_d2 <= btnD_d1;
        end
    end
    my_btn_debounce u_my_btn_debounce(
        
    );

endmodule
