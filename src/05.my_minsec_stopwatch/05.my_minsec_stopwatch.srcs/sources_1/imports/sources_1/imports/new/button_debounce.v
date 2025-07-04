`timescale 1ns / 1ps

module btn_debouncer (
    input clk,          // 시스템 클럭 (타이머를 위해)
    input reset,        // 리셋 신호
    input btn_in,       // 물리 버튼에서 들어오는 불안정한 입력
    output reg btn_out  // 채터링이 제거된 안정적인 출력
);

    // 디바운싱을 위한 타이머 설정 (예: 20ms)
    localparam DEBOUNCE_TIME = 1_000_000; // 50MHz 클럭 기준 약 20ms

    reg [19:0] counter; // 20ms를 셀 카운터
    reg btn_state;      // 버튼의 현재 상태를 저장할 변수

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // 리셋 시 모든 것을 초기화
            counter <= 0;
            btn_state <= 0;
            btn_out <= 0;
        end else begin
            // 버튼 입력과 현재 상태가 다를 때 (변화 감지!)
            if (btn_in != btn_state) begin
                counter <= counter + 1; // 카운터 시작
                // 카운터가 설정한 시간에 도달하면
                if (counter >= DEBOUNCE_TIME) begin
                    btn_state <= btn_in; // 버튼 상태를 안정된 값으로 업데이트
                    btn_out <= btn_in;   // 최종적으로 안정된 신호 출력
                    counter <= 0;        // 카운터 초기화
                end
            // 버튼 입력과 현재 상태가 같다면 (안정적)
            end else begin
                counter <= 0; // 변화가 없으면 카운터는 항상 0
            end
        end
    end

endmodule