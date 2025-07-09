`timescale 1ns / 1ps

module fsm_2(
    input clk, rst_n, go, ws,
    output reg rd, ds
    );

    parameter IDLE = 2'b00;
    parameter READ = 2'b01;
    parameter DLY  = 2'b10;
    parameter DONE = 2'b11;
    reg[1:0] state, next_state;

    // always @(go or ws or state)begin
    //     case (state)
    //         IDLE: next_state = go ? READ : IDLE; 
    //         READ: next_state = DLY;
    //         DLY: next_state = ws ? READ : DONE;
    //         DONE : next_state = IDLE;
    //         default: next_state = IDLE;
    //     endcase
    // end
    // assign rd = (state == READ) || (state == DLY);
    // assign ds = (state == DONE);

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always@(*)begin
        next_state = state;
        case(state)
        IDLE:begin
            if(go)begin
                next_state = READ;
            end
        end
        READ:begin
            if(ws)begin
                next_state = DLY;
            end else if(!go) begin
                next_state = IDLE;
            end
        end
        DLY:begin
            if(!ws)begin
                next_state = DONE;
            end
        end
        DONE:begin
            next_state = IDLE;
        end
        endcase
    end

    always@(state) begin
        rd = 1'b0;
        ds = 1'b0;

        case (state)
            READ: rd = 1'b1;
            DLY : rd = 1'b1;
            DONE: ds = 1'b1; 
        endcase
    end
endmodule
