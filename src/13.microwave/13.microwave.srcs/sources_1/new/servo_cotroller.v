`timescale 1ns / 1ps
module pwm_generator (
    input wire clk,
    input wire reset,
    input wire [1:0] position_select, // 01: 닫힘, 10: 열림
    output reg pwm_out
);

    // --- 상수 정의 (100MHz 클럭 기준) ---
    localparam PERIOD_COUNT = 2_000_000;       // 20ms
    localparam CLOSED_PULSE_COUNT = 100_000;   // 1ms (문 닫힘)
    localparam OPEN_PULSE_COUNT = 200_000;     // 2ms (문 열림)

    // --- 내부 레지스터 ---
    reg [$clog2(PERIOD_COUNT)-1:0] period_counter;
    reg [$clog2(PERIOD_COUNT)-1:0] duty_count;

    // --- 1. 주기 카운터 로직 (완성된 예시) ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            period_counter <= 0;
        end else if (period_counter < PERIOD_COUNT - 1) begin
            period_counter <= period_counter + 1;
        end else begin
            period_counter <= 0;
        end
    end

    // --- 2. 듀티 카운터 로직 ---
    always @(*) begin
        // FSM에서 받은 position_select 입력에 따라
        case (position_select)
            2'b01: duty_count = CLOSED_PULSE_COUNT;
            2'b10: duty_count = OPEN_PULSE_COUNT;
            default: duty_count = 0; // 정지 또는 그 외의 경우
        endcase
    end

    // --- 3. PWM 출력 생성 로직 ---
    
    always @(posedge clk or posedge reset) begin
        if(reset)begin
            pwm_out <= 1'b0;
        end else begin
            pwm_out <= (period_counter <duty_count);
        end
    end

endmodule