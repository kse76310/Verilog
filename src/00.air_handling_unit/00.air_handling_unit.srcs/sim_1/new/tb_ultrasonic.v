`timescale 1ns / 1ps


module tb_ultrasonic();
    reg clk;
    reg reset;
    reg start;
    reg echo;

    wire trig;
    wire [15:0] distance_cm;
    wire measure_done;

    ultrasonic uut(
        .clk(clk),
        .reset(reset),
        .start(start),
        .echo(echo),
        .trig(trig),
        .distance_cm(distance_cm),
        .measure_done(measure_done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset   = 1;
        start   = 0;
        echo    = 0;
        #20;
        reset = 0;
        #100;

        start = 1;
        #10
        start = 0;

        wait(trig == 1);
        wait(trig == 0);

        #100;
        echo = 1;
        #(580 * 1000);
        echo = 0;

        wait(measure_done == 1);
        #200;
        $finish;
    end

endmodule
