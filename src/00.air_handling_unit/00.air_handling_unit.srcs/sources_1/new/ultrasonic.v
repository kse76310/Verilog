`timescale 1ns / 1ps


module ultrasonic(
    input clk,reset,
    input start,
    input echo,
    output reg trig,
    output reg [15:0] distance_cm,
    output reg measure_done
    );

    parameter S_IDLE        = 3'b000;
    parameter S_TRIG        = 3'b001;
    parameter S_ECHO_WAIT   = 3'b010;
    parameter S_MEASURE     = 3'b011;
    parameter S_CALC        = 3'b100;


    reg [2:0] state;
    reg [23:0] counter;

    // 타임아웃 설정: 38ms (HC-SR04 최대 측정 시간)
    // 100MHz 클럭 기준: 100,000,000 * 0.038 = 3,800,000
    localparam TIMEOUT_CYCLES = 3_800_000;

    always @(posedge clk or posedge reset) begin
        if(reset)begin
            state           <= S_IDLE;
            trig            <= 0;
            distance_cm     <= 0;
            measure_done    <= 0;
            counter         <= 0;

        end else begin
            case (state)
                S_IDLE:begin
                    trig         <= 1'b0;
                    measure_done <= 1'b0;
                    counter      <= 0;
                    if(start == 1'b1)begin
                        state <= S_TRIG;
                    end
                end 
                S_TRIG:begin
                    trig    <= 1'b1;
                    // 10us 동안 trig 신호 유지
                    if(counter >= 1000) begin 
                        state <= S_ECHO_WAIT;
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                S_ECHO_WAIT:begin
                    trig    <= 1'b0;
                    counter <= counter + 1;
                    // echo 신호가 들어오면 측정 시작
                    if(echo == 1'b1)begin
                        state <= S_MEASURE;
                        counter <= 0;
                    // 타임아웃: echo 신호가 너무 오래 안들어오면 IDLE로 복귀
                    end else if (counter >= TIMEOUT_CYCLES) begin
                        state <= S_IDLE;
                    end
                end
                S_MEASURE: begin
                    counter <= counter + 1;
                    // echo 신호가 끝나면 거리 계산
                    if(echo == 1'b0)begin
                        state <= S_CALC;
                    // 타임아웃: echo 신호가 너무 오래 지속되면(오류) IDLE로 복귀
                    end else if (counter >= TIMEOUT_CYCLES) begin
                        state <= S_IDLE;
                    end
                end
                S_CALC:begin
                    // 정확도를 높인 거리 계산 공식 적용
                    distance_cm <= (counter * 180) >> 20;
                    measure_done <= 1'b1;
                    state <= S_IDLE;
                end
                default: state <= S_IDLE; 
            endcase
         end 
      end
endmodule
