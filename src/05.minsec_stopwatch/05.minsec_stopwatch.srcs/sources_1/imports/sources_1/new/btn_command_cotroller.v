`timescale 1ns / 1ps

module btn_command_controller(
    // --- 모든 기능을 사용하기 위한 포트 목록 ---
    input clk,
    input reset,
    input [2:0] btn,              // 디바운싱된 버튼 입력 [L, C, R]
    input [7:0] sw,               // 8개 슬라이드 스위치
    input [13:0] stopwatch_count, // stopwatch_core에서 오는 시간 값
    
    output reg run_stop,          // stopwatch_core 제어 신호
    output reg clear,             // stopwatch_core 제어 신호
    output reg [13:0] seg_data,   // FND에 표시될 데이터
    output reg animation_active,  // FND 애니메이션 활성화 신호
    output reg [15:0] led         // 16개 LED
);

    parameter MODE_STOPWATCH = 1'b0, MODE_UP_DOWN = 1'b1;
    reg mode, is_running;
    reg [13:0] up_down_counter;
    reg [2:0] btn_ff1, btn_ff2;
    wire btn0_edge, btn1_edge, btn2_edge;
    
    always @(posedge clk) {btn_ff1, btn_ff2} <= {btn, btn_ff1};
    assign btn0_edge = ~btn_ff2[0] && btn_ff1[0];
    assign btn1_edge = ~btn_ff2[1] && btn_ff1[1];
    assign btn2_edge = ~btn_ff2[2] && btn_ff1[2];

    always @(posedge clk or posedge reset) begin
    if (reset) begin
        mode <= MODE_STOPWATCH;
        is_running <= 1'b0;
        up_down_counter <= 0;
        clear <= 1'b0;
    end else begin
        clear <= 1'b0;

        // btn[0]을 누르면 모드를 변경하고, 항상 정지 상태로
        if (btn0_edge) begin
            mode <= ~mode;
            is_running <= 1'b0;
        end

        // btn[1]을 누르면 동작/정지 상태를 토글
        if (btn1_edge) begin
            is_running <= ~is_running;
        end

        // btn[2]를 누르면 현재 모드의 값을 초기화
        if (btn2_edge) begin
            is_running <= 1'b0;
            if (mode == MODE_STOPWATCH) begin
                clear <= 1'b1;
            end else begin
                up_down_counter <= 0;
            end
        end

        // UP/DOWN 카운터 모드이고, 동작 상태일 때만 카운터 증가
        if (mode == MODE_UP_DOWN && is_running) begin
            up_down_counter <= up_down_counter + 1;
        end
    end
end

    always @(*) begin
        // --- 모드에 따라 모든 출력값을 결정 ---
        if (mode == MODE_STOPWATCH) begin
            seg_data = stopwatch_count;
            run_stop = is_running;
            animation_active = ~is_running; // 정지 상태일 때 애니메이션 활성화

            led[15] = 1'b1; // 스톱워치 모드 LED 켜기
            led[14] = 1'b0;
        end else begin // MODE_UP_DOWN
            seg_data = up_down_counter;
            run_stop = 1'b0;
            animation_active = 1'b0;
            
            led[15] = 1'b0;
            led[14] = 1'b1; // 업/다운 모드 LED 켜기
        end

        // --- 다른 출력값 결정 ---
        // 아래 신호들은 모드에 상관없이 공통으로 적용
        led[13] = 1'b0;
        led[12:9] = 4'b0000;
        led[8] = is_running; // 동작 상태 LED
        led[7:0] = 8'b0;
    end
endmodule