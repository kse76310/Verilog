`timescale 1ns / 1ps

module clock_8Hz(clk, reset, clk_8Hz);
    input clk;   // 100MHz
    input reset;
    output reg clk_8Hz;   // 8Hz

    reg [19:0] i_count=0;

    always @(posedge clk, posedge reset) begin
        if (reset) begin // 0-->1 비동기 reset 
            clk_8Hz <= 0;
            i_count <= 0;
        end else begin
            if (i_count == (1_250_000/2)-1) begin  // 8Hz 12_500_000 /2 --> 62500 125_000
                i_count <= 0;
                clk_8Hz <= ~clk_8Hz;
            end begin
                i_count <= i_count + 1;
            end
        end
    end
endmodule
