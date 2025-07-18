// button_debounce.v 파일의 내용을 이걸로 교체하세요.

`timescale 1ns / 1ps

module button_debounce(
    input i_clk,
    input i_reset,
    input [2:0] i_btn, // ◀◀ 3비트 입력으로 수정
    output [2:0] o_debounced_btn
);

    // for-generate 구문을 사용하여 3개의 디바운싱 회로를 각각 생성
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : DEBOUNCE_LOOP

            localparam DEBOUNCE_TIME = 100_000; // 100MHz 클럭 기준 약 1ms

            reg [16:0] debounce_counter;
            reg btn_sync1, btn_sync2;
            reg r_debounced_btn;

            // 입력 동기화
            always @(posedge i_clk or posedge i_reset) begin
                if (i_reset) begin
                    btn_sync1 <= 1'b0;
                    btn_sync2 <= 1'b0;
                end else begin
                    btn_sync1 <= i_btn[i];
                    btn_sync2 <= btn_sync1;
                end
            end

            // 디바운싱 로직
            always @(posedge i_clk or posedge i_reset) begin
                if (i_reset) begin
                    debounce_counter <= 0;
                    r_debounced_btn <= 1'b0;
                end else if (btn_sync2 != r_debounced_btn) begin
                    if (debounce_counter == DEBOUNCE_TIME) begin
                        r_debounced_btn <= btn_sync2;
                        debounce_counter <= 0;
                    end else begin
                        debounce_counter <= debounce_counter + 1;
                    end
                end else begin
                    debounce_counter <= 0;
                end
            end

            assign o_debounced_btn[i] = r_debounced_btn;

        end
    endgenerate

endmodule