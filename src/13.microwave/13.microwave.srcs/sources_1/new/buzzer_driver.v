`timescale 1ns / 1ps

module buzzer_driver (
    input wire clk,
    input wire reset,
    input wire enable,      // 소리를 켜라는 명령 (레벨 신호)
    output reg buzzer_out   // 실제 부저 핀으로 나갈 스퀘어 웨이브
);

    // 1kHz 톤을 만들기 위한 상수
    localparam CLOCK_FREQ = 100_000_000; // 100MHz
    localparam BEEP_FREQ = 1000;         // 1kHz 톤
    // 1kHz의 반주기(0.5ms)에 해당하는 클럭 카운트
    localparam HALF_PERIOD = CLOCK_FREQ / (BEEP_FREQ * 2); // 50,000

    reg [$clog2(HALF_PERIOD)-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            buzzer_out <= 1'b0;
        end else if (enable) begin // '소리 내라' 명령이 있을 때만 동작
            if (counter >= HALF_PERIOD - 1) begin
                counter <= 0;
                buzzer_out <= ~buzzer_out; // 출력 토글
            end else begin
                counter <= counter + 1;
            end
        end else begin
            // enable이 0일 때는 카운터와 출력을 0으로 유지
            counter <= 0;
            buzzer_out <= 1'b0;
        end
    end

endmodule