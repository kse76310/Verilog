`timescale 1ns / 1ps

module tb_fsm();
    reg clk;
    reg rstn;
    reg done;
    wire ack;

    fsm dut(
        .clk(clk),
        .rstn(rstn),
        .done(done),
        .ack(ack)
    );

    initial clk = 0;
    always #5 clk=~clk;

    initial begin
        rstn = 0;
        done = 0;
        #20

        #00
        #10 rstn = 1;
        #10 done = 1;      
        #10 done = 0;
        #10 done = 1;
        #10 done = 0;
        #10 done = 1;
        #100
        $stop;
    end

endmodule
