`timescale 1ns / 1ps


module top(
    input clk, 
    input reset, 
    input [2:0]btn,
    input [7:0]sw,
    input [13:0] input_data,
    output [6:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire w_btn_debounce;
    wire w_tick;
    reg r_led_toggle = 1'b0;
    reg r_led_100mstoggle = 1'b0;
    reg r_led_500mstoggle = 1'b0;
    reg [$clog2(500)-1:0] r_ms_count=0;
    reg [$clog2(100)-1:0] r_100ms_count=0;
    reg r_btn_prev = 0;
    reg [3:0] stable_count = 0;

    wire w_clean_btn;

    
    button_debounce u_button_debounce(
        .i_clk(clk), 
        .i_reset(reset), 
        .i_btn(btnC),
        .o_led(w_btn_debounce)
    );

    // my_btn_debounce u_my_btn_debounce(
    //     .i_clk(clk), 
    //     .i_reset(reset), 
    //     .i_btn(btnC),
    //     .o_led(w_btn_debounce)
    // );

    tick_generator u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );


    fnd_controllor u_fnd_controllor(
        .clk(clk),
        .reset(reset),
        .input_data(15'd9999),
        .seg_data(seg),
        .an(an)    // 자릿수 선택
    );

    always @(posedge w_tick, posedge reset) begin
        if(reset)begin
            r_led_toggle    <= 1'b0;
            r_btn_prev      <= 1'b0;
        end else begin
            r_btn_prev <= w_btn_debounce;

            if (w_btn_debounce ==1'b1 && r_btn_prev ==1'b0) begin
                r_led_toggle <= ~r_led_toggle;
            end
        end
    end

    assign led[0] =r_led_toggle;   

    always @(posedge w_tick, posedge reset) begin
        if (reset) begin
            r_ms_count <= 0;
            r_100ms_count <= 0;
            r_led_100mstoggle <= 0;
            r_led_500mstoggle <= 0;
        end else begin
            if(r_ms_count == 500-1) begin
                r_ms_count <= 0;
                r_led_500mstoggle = ~r_led_500mstoggle;
            end else begin
                r_ms_count <= r_ms_count +1;
            end
            if(r_ms_count == 100-1) begin
                r_100ms_count <= 0;
                r_led_100mstoggle = ~r_led_100mstoggle;
            end else begin
                r_100ms_count <= r_100ms_count +1;
            end
        
        end
        r_led_toggle <= ~r_led_toggle;
    end

    assign led[1] = r_led_100mstoggle;
    assign led[0] = r_led_500mstoggle;
    assign led[0] = (r_led_toggle == 1) ? 1'b1 : 1'b0;

endmodule
