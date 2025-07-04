`timescale 1ns / 1ps

// 스톱워치 제어 및 FND 출력 데이터 생성을 담당하는 모듈
// 수정: ANSI-style 포트 선언 방식으로 변경
module btn_command_controller(
    input clk,
    input reset,
    input [7:0] sw,
    input [2:0] debounce_btn,    // [0]:모드변경, [1]:시작/정지, [2]:초기화
    input [9:0] ms,              // ms 입력은 현재 사용되지 않으나, 추후 표시를 위해 유지
    input [5:0] sec,             // 초 입력
    input [5:0] min,             // 분 입력
    output reg clear,           // 스톱워치 초기화 신호
    output reg run_stop,        // 스톱워치 시작/정지 신호
    output reg [15:0] fnd_data         // FND에 표시될 데이터
);

    // --- 모드 정의 ---
    parameter STOPWATCH_MODE = 2'b00;
    parameter SLIDE_SW_MODE  = 2'b01;

    // --- 내부 레지스터 ---
    reg [1:0] r_mode = STOPWATCH_MODE;
    reg prev_btn_mode = 1'b0;
    reg prev_btn_run = 1'b0;


    // 1. 모드 변경 로직 (버튼 0)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_mode <= STOPWATCH_MODE;
            prev_btn_mode <= 1'b0;
        end else begin
            if (debounce_btn[0] && !prev_btn_mode) begin
                r_mode <= (r_mode == SLIDE_SW_MODE) ? STOPWATCH_MODE : r_mode + 1;
            end
            prev_btn_mode <= debounce_btn[0];
        end
    end

    // 2. 스톱워치 제어 신호 생성 로직 (버튼 1, 2)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            run_stop <= 1'b0; // 정지 상태에서 시작
            clear <= 1'b0;
            prev_btn_run <= 1'b0;
        end else begin
            // 시작/정지 버튼 (토글)
            if (debounce_btn[1] && !prev_btn_run) begin
                run_stop <= ~run_stop;
            end
            prev_btn_run <= debounce_btn[1];

            // 초기화 버튼 (누를 때만 1)
            clear <= debounce_btn[2];
        end
    end

    // 3. FND에 보낼 데이터 선택 로직
    always @(*) begin
        case(r_mode)
            STOPWATCH_MODE: begin
                // 수정: 실제 min, sec 값을 조합하여 fnd_data 생성
                // 4자리 FND에 분(2자리), 초(2자리)를 표시하도록 데이터 조합
                // 예: {min[5:0], sec[5:0]} -> {001110, 010101}
                // fnd_controller가 BCD를 받는다면 변환이 필요하지만,
                // 우선 이진값을 그대로 전달합니다.
                fnd_data = {4'b0, min, sec}; // {4비트 공백, 6비트 분, 6비트 초} -> 총 16비트
            end
            SLIDE_SW_MODE: begin
                fnd_data = {8'b0, sw}; // 스위치 값을 FND에 표시
            end
            default: begin
                fnd_data = 16'h0000;
            end
        endcase
    end

endmodule