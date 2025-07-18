`timescale 1ns / 1ps

module fsm_micro(
    input clk, reset,
    input btnL,btnC,btnR,btnU,btnD,
    input timer_done, timer_is_zero, done_timer_finished,
    input door_is_open,
    output reg timer_en,
    output reg timer_clear,
    output reg done_timer_en,
    output reg add_1m,
    output reg add_10s,
    output reg load_30s,
    output reg led_cooking_n,
    output reg led_done_n,
    output reg [1:0]servo_pos_select,
    output reg fan_on,
    output reg beep_trigger,
    output reg alarm_trigger

    );

    parameter   IDLE    = 2'b00,
                COOKING = 2'b01,
                PAUSE   = 2'b10,
                DONE    = 2'b11;

    reg [1:0] current_state = IDLE;
    reg [1:0] next_state    = IDLE;
    reg done_alarm_triggered;

    always @(*) begin
        next_state = current_state;

        case (current_state)
            IDLE : begin
                if((btnC && !timer_is_zero && !door_is_open) || (btnL && !door_is_open))begin
                    next_state = COOKING;
                end
            end 

            COOKING : begin
                if(door_is_open)begin
                    next_state = PAUSE;
                end else if(timer_done)begin
                    next_state = DONE;
                end else if(btnC) begin
                    next_state = PAUSE;
                end else if(btnR) begin
                    next_state = IDLE;
                end
            end

            PAUSE : begin
                if(btnC && !door_is_open)begin
                    next_state = COOKING;
                end else if(btnR)begin
                    next_state = IDLE;
                end
            end

            DONE : begin
                if(done_timer_finished)begin
                    next_state = IDLE;
                end
            end
            // default: begin
            //     next_state = IDLE;
            // end
        endcase
    end
    //state_Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            done_alarm_triggered <= 1'b0;
        end else begin
            current_state <= next_state;

            if(next_state == DONE && current_state != DONE)begin
                done_alarm_triggered <= 1'b1;
            end else begin
                done_alarm_triggered <= 1'b0;
            end
        end
    end

    //Output Logic
    always @(*) begin
        // 모든 출력을 기본값으로 초기화 (Latch 방지)
        timer_en         = 1'b0;
        timer_clear      = 1'b0;
        done_timer_en    = 1'b0;
        add_1m           = 1'b0;
        add_10s          = 1'b0;
        load_30s         = 1'b0;
        led_cooking_n    = 1'b0; // Active-low 이므로 1이 꺼짐
        led_done_n       = 1'b1;
        fan_on           = 1'b0;
        servo_pos_select = 2'b00;
        beep_trigger     = 1'b0;
        alarm_trigger    = 1'b0;
        
        case (current_state)
            IDLE: begin
                // IDLE 상태에서는 btnU, btnD, btnR 등의 입력에 따라
                // add_1m, add_10s, timer_clear, load_30s 신호를 만들어야 함
                if (btnU) add_1m = 1'b1;
                if (btnD) add_10s = 1'b1;
                if (btnL) load_30s = 1'b1;
                if (btnR) timer_clear = 1'b1;

                if(door_is_open)begin
                    servo_pos_select = 2'b10;
                end else begin
                    servo_pos_select = 2'b01;
                end
                if (btnL || btnC || btnR || btnU || btnD) begin
                    beep_trigger = 1'b1;
                end
            end
            COOKING: begin
                timer_en        = 1'b1;
                led_cooking_n   = 1'b0;
                fan_on          = 1'b1;
            end
            PAUSE: begin
                // 모든 출력이 0 (기본값) 이므로 특별히 할 것 없음
            end
            DONE: begin
                done_timer_en = 1'b1;
                led_done_n = 1'b0;
                if(!done_alarm_triggered)begin
                    alarm_trigger = 1'b1;
                end
            end
        endcase
    end
    
endmodule
