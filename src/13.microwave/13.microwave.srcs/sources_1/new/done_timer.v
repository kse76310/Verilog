`timescale 1ns / 1ps

module done_timer (
    input clk,
    input reset,
    input en,       // FSM이 DONE 상태일 때 '1'이 됨
    output reg finished  // 3초가 되면 1-cycle 펄스 출력
);

    // 100MHz 클럭 기준으로 3초는 300,000,000 클럭
    parameter MAX_COUNT = 10_000_000;
    
    // 카운터 레지스터. 3억 이상을 저장할 수 있는 크기여야 함 (2^28 < 3억 < 2^29)
    reg [28:0] counter;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= 0;
            finished <= 1'b0;
        end else if(en) begin
            if(counter == MAX_COUNT-1)begin
                counter <= 0;
                finished <= 1'b1;
            end else begin
                counter <= counter + 1;
                finished <= 1'b0;
            end
        end else begin
            counter <= 0;
            finished <= 1'b0;
        end
    end

endmodule
