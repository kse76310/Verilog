`timescale 1ns / 1ps


module tb_full_adder();
    reg r_a, r_b, r_cin;
    wire w_sum, w_carry_out;

    full_adder u_full_adder(
    .a(r_a),
    .b(r_b),
    .cin(r_cin),
    .sum(w_sum),
    .carry_out(w_carry_out)
    );

    initial begin
        #00 r_a=1'b0;r_b=1'b0;r_cin=1'b0;        
        #20 r_a=1'b0;r_b=1'b0;r_cin=1'b1;        
        #20 r_a=1'b0;r_b=1'b1;r_cin=1'b0;        
        #20 r_a=1'b0;r_b=1'b1;r_cin=1'b1;        
        #20 r_a=1'b1;r_b=1'b0;r_cin=1'b0;        
        #20 r_a=1'b1;r_b=1'b0;r_cin=1'b1;        
        #20 r_a=1'b1;r_b=1'b1;r_cin=1'b0;        
        #20 r_a=1'b1;r_b=1'b1;r_cin=1'b1;        
        #20 $stop;

    end

endmodule
