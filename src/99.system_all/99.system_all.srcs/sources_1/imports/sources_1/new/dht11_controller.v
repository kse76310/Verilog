`timescale 1ns / 1ps

module dht11_controller(
    input clk,
    input reset,
    input start_trigger,
    inout dht11,
    output reg [39:0] out_dht11_data
);
    parameter 
        IDLE = 3'b000,
        START_1 = 3'b001,
        START_2 = 3'b010,
        START_3 = 3'b011,
        START_4 = 3'b100,
        DATA_1 = 3'b101,
        DATA_2 = 3'b110;
        
    reg [23:0] clk_cnt = 0;

    reg [2:0] state;

    reg [39:0] dht11_data;
    reg [39:0] prev_dht11_data = 0;
    reg [5:0] dht11_data_idx;

    reg dht11_done;
    reg dht11_out;
    reg dht11_inout_mode;       // 1 -> out, 0 -> in

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            dht11_inout_mode <= 1;
            dht11_out <= 1;
            dht11_done <= 0;
            dht11_data <= 0;
            prev_dht11_data <= 0;
            dht11_data_idx <= 0;
        end else begin
            case(state)
                IDLE: begin
                    dht11_inout_mode <= 1;
                    dht11_out <= 1;
                    clk_cnt <= 0;
                    if (dht11_done) begin
                        if (dht11_data[39:32] + dht11_data[31:24] + dht11_data[23:16] + dht11_data[15:8] == dht11_data[7:0]) begin
                            out_dht11_data <= dht11_data;
                        end else out_dht11_data <= 40'b01100011_01100011_01100011_01100011_01100011; 
                    end else out_dht11_data <= 40'h5858585858;
                    if (start_trigger) begin
                        dht11_done <= 0;
                        state <= START_1;
                    end
                end
                START_1: begin
                    dht11_out <= 0;
                    if (clk_cnt == 1_800_000-1) begin
                        clk_cnt <= 0;
                        state <= START_2;
                    end else clk_cnt <= clk_cnt + 1;
                end
                START_2: begin
                    dht11_out <= 1;
                    if (clk_cnt == 4_000-1) begin
                        clk_cnt <= 0;
                        state <= START_3;
                        dht11_inout_mode <= 0; 
                    end else clk_cnt <= clk_cnt + 1;
                end
                START_3 : begin
                    if (dht11 == 1) begin
                        clk_cnt <= 0;
                        state <= START_4;
                    end else if (clk_cnt > 12_000) state <= IDLE;
                    else clk_cnt <= clk_cnt + 1;
                end
                START_4 : begin
                    if (dht11 == 0) begin
                        clk_cnt <= 0;
                        // dht11_done <= 0;
                        state <= DATA_1;
                    end else if (clk_cnt > 12_000) state <= IDLE;
                    else clk_cnt <= clk_cnt + 1;
                end
                DATA_1: begin
                    if (dht11 == 1) begin
                        state <= DATA_2;
                        clk_cnt <= 0;
                    end else if (clk_cnt > 15_000) state <= IDLE;
                    else clk_cnt <= clk_cnt + 1;
                end
                DATA_2: begin
                    if (dht11 == 0) begin
                        if (clk_cnt < 5_000) dht11_data[39 - dht11_data_idx] <= 0;
                        else dht11_data[39 - dht11_data_idx] <= 1;
                        if(dht11_data_idx == 39) begin
                            clk_cnt <= 0;
                            dht11_data_idx <= 0;
                            dht11_done <= 1;
                            state <= IDLE;
                        end else begin
                            clk_cnt <= 0;
                            dht11_data_idx <= dht11_data_idx + 1;
                            state <= DATA_1;
                        end
                    end else if (clk_cnt > 20_000) state <= IDLE;
                    else clk_cnt <= clk_cnt + 1;
                end
            endcase
        end
    end

    assign dht11 = dht11_inout_mode ? dht11_out : 1'bz;
endmodule