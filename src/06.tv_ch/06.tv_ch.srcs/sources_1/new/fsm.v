`timescale 1ns / 1ps

module fsm(
    input clk,rstn,done,
    output reg ack
    );

    reg [1:0] state, next_state;

    parameter ready = 2'b00, trans = 2'b01, write = 2'b10, read = 2'b11;

    always@(*) begin
        next_state = state;
        ack = 1'b0;
        case(state)

            ready: begin
                if(done == 1)begin
                    next_state = trans;
                    ack = 1'b1;
                end        
            end

            trans: begin
                if(done == 1) begin
                end else begin
                    next_state = write;
                end
            end

            write: begin
                if(done == 1)begin
                    next_state = read;
                end
                   
            end

            read: begin
                if(done == 1)begin
                    next_state = ready;
                end
            end
        endcase
    end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        state <= ready;
    end else begin
        state <= next_state;
    end
end

endmodule
