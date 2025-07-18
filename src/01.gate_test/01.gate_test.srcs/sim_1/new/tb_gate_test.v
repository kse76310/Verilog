`timescale 1ns / 1ps

module tb_gate_test();
    
    reg i_a;
    reg i_b;
    wire [5:0] o_led;

//named port mapping 방식
 gate_test u_gate_test( // u_gate_test 라는 이름으로 인스턴스 생성
    .a(i_a),
    .b(i_b),
    .led(o_led)
    );

    initial begin
        i_a=1'b0; i_b=1'b0;
        #20 i_a=1'b0; i_b=1'b1;
        #20 i_a=1'b1; i_b=1'b0;
        #20 i_a=1'b1; i_b=1'b1; 
        #20 $stop;
    end

endmodule
