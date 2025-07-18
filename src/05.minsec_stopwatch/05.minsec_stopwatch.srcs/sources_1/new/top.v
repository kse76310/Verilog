`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input [7:0] sw,
    input [2:0] btn,
    output [3:0] an,
    output [7:0] seg,
    output [15:0] led
);

    // 모듈 간 연결을 위한 와이어 선언
    wire [2:0]  debounced_btn;
    wire        run_stop;
    wire        clear;
    wire [4:0]  hour_count;
    wire [5:0]  min_count;
    wire [5:0] sec_count;
    wire [13:0] stopwatch_count;
    wire [13:0] seg_data_wire;
    wire animation_active_wire;
    assign led[9] = animation_active_wire;

    // 1. 스톱워치 
    stopwatch_core u_stopwatch_core(
        .clk(clk),
        .reset(reset),
        .run_stop(run_stop), // u_btn_command_controller에서 오는 제어 신호
        .clear(clear),       // u_btn_command_controller에서 오는 제어 신호
        .hour_count(hour_count),
        .min_count(min_count),
        .sec_count(sec_count),
        .stopwatch_count(stopwatch_count)
    );

    // 2. 버튼 디바운서
    
    button_debounce u_button_debounce(
        .i_clk(clk), 
        .i_reset(reset), 
        .i_btn(btn),
        .o_debounced_btn(debounced_btn)
    );

    // 3. 버튼 명령어 컨트롤러
    btn_command_controller u_btn_command_controller(
        .clk(clk), 
        .reset(reset),
        .btn(debounced_btn), // 디바운싱된 버튼 입력을 받음
        .sw(sw),
        .stopwatch_count(stopwatch_count),
        .run_stop(run_stop), // 스톱워치 제어 신호 출력
        .clear(clear),       // 스톱워치 제어 신호 출력
        .seg_data(seg_data_wire), // FND 컨트롤러로 데이터 출력
        .animation_active(animation_active_wire),
        .led(led)   
    );

    // 4. FND 컨트롤러
    fnd_controllor u_fnd_controllor(
        .clk(clk),
        .reset(reset),
        .input_data(seg_data_wire), // u_btn_command_controller에서 데이터를 받음
        .seg(seg),
        .an(an),
        .animation_active(animation_active_wire) 
    );

endmodule