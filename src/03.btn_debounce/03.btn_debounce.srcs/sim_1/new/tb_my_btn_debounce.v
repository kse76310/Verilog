`timescale 1ns / 1ps
// my_btn_debounce 
module tb_my_btn_debounce;
    reg  clk; 
    reg  reset; 
    reg  btn;
    wire led;

    my_btn_debounce u_my_btn_debounce(
        .i_clk(clk),
        .i_reset(reset),
        .i_btn(btn),
        .o_led(led)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 0;
        btn = 0;

        #10 reset = 1;
        #20 reset = 0; btn = 1;

        #20 btn = 0;
        #20 btn = 1;
        #20 btn = 0;
        #20 btn = 1;
        #20 btn = 0;
        #20 btn = 1;
        #20 btn = 0;
        #20 btn = 1;
    end

    // reg  clk; 
    // reg  reset; 
    // reg  btn;
    // wire led;

    // my_btn_debounce u_my_btn_debounce(
    //     .i_clk(clk), 
    //     .i_reset(reset), 
    //     .i_btn(btn),
    //     .o_led(led)
    // );

    // initial clk = 0;
    // always #5 clk = ~clk; // 10ns period = 100MHz

 
    // initial begin
      
    //     reset = 1'b0;
    //     btn   = 1'b0;
    //     #10;
    //     reset = 1'b1; 
    //     #20;
    //     reset = 1'b0; 
        
    //     #50;

    //     // 2. Chattering
        
    //     $display("--- Start Chattering Test ---");
    //     #20 btn = 1;
    //     #20 btn = 0;
    //     #20 btn = 1;
    //     #20 btn = 0;
    //     #20 btn = 1; 
    
    //     $display("--- Start Stable Press Test (Expecting led to be 1) ---");
    //     #15_000_000; 

    //     $display("--- Start Stable Release Test (Expecting led to be 0) ---");
    //     btn = 0;
    //     #15_000_000;

    //     $display("--- Test Finished ---");
    //     $stop;
    // end

endmodule