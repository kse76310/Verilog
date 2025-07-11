`timescale 1ns / 1ps

module top_micro(
    input clk, reset,
    input btnL,btnC,btnR,btnU,btnD,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] an
    );
    
    wire w_timer_done, w_time_is_zero, w_done_timer_finished;
    wire w_timer_en, w_timer_clear, w_done_timer_en;
    wire w_add_1m, w_add_10s, w_load_30s;
    wire w_btnL, w_btnC, w_btnR, w_btnU, w_btnD;
    wire [3:0] w_bcd_min_t, w_bcd_min_o, w_bcd_sec_t, w_bcd_sec_o;

    button_debounce u_btnL(.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));
    button_debounce u_btnC(.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    button_debounce u_btnR(.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));
    button_debounce u_btnU(.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    button_debounce u_btnD(.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));

    fsm_micro u_fsm(
        .clk(clk),
        .reset(reset),
        .btnL(w_btnL),
        .btnC(w_btnC),
        .btnR(w_btnR),
        .btnU(w_btnU),
        .btnD(w_btnD),
        .timer_done(w_timer_done),
        .timer_is_zero(w_time_is_zero),
        .done_timer_finished(w_done_timer_finished),
        .timer_en(w_timer_en),
        .timer_clear(w_timer_clear),
        .done_timer_en(w_done_timer_en),
        .add_1m(w_add_1m),
        .add_10s(w_add_10s),
        .load_30s(w_load_30s),
        .led_cooking_n(led[0]),
        .led_done_n(led[1])
    );

    timer_counter u_time_counter(
        .clk(clk),
        .reset(reset),
        .timer_en(w_timer_en), 
        .timer_clear(w_timer_clear),
        .add_1m(w_add_1m), 
        .add_10s(w_add_10s), 
        .load_30s(w_load_30s),
        .timer_done(w_timer_done), 
        .timer_is_zero(w_time_is_zero),
        .bcd_minutes_tens(w_bcd_min_t),
        .bcd_minutes_ones(w_bcd_min_o),
        .bcd_seconds_tens(w_bcd_sec_t),
        .bcd_seconds_ones(w_bcd_sec_o)
    );

    fnd_controller fnd_micro(
        .clk(clk),
        .reset(reset),
        .bcd_minutes_tens(w_bcd_min_t),
        .bcd_minutes_ones(w_bcd_min_o),
        .bcd_seconds_tens(w_bcd_sec_t),
        .bcd_seconds_ones(w_bcd_sec_o),
        .seg_data(seg),
        .an(an)     // 자릿수 선택)
    );

    done_timer u_done_timer (
        .clk(clk),
        .reset(reset),
        .en(w_done_timer_en),       // FSM이 DONE 상태일 때 '1'이 됨
        .finished(w_done_timer_finished)  // 3초가 되면 1-cycle 펄스 출력
);


endmodule
