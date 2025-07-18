`timescale 1ns / 1ps

module timer_counter(
    input clk, reset,
    input timer_en, timer_clear,
    input add_1m, add_10s, load_30s,
    output timer_done, timer_is_zero,
    output reg [3:0] bcd_minutes_tens,
    output reg [3:0] bcd_minutes_ones,
    output reg [3:0] bcd_seconds_tens,
    output reg [3:0] bcd_seconds_ones
    );

    //1초 펄스 생성기
    localparam ONE_SEC_COUNT = 100_000_000; // 100MHz 클럭 기준
    reg [$clog2(ONE_SEC_COUNT)-1:0] one_sec_counter;
    reg one_sec_tick; // 1초마다 1클럭 동안 1이 되는 신호
    reg prev_timer_clear, prev_add_1m, prev_add_10s, prev_load_30s;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            one_sec_counter <= 0;
            one_sec_tick <= 1'b0;
        end else begin
            if (one_sec_counter == ONE_SEC_COUNT - 1) begin
                one_sec_counter <= 0;
                one_sec_tick <= 1'b1; // 1초가 되는 순간, 1클럭 펄스 발생!
            end else begin
                one_sec_counter <= one_sec_counter + 1;
                one_sec_tick <= 1'b0;
            end
        end
    end

    // 시간 저장 레지스터
    reg [12:0] total_seconds;

    //명령 처리 및 카운트다운 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            total_seconds <= 0;
            prev_timer_clear <= 0;
            prev_add_1m <= 0;
            prev_add_10s <= 0;
            prev_load_30s <= 0;
        end else begin

            prev_timer_clear <= timer_clear;
            prev_add_1m <= add_1m;
            prev_add_10s <= add_10s;
            prev_load_30s <= load_30s;

            if(timer_clear && !prev_timer_clear)begin
                total_seconds <= 0;
            end else if(load_30s && !prev_load_30s)begin
                total_seconds <= 30; 
            end else if(add_1m && !prev_add_1m) begin
                total_seconds <= total_seconds + 60;
            end else if(add_10s && !prev_add_10s) begin
                total_seconds <= total_seconds + 10;
            // 카운트다운 로직
            end else if (one_sec_tick && timer_en && total_seconds > 0) begin
                total_seconds <= total_seconds - 1;
            end
        end
    end

    assign timer_is_zero = (total_seconds == 0);
    assign timer_done = (one_sec_tick && timer_en && total_seconds == 1);
// --- BCD 변환 로직 ---
    reg [6:0] minutes;
    reg [5:0] seconds;

    always @(*) begin
        // 1. 전체 초를 '분'과 '초'로 변환
        minutes = total_seconds / 60;
        seconds = total_seconds % 60;

        // 2. '분'을 10의 자리와 1의 자리로 분리
        bcd_minutes_tens = minutes / 10;
        bcd_minutes_ones = minutes % 10;

        // 3. '초'를 10의 자리와 1의 자리로 분리
        bcd_seconds_tens = seconds / 10;
        bcd_seconds_ones = seconds % 10;
    end

endmodule
