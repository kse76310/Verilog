`timescale 1ns / 1ps

module top_micro(
    input clk, reset,
    input enable, // New enable port
    input btnL,btnC,btnR,btnU,btnD,
    input door_is_open,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] an,
    output fan_in1,
    output fan_in2,
    output fan_ena,
    output pwm_out,
    output buzzer_out
    );
    
    wire w_timer_done, w_time_is_zero, w_done_timer_finished;
    wire w_timer_en, w_timer_clear, w_done_timer_en;
    wire w_add_1m, w_add_10s, w_load_30s;
    wire w_btnL, w_btnC, w_btnR, w_btnU, w_btnD;
    wire [3:0] w_bcd_min_t, w_bcd_min_o, w_bcd_sec_t, w_bcd_sec_o;
    wire [1:0] w_servo_pos_select;
    wire w_fan_on;
    wire w_beep_trigger;
    wire w_alarm_trigger;
    wire w_buzzer_en;

    button_debounce u_micro_btnL(.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));
    button_debounce u_micro_btnC(.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    button_debounce u_micro_btnR(.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));
    button_debounce u_micro_btnU(.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    button_debounce u_micro_btnD(.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));

    fsm_micro u_fsm(
        .clk(clk),
        .reset(reset),
        .enable(enable), // Connect the new enable port
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
        .led_done_n(led[1]),
        .servo_pos_select(w_servo_pos_select),
        .door_is_open(door_is_open),
        .fan_on(w_fan_on),
        .beep_trigger(w_beep_trigger),
        .alarm_trigger(w_alarm_trigger)
    );

    pwm_generator u_micro_pwm(
        .clk(clk),
        .reset(reset),
        .position_select(w_servo_pos_select), // 01: 닫힘, 10: 열림
        .pwm_out(pwm_out)
    );

    beep_generator u_beep (
        .clk(clk),
        .reset(reset),
        .beep_trigger(w_beep_trigger),
        .alarm_trigger(w_alarm_trigger),
        .buzzer_en(w_buzzer_en)
    );

    buzzer_driver u_micro_buzzer (
        .clk(clk),
        .reset(reset),
        .enable(w_buzzer_en),
        .buzzer_out(buzzer_out)
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
        .an(an)     // 자릿수 선택

    );

    done_timer u_done_timer (
        .clk(clk),
        .reset(reset),
        .en(w_done_timer_en),       // FSM이 DONE 상태일 때 '1'이 됨
        .finished(w_done_timer_finished)  // 3초가 되면 1-cycle 펄스 출력
    );

    // L298N 제어 로직
    assign fan_in1 = w_fan_on; // 팬이 켜질 때 IN1=1
    assign fan_in2 = 1'b0;   // IN2는 항상 0으로 고정 (정방향)
    assign fan_ena = w_fan_on; // 팬이 켜질 때 Enable
    assign led[11] = door_is_open;      // FSM이 타이머를 켜라고 명령하는가?
    assign led[10] = w_done_timer_finished;  // 타이머가 끝났다고 신호를 보내는가?
endmodule
