`timescale 1ns / 1ps


module stopwatch_core(
    input clk,              // 50MHz 클럭 입력
    input reset,            // 리셋 버튼 (Active High)
    input run_stop,       // 시작/정지 토글 버튼
    input clear,
    output reg [4:0] hour_count,
    output reg [5:0] min_count,
    output reg [12:0] sec_count,
    output reg [13:0] stopwatch_count
);

   // 1/100초 (0.01초)를 만들기 위한 카운터. 50MHz/500,000 = 100Hz
    localparam HUNDREDTH_SEC_TICK = 500_000; 
    reg [18:0] tick_counter = 0;

    // always 블록은 단 하나만 사용합니다.
    always @(posedge clk or posedge reset) begin
        
        // 1. 비동기 리셋을 최우선으로 처리합니다.
        if (reset) begin
            tick_counter    <= 0;
            hour_count      <= 0;
            min_count       <= 0;
            sec_count       <= 0;
            stopwatch_count <= 0;
        end
        // 2. 그 다음, 동기 클리어 신호를 처리합니다. (리셋이 아닐 때)
        else if (clear) begin
            tick_counter    <= 0;
            hour_count      <= 0;
            min_count       <= 0;
            sec_count       <= 0;
            stopwatch_count <= 0;
        end
        // 3. run_stop이 1일 때만 카운터를 동작시킵니다.
        else if (run_stop) begin
            
            // 1/100초를 세는 기본 카운터
            if (tick_counter < HUNDREDTH_SEC_TICK - 1) begin
                tick_counter <= tick_counter + 1;
            end
            else begin
                tick_counter <= 0; // 카운터 리셋
                
                // 1/100초 카운터 (0-99)
                if (stopwatch_count == 99) begin
                    stopwatch_count <= 0;
                    
                    // 초 카운터 (0-59)
                    if (sec_count == 59) begin
                        sec_count <= 0;

                        // 분 카운터 (0-59)
                        if (min_count == 59) begin
                            min_count <= 0;
                            hour_count <= hour_count + 1; // 시간은 계속 증가
                        end else begin
                            min_count <= min_count + 1;
                        end
                    end else begin
                        sec_count <= sec_count + 1;
                    end
                end else begin
                    stopwatch_count <= stopwatch_count + 1;
                end
            end
        end
        // run_stop이 0이면 아무것도 하지 않고 현재 시간 값을 유지합니다.
    end

endmodule
