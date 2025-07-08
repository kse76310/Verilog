`timescale 1ns / 1ps

module btn_debouncer (
    input clk,          // 시스템 클럭 (타이머를 위해)
    input reset,        // 리셋 신호
    input [2:0] noise_btn,       // 물리 버튼에서 들어오는 불안정한 입력
    input tick,
    output reg [2:0] clean_btn
);

    parameter  DEBOUNCE_TIME = 1_000_000;
    reg [$clog2(DEBOUNCE_TIME)-1:0] counter;
    reg [2:0] prev_btn_state;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            counter <= 0;
            clean_btn <= 0;
            prev_btn_state <= 0;
        end else begin
            if(noise_btn != prev_btn_state)begin
                prev_btn_state <= noise_btn;
                counter <= DEBOUNCE_TIME;
            end
                else if(counter != 0 && tick) begin
                    counter <= counter - 1;
                    if(counter == 1)
                        clean_btn <= noise_btn;
                end
            end 
        end

endmodule