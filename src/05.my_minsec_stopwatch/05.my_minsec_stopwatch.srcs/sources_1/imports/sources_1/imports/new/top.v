`timescale 1ns / 1ps

module top(
    input clk,
    input reset,        // btnU
    input [2:0] btn,
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
);

wire [2:0] w_debounced_btn;
wire [13:0] w_seg_data;
wire [4:0] w_hour_count;
wire [5:0] w_min_count;
wire [12:0] w_sec_count;
wire [13:0] w_stopwatch_count;
wire w_run_stop;
wire w_clear;
wire w_tick;

stopwatch_core u_stopwatch_core(
    .clk(clk),              // 50MHz 클럭 입력
    .reset(reset),            // 리셋 버튼 (Active High)
    .run_stop(w_run_stop),       // 시작/정지 토글 버튼
    .clear(clear),
    .hour_count(w_hour_count),
    .min_count(w_min_count),
    .sec_count(w_sec_count),
    .stopwatch_count(w_stopwatch_count)
);

btn_command_controller u_btn_command_controller(
    .clk(clk),
    .reset(reset),
    .sw(sw),
    .debounced_btn(w_debounced_btn),    // [0]:모드변경, [1]:시작/정지, [2]:초기화
    .hour_count(w_hour_count),
    .min_count(w_min_count),
    .sec_count(w_sec_count),
    .stopwatch_count(w_stopwatch_count),
    .clear(clear),
    .run_stop(w_run_stop),
    .seg_data(w_seg_data),
    .led(led)

);

fnd_controller u_fnd_controller(
    .clk(clk),
    .reset(reset),
    .input_data(w_seg_data),
    .seg(seg),
    .an(an)    // 자릿수 선택 
);

btn_debouncer u_btn_debouncer (
    .clk(clk),          // 시스템 클럭 (타이머를 위해)
    .reset(reset),        // 리셋 신호
    .noise_btn(btn),       // 물리 버튼에서 들어오는 불안정한 입력
    .tick(w_tick),
    .clean_btn(w_debounced_btn)
);

endmodule