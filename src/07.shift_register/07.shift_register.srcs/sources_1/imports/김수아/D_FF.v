`timescale 1ns / 1ps

module D_FF(clk, reset, d, q);
    input clk, reset;
    input [1:0] d;
    output reg [1:0] q;

    always @(posedge clk, posedge reset) begin  // 8Hz
        if (reset) begin
            q <= 0;
        end 
        else begin
            q <= d;
        end
    end

endmodule
