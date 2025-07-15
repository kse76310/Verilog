`timescale 1ns / 1ps

module top(
    input clk,
    input reset,  // btnU
    input [2:0] btn,
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0] w_btn_debounce;
    wire [13:0] w_seg_data;
    wire w_tick;
    reg  r_led_toggle = 1'b0;
    reg  [$clog2(500)-1:0] r_ms_count=0;
    reg  [$clog2(100)-1:0] r_100ms_count=0;
    reg  r_led_500mstoggle = 1'b0;
    reg  r_led_100mstoggle = 1'b0;


    button_debounce u_button_debounce(
        .i_clk(clk),
        .i_reset(reset),
        .i_btn(btn[0]),
        .o_led(w_btn_debounce)
    );

    tick_generator u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    btn_command_controller u_btn_command_controller (
        .clk(clk),
        .reset(reset),  // btnU
        .btn(w_btn_debounce), // btn[0]: L btn[1]:C btn[2]:R
        .sw(sw),
        .seg_data(w_seg_data),
        .led(led)
    );

    fnd_controller u_fnd_controller (
        .clk(clk),
        .reset(reset),
        .input_data(w_seg_data),
        .seg_data(seg),
        .an(an)    
    );

    always @(posedge w_btn_debounce) begin
        r_led_toggle <= ~r_led_toggle;
    end

    always @(posedge w_tick, posedge reset) begin
        if (reset) begin
            r_ms_count <= 0; 
            r_100ms_count <= 0;
            r_led_500mstoggle <= 0;
            r_led_100mstoggle <= 0;
        end else begin
            if (r_ms_count == 500-1) begin  // 500ms
                r_ms_count <= 0;
                r_led_500mstoggle = ~r_led_500mstoggle;
            end else begin
                r_ms_count <= r_ms_count + 1;
            end 
            if (r_100ms_count == 100-1) begin  // 100ms
                r_100ms_count <= 0;
                r_led_100mstoggle = ~r_led_100mstoggle;
            end else begin
                r_100ms_count <= r_100ms_count + 1;
            end 
        end
        r_led_toggle <= ~r_led_toggle;
    end

    assign led[1] = r_led_100mstoggle;
    assign led[0] = r_led_500mstoggle;
    assign led[0] = (r_led_toggle == 1) ? 1'b1 : 1'b0;
endmodule
