`timescale 1ns / 1ps

module shift_register (clk, reset, btnU, btnD, dout, sr7);
    input   clk, reset;
    input  btnU, btnD;
    output reg   dout;
    output reg [6:0]  sr7;

    reg prevU, prevD;
    wire riseU =  btnU & ~prevU;
    wire riseD =  btnD & ~prevD;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      sr7   <= 7'b0;
      dout  <= 1'b0;
      prevU <= 1'b0;
      prevD <= 1'b0;
    end else begin
      // clk마다 업데이트트
      prevU <= btnU;
      prevD <= btnD;

      //  btn edge에만 shift
      if (riseU) begin
        sr7  <= {sr7[5:0], 1'b1};
        dout <= ({sr7[5:0],1'b1} == 7'b1010111);
      end
      else if (riseD) begin
        sr7  <= {sr7[5:0], 1'b0};
        dout <= ({sr7[5:0],1'b0} == 7'b1010111);
      end
      // else: 유지
    end
  end

endmodule
