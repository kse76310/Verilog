`timescale 1ns / 1ps

module tv_ch(
    input clk,
    input rstn,
    input up,
    input dn,
    output reg [3:0] ch
    );
   
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            ch <= 4'h0; // 1. 리셋 조건은 최우선으로 처리
        else begin
            // 2. 리셋이 아닐 때, 입력 조합에 따라 동작 결정
            casex({up, dn})
                2'b10: ch <= (ch == 9) ? 0 : ch + 1; // UP만 눌렸을 때
                2'b01: ch <= (ch == 0) ? 9 : ch - 1; // DOWN만 눌렸을 때
                // default: 아무 일도 하지 않음 (ch 값 유지)
            endcase
        end
    end   
endmodule