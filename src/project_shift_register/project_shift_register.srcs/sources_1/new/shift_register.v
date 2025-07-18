`timescale 1ns / 1ps

module top (
    input clk,             // 100MHz  
    input reset,            // Reset 버튼
    input btnU,            // '1' 입력 버튼
    input btnD,            // '0' 입력 버튼
    output [15:0] led
);
    reg prev_btnU_press=1'b0;
    reg prev_btnD_press=1'b0;
    reg [6:0] shift_reg7=7'b0000000;

    wire debounced_btnU, debounced_btnD;

    debouncer U_debouncer_btnU (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnU),
        .clean_btn(debounced_btnU)
    );

    debouncer U_debouncer_btnD (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnD),
        .clean_btn(debounced_btnD)
    );

    always @(posedge clk, posedge reset) begin
        if (reset) begin 
            prev_btnU_press <= 1'b0;
            prev_btnD_press <= 1'b0;
            shift_reg7 <= 7'b0000000;
        end else begin
            if( debounced_btnU && ~prev_btnU_press) begin 
                shift_reg7 <= {shift_reg7[5:0], 1'b1};
            end else if ( debounced_btnD && ~prev_btnD_press) begin
                 shift_reg7 <= {shift_reg7[5:0], 1'b0};
            end 
            prev_btnU_press <= debounced_btnU;
            prev_btnD_press <= debounced_btnD;
        end 
    end

    assign led[0] = (shift_reg7 == 7'b1010111) ? 1'b1 : 1'b0;
    assign led[7:1] = shift_reg7; // 내부 시프트 레지스터 상태 확인용 (선택)
    assign led[15:8] = 8'b0;

endmodule

/*
module shift_reg_nblk1(clk, rst, sin, sout); 
    input     clk, rst, sin;
    output    sout;
    reg [7:0] q;

    assign sout = q[7];

    always @(posedge clk) begin
        if(!rst)
            q <= 8'b0;
        else begin
            q[0] <= sin; 
            q[1] <= q[0]; 
            q[2] <= q[1]; 
            q[3] <= q[2]; 
            q[4] <= q[3]; 
            q[5] <= q[4]; 
            q[6] <= q[5]; 
            q[7] <= q[6];
        end
    end
endmodule
*/
