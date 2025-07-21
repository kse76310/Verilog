`timescale 1ns / 1ps

module tb_top;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] sw;
    reg btnC, btnU, btnD, btnL;
    reg echo_pin;
    wire dht11_data_pin; // Changed from reg to wire
    reg tb_dht11_data_out; // Testbench output value for dht11_data_pin
    reg tb_dht11_data_oe;  // Testbench output enable for dht11_data_pin

    // Outputs
    wire trig_pin;
    wire fan_pwm_out;
    wire fan_in1;
    wire fan_in2;
    wire buzzer_out;
    wire RsTx;
    wire [7:0] seg;
    wire [3:0] an;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .echo_pin(echo_pin),
        .trig_pin(trig_pin),
        .fan_pwm_out(fan_pwm_out),
        .fan_in1(fan_in1),
        .fan_in2(fan_in2),
        .buzzer_out(buzzer_out),
        .dht11_data_pin(dht11_data_pin),
        .RsTx(RsTx),
        .seg(seg),
        .an(an)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock (10ns period)
    end

    // Assign dht11_data_pin based on testbench control
    assign dht11_data_pin = tb_dht11_data_oe ? tb_dht11_data_out : 1'bz;

    // Initial stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        btnC = 0;
        btnU = 0;
        btnD = 0;
        btnL = 0;
        echo_pin = 0;
        tb_dht11_data_out = 1; // Default high
        tb_dht11_data_oe = 0;  // Initially let UUT control

        // Apply reset
        #100;
        reset = 0;

        // Test sequence
        #100; // Wait for system to stabilize

     
        btnC = 1;
        #20;
        btnC = 0;
        #100;
        echo_pin = 1;
        #50; // Simulate a short echo pulse
        echo_pin = 0;
        #100;

        #1000; // Run for a longer duration
        $finish; // End simulation
    end

endmodule