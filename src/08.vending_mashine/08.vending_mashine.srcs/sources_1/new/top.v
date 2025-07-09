`timescale 1ns / 1ps


module top (
    input clk,         // 100MHz 클럭
    input reset,        // 리셋 버튼
    input [3:0]btn,        // 100원 투입
    output [14:0] led,
    output[7:0] seg,   // 7-Segment 출력
    output[3:0] an     // FND 자리 선택
);

    wire [7:0] w_fnd_seg;
    wire [3:0] w_fnd_an;
    wire [14:0] w_money;
    wire [14:0] w_cup;
    wire [3:0] W_btn_debounce;
    // vending_machine 모듈을 인스턴스화(instantiate) 합니다.

    my_vending_machine u_fsm(
        .clk(clk),
        .reset(reset),
        .i_btn(W_btn_debounce[3:0]),
        .cup(w_cup[14:0]),
        .money(w_money)
    );

endmodule
