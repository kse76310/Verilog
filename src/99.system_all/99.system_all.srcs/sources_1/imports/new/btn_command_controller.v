`timescale 1ns / 1ps

module btn_command_controller(
    input clk,
    input reset,  //          
    input [2:0] btn, // L C R 
    input [7:0] sw,
    input [4:0] hour_count,
    input [5:0] min_count,
    input [12:0] sec_count,
    input [13:0] stopwatch_count,    
    output reg [3:0] o_bcd_d1000,
    output reg [3:0] o_bcd_d100,
    output reg [3:0] o_bcd_d10,
    output reg [3:0] o_bcd_d1,
    output reg [15:0] led, 
    output reg clear,
    output reg run_stop,
    output reg anim_mode
    );

    //mode
    parameter IDLE = 3'b000;
    parameter MINSEC = 3'b001;
    parameter STOPWATCH = 3'b010;

    reg prev_btnL = 0;
    reg prev_btnC = 0;
    reg prev_btnR = 0;
    reg r_run_stop;
    reg [2:0] r_mode = IDLE;
    reg [5:0] stop_idle_sec = 0;
    reg [26:0] tick_counter = 0;

    wire tick_1s = (tick_counter == 100_000_000-1);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick_counter <= 0;
        end else if (tick_counter == 100_000_000-1)
            tick_counter <= 0;
        else
            tick_counter <= tick_counter + 1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stop_idle_sec <= 0;
        end else if (r_mode != STOPWATCH || run_stop) begin
            stop_idle_sec <= 0;
        end else if (tick_1s) begin
            stop_idle_sec <= stop_idle_sec + 1;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            r_run_stop <= 0;
        else
            r_run_stop <= run_stop;  
    end

    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            r_mode <= IDLE;
            prev_btnL <= 0;
        end else begin
            if(btn[0] && !prev_btnL)
                r_mode <= (r_mode == STOPWATCH) ? IDLE : r_mode + 1;
            else if (r_mode == STOPWATCH && !run_stop && stop_idle_sec >= 30)
                r_mode <= IDLE;
            prev_btnL <= btn[0];  
        end
    end

    always @ (posedge clk, posedge reset) begin
        if(reset)
            anim_mode <= 1;
        else begin
            if(r_mode == IDLE)
                anim_mode <= 1;
            else
                anim_mode <= 0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            run_stop <= 0;
            prev_btnC <= 0;
        end else begin
            if (btn[1] && !prev_btnC)
                run_stop <= ~run_stop;

            prev_btnC <= btn[1];
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clear     <= 0;
            prev_btnR <= 0;
        end else begin
            if (btn[2] && !prev_btnR)
                clear <= 1;
            else
                clear <= 0;

            prev_btnR <= btn[2];
        end
    end

    always @(*) begin
        case (r_mode)
            MINSEC:
            begin
                o_bcd_d1000 = min_count / 10;
                o_bcd_d100  = min_count % 10;
                o_bcd_d10   = sec_count / 10;
                o_bcd_d1    = sec_count % 10;
            end
            STOPWATCH:
            begin
                o_bcd_d1000 = (stopwatch_count / 1000) % 10;
                o_bcd_d100  = (stopwatch_count / 100) % 10;
                o_bcd_d10   = (stopwatch_count / 10) % 10;
                o_bcd_d1    = stopwatch_count % 10;
            end
            default: // IDLE or other states
            begin
                o_bcd_d1000 = 0;
                o_bcd_d100  = 0;
                o_bcd_d10   = 0;
                o_bcd_d1    = 0;
            end
        endcase
    end

    //led
    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            led[15:13] <= 3'b100;
        end else begin   
        case(r_mode)
            IDLE: led[15:13] <= 3'b100;
            MINSEC: led[15:13] <= 3'b010;
            STOPWATCH: led[15:13] <= 3'b001;
            default : led[15:13] <= 3'b000;
        endcase     
        end 
    end
endmodule
