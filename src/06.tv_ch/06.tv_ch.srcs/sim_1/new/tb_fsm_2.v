`timescale 1ns / 1ps


module tb_fsm_2();
    reg clk;
    reg rst_n;
    reg go;
    reg ws;
    wire rd;
    wire ds;

    fsm_2 dut(
        .clk(clk),
        .rst_n(rst_n),
        .go(go),
        .ws(ws),
        .rd(rd),
        .ds(ds)
    );

    initial clk = 0;
    always #5 clk=~clk;

    initial begin
        rst_n = 0;
        go = 0;
        ws = 0;
        #20;

        #00 rst_n = 1;
        #10 go = 1;
        #10 ws = 1;
        #10 ws = 0;
        #10;
        $stop;
    end
endmodule
