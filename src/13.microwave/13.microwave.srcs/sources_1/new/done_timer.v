`timescale 1ns / 1ps

module done_timer (
    input clk,
    input reset,
    input en,       // FSM이 DONE 상태일 때 '1'이 됨
    output reg finished  // 3초가 되면 1-cycle 펄스 출력
);

    // 100MHz 클럭 기준으로 3초는 300,000,000 클럭
    parameter MAX_COUNT = 300_000_000;
    
    // 카운터 레지스터. 3억 이상을 저장할 수 있는 크기여야 함 (2^28 < 3억 < 2^29)
    reg [28:0] counter;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= 0;
            finished <= 1'b0;
        // FSM이 활성화(en) 신호를 줄 때만 카운트 시작
        end else if (en) begin
            finished <= 1'b0; // 평소에는 0으로 유지
            if (counter < MAX_COUNT - 1) begin
                counter <= counter + 1;
            // 카운트가 끝나면
            end else begin
                finished <= 1'b1; // 1 클럭 동안만 finished 신호를 1로!
                counter <= 0;     // 카운터 초기화
            end
        // 활성화 신호가 없으면 항상 0으로 초기화
        end else begin
            counter <= 0;
            finished <= 1'b0;
        end
    end

endmodule
