`timescale 1ns / 1ps

module btn_command_controller(
    // --- 모든 기능을 사용하기 위한 포트 목록 ---
    input clk,
    input reset,
    input [2:0] btn,                  // 디바운싱된 버튼 입력 [L, C, R]
    input [7:0] sw,                   // 미사용 입력
    input [13:0] stopwatch_count,     // stopwatch_core에서 오는 시간 값
    
    output reg run_stop,              // stopwatch_core 제어 신호
    output reg clear,                 // stopwatch_core 제어 신호
    output reg [13:0] seg_data,       // FND에 표시될 데이터
    output reg animation_active,      // FND 애니메이션 활성화 신호
    output reg [15:0] led             // 16개 LED
);

    parameter MODE_STOPWATCH = 1'b0, MODE_UP_DOWN = 1'b1;
    reg mode, is_running;
    reg [13:0] up_down_counter;
    reg [2:0] btn_ff1, btn_ff2;
    wire btn0_edge, btn1_edge, btn2_edge;
    
    // 수정: 가독성을 위해 엣지 감지 로직을 두 줄로 분리
    always @(posedge clk) begin
        btn_ff1 <= btn;
        btn_ff2 <= btn_ff1;
    end
    
    assign btn0_edge = ~btn_ff2[0] && btn_ff1[0]; // Mode
    assign btn1_edge = ~btn_ff2[1] && btn_ff1[1]; // Run/Stop
    assign btn2_edge = ~btn_ff2[2] && btn_ff1[2]; // Clear

    // 순차 로직: 내부 상태(mode, is_running 등)를 관리
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mode <= MODE_STOPWATCH;
            is_running <= 1'b0;
            up_down_counter <= 0;
            clear <= 1'b0;
        end else begin
            clear <= 1'b0; // clear 신호는 버튼 누를 때만 1-cycle 동안 활성화

            // 수정: if-else if 구조로 버튼 입력에 우선순위 부여
            if (btn0_edge) begin // btn[0] (모드 변경)
                mode <= ~mode;
                is_running <= 1'b0;
            end else if (btn1_edge) begin // btn[1] (동작/정지)
                is_running <= ~is_running;
            end else if (btn2_edge) begin // btn[2] (초기화)
                is_running <= 1'b0;
                if (mode == MODE_STOPWATCH) begin
                    clear <= 1'b1;
                end else begin // MODE_UP_DOWN
                    up_down_counter <= 0;
                end
            end

            // UP/DOWN 카운터 모드이고, 동작 상태일 때만 카운터 증가
            if (mode == MODE_UP_DOWN && is_running) begin
                up_down_counter <= up_down_counter + 1;
            end
        end
    end

    // 조합 로직: 현재 상태에 따라 최종 출력을 결정
    always @(*) begin
        // --- 모드에 따라 FND 데이터 결정 ---
        if (mode == MODE_STOPWATCH) begin
            seg_data = stopwatch_count;
            animation_active = ~is_running; // 정지 상태일 때 애니메이션 활성화
        end else begin // MODE_UP_DOWN
            seg_data = up_down_counter;
            animation_active = 1'b0;
        end

        // 수정: run_stop은 모드와 관계없이 is_running 상태를 그대로 출력
        run_stop = is_running;

        // 수정: LED 출력의 기본값을 먼저 설정하여 래치(latch) 방지
        led = 16'b0; 
        if (mode == MODE_STOPWATCH) begin
            led[15] = 1'b1;
        end else begin // MODE_UP_DOWN
            led[14] = 1'b1;
        end
        // 여기에 다른 LED 로직 추가 가능
    end
endmodule