`timescale 1ns / 1ps

module fsm_micro(
    input clk, reset,
    input btnL,btnC,btnR,btnU,btnD,
    input timer_done, timer_is_zero, done_timer_finished,
    output reg timer_en,
    output reg timer_clear,
    output reg done_timer_en,
    output reg add_1m,
    output reg add_10s,
    output reg load_30s,
    output reg led_cooking_n,
    output reg led_done_n

    );

    parameter   IDLE  = 2'b00,
                COOKING  = 2'b01,
                PAUSE = 2'b10,
                DONE  = 2'b11;

    reg [1:0] current_state = IDLE;
    reg [1:0] next_state    = IDLE;
    
    always @(*) begin
        next_state = current_state;

        case (current_state)
            IDLE : begin
                if(btnC && !timer_is_zero)begin
                    next_state = COOKING;
                end else if(btnL) begin
                    next_state = COOKING;
                end
            end 

            COOKING : begin
                if(timer_done)begin
                    next_state = DONE;
                end else if(btnC) begin
                    next_state = PAUSE;
                end else if(btnR) begin
                    next_state = IDLE;
                end
            end

            PAUSE : begin
                if(btnC)begin
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
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    //state_Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    //Output Logic
    always @(*) begin
        // 모든 출력을 기본값으로 초기화 (Latch 방지)
        timer_en = 1'b0;
        timer_clear = 1'b0;
        done_timer_en = 1'b0;
        add_1m = 1'b0;
        add_10s = 1'b0;
        load_30s = 1'b0;
        led_cooking_n = 1'b1; // Active-low 이므로 1이 꺼짐
        led_done_n = 1'b1;

        case (current_state)
            IDLE: begin
                // IDLE 상태에서는 btnU, btnD, btnR 등의 입력에 따라
                // add_1m, add_10s, timer_clear, load_30s 신호를 만들어야 함
                if (btnU) add_1m = 1'b1;
                if (btnD) add_10s = 1'b1;
                if (btnR) timer_clear = 1'b1;
                if (btnL) load_30s = 1'b1;
            end
            COOKING: begin
                timer_en = 1'b1;
                led_cooking_n = 1'b0;
            end
            PAUSE: begin
                // 모든 출력이 0 (기본값) 이므로 특별히 할 것 없음
            end
            DONE: begin
                done_timer_en = 1'b1;
                led_done_n = 1'b0;
            end
        endcase
    end
    
endmodule
