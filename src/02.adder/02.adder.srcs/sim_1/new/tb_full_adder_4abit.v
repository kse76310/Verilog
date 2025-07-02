`timescale 1ns / 1ps


module tb_full_adder_4abit();
    reg [3:0] r_a; // 시물레이션에서 입력은 reg
    reg [3:0] r_b;
    reg r_cin; // 1bit
    wire [3:0] w_sum; // 시물레이션에서 출력은 wire로 선언
    wire w_carry_out;

    full_adder_4bit dut (
    .a(r_a),
    .b(r_b),
    .cin(r_cin), // 1bit
    .sum(w_sum),
    .carry_out(w_carry_out)
    );

    initial begin
        #00 r_a = 4'd0; r_b=4'd0; r_cin = 1'b0;
        #10 r_a = 4'd5; r_b=4'd3; r_cin = 1'b1;
        #10 r_a = 4'd9; r_b=4'd8; r_cin = 1'b0;
        #10 $finish;
    end

endmodule
