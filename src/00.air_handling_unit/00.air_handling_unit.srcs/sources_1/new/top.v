`timescale 1ns / 1ps

module top(
    input clk, reset,
    input [7:0] sw,
    input echo_pin,
    output trig_pin,
    output fan_pwm_out,
    output fan_in1,
    output fan_in2,
    output buzzer_out,
    output RsTx, // UART TX output
    output [7:0] seg, // FND segment output
    output [3:0] an // FND anode output

    );

    wire [15:0] w_distance_cm;
    reg [6:0] duty;
    reg buzzer_enable;

    ultrasonic u_ultrasonic(
        .clk(clk),
        .reset(reset),
        .start(1'b1),
        .echo(echo_pin),
        .trig(trig_pin),
        .distance_cm(w_distance_cm),
        .measure_done()
    );

    pwm_controller u_pwm_controller(
        .clk(clk), 
        .reset(reset),
        .duty(duty),
        .pwm_out(fan_pwm_out)
    );

    
    buzzer_driver u_buzzer_driver(
        .clk(clk),
        .reset(reset),
        .enable(buzzer_enable),      // 소리를 켜라는 명령 (레벨 신호)
        .buzzer_out(buzzer_out)   // 실제 부저 핀으로 나갈 스퀘어 웨이브
    );

    always @(*) begin
        if(w_distance_cm < 5) begin
            duty = 0;
            buzzer_enable = 1'b1;
        end else begin
            duty = sw[6:0]; // 8비트 sw에서 하위 7비트만 duty(7비트)에 할당
            buzzer_enable = 1'b0;
        end
    end

    assign fan_in1 = 1'b1;
    assign fan_in2 = 1'b0;

    uart_controller u_uart_controller(
        .clk(clk),
        .reset(reset),
        .send_data(w_distance_cm),
        .rx(1'b0), // RX는 현재 사용하지 않으므로 0으로 고정
        .rx_data(),
        .rx_done(),
        .tx(RsTx)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .input_data(w_distance_cm),
        .seg_data(seg),
        .an(an)
    );

endmodule