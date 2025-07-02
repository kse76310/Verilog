`timescale 1ns / 1ps

module gate_test(
    input wire a,
    input b, // 생략하면 wire (아무런 언급 안하면 1bit)
    output [5:0]led
    
    );

    assign led[0] = a & b;
    assign led[1] = a | b;
    assign led[2] = ~(a & b); // NAND
    assign led[3] = ~(a | b);  // NOR
    assign led[4] = a ^ b;    // XOR
    assign led[5] = ~a;       // NOT
endmodule
