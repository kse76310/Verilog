`timescale 1ns / 1ps

module pwm_controller(
    input clk, reset,
    input [6:0] duty,
    output reg pwm_out
    );

    reg [6:0] counter;
    always @(posedge clk or posedge reset) begin
        if(reset)begin
            counter <= 0;
            pwm_out <= 0;
        end
        else begin
            // 카운터가 127에 도달하면 0으로 리셋 (PWM 주기 = 128 클럭)
            if(counter == 127)begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end 
            
            // 카운터 값이 duty 값보다 작으면 pwm_out을 1로 설정
            if(counter < duty)begin
                pwm_out <= 1;
            end else begin
                pwm_out <= 0;
            end
        end
    end
endmodule
