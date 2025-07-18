`timescale 1ns / 1ps

module top(
    input clk, reset,
    input btnR, btnL,
    output btn_clean,
    output buzzer
);

    // Debounced button wires
    wire w_btnL, w_btnR;

    button_debounce u_btnL_debounce(.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));
    button_debounce u_btnR_debounce(.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));

    // Edge detectors for buttons
    reg w_btnL_d1, w_btnR_d1;
    wire w_btnL_posedge, w_btnR_posedge;

    always @(posedge clk) begin
        w_btnL_d1 <= w_btnL;
        w_btnR_d1 <= w_btnR;
    end
    assign w_btnL_posedge = w_btnL & ~w_btnL_d1;
    assign w_btnR_posedge = w_btnR & ~w_btnR_d1;

    // -- Common parameters --
    localparam DURATION_70MS = 29'd7_000_000;   // 70ms @ 100MHz
    localparam DURATION_3S   = 29'd300_000_000; // 3s @ 100MHz

    //================================================================
    // Power On Buzzer (btnL)
    //================================================================
    localparam S_L_IDLE     = 3'd0;
    localparam S_L_1KHZ     = 3'd1;
    localparam S_L_2KHZ     = 3'd2;
    localparam S_L_3KHZ     = 3'd3;
    localparam S_L_4KHZ     = 3'd4;
    localparam S_L_SILENCE  = 3'd5;

    reg [2:0] r_l_state = S_L_IDLE;
    reg [28:0] r_l_duration_cnt = 29'd0;
    reg [15:0] r_l_freq_cnt = 16'd0;
    reg [15:0] r_l_freq_limit = 16'd0;
    reg r_l_buzzer_out = 1'b0;

    localparam FREQ_1KHZ_CNT = 16'd50_000;
    localparam FREQ_2KHZ_CNT = 16'd25_000;
    localparam FREQ_3KHZ_CNT = 16'd16_667;
    localparam FREQ_4KHZ_CNT = 16'd12_500;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_l_state <= S_L_IDLE;
            r_l_duration_cnt <= 0;
            r_l_freq_cnt <= 0;
            r_l_buzzer_out <= 1'b0;
            r_l_freq_limit <= 0;
        end else begin
            if (w_btnL_posedge) begin
                if (r_l_state == S_L_IDLE) begin // If idle, start sequence
                    r_l_state <= S_L_1KHZ;
                    r_l_duration_cnt <= 0;
                    r_l_freq_cnt <= 0;
                    r_l_freq_limit <= FREQ_1KHZ_CNT;
                end else begin // If running, stop and go to idle
                    r_l_state <= S_L_IDLE;
                    r_l_duration_cnt <= 0;
                    r_l_freq_cnt <= 0;
                    r_l_buzzer_out <= 1'b0;
                end
            end else begin
                case (r_l_state)
                    S_L_IDLE: begin
                        r_l_buzzer_out <= 1'b0;
                    end

                    S_L_1KHZ, S_L_2KHZ, S_L_3KHZ, S_L_4KHZ: begin
                        if (r_l_freq_cnt >= r_l_freq_limit - 1) begin
                            r_l_freq_cnt <= 0;
                            r_l_buzzer_out <= ~r_l_buzzer_out;
                        end else begin
                            r_l_freq_cnt <= r_l_freq_cnt + 1;
                        end

                        if (r_l_duration_cnt >= DURATION_70MS - 1) begin
                            r_l_duration_cnt <= 0;
                            r_l_freq_cnt <= 0;
                            case (r_l_state)
                                S_L_1KHZ: begin r_l_state <= S_L_2KHZ; r_l_freq_limit <= FREQ_2KHZ_CNT; end
                                S_L_2KHZ: begin r_l_state <= S_L_3KHZ; r_l_freq_limit <= FREQ_3KHZ_CNT; end
                                S_L_3KHZ: begin r_l_state <= S_L_4KHZ; r_l_freq_limit <= FREQ_4KHZ_CNT; end
                                S_L_4KHZ: begin r_l_state <= S_L_SILENCE; r_l_buzzer_out <= 1'b0; end
                            endcase
                        end else begin
                            r_l_duration_cnt <= r_l_duration_cnt + 1;
                        end
                    end

                    S_L_SILENCE: begin
                        r_l_buzzer_out <= 1'b0;
                        if (r_l_duration_cnt >= DURATION_3S - 1) begin
                            r_l_state <= S_L_IDLE;
                        end else begin
                            r_l_duration_cnt <= r_l_duration_cnt + 1;
                        end
                    end
                    default: r_l_state <= S_L_IDLE;
                endcase
            end
        end
    end

    //================================================================
    // Open Buzzer (btnR)
    //================================================================
    localparam S_R_IDLE     = 3'd0;
    localparam S_R_261HZ    = 3'd1;
    localparam S_R_329HZ    = 3'd2;
    localparam S_R_392HZ    = 3'd3;
    localparam S_R_554HZ    = 3'd4;
    localparam S_R_SILENCE  = 3'd5;

    reg [2:0] r_r_state = S_R_IDLE;
    reg [28:0] r_r_duration_cnt = 29'd0;
    reg [17:0] r_r_freq_cnt = 18'd0;
    reg [17:0] r_r_freq_limit = 18'd0;
    reg r_r_buzzer_out = 1'b0;

    // Frequencies for 100MHz clock (100M / (freq * 2))
    localparam FREQ_261HZ_CNT = 18'd191571;
    localparam FREQ_329HZ_CNT = 18'd151976;
    localparam FREQ_392HZ_CNT = 18'd127551;
    localparam FREQ_554HZ_CNT = 18'd90253;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_r_state <= S_R_IDLE;
            r_r_duration_cnt <= 0;
            r_r_freq_cnt <= 0;
            r_r_buzzer_out <= 1'b0;
            r_r_freq_limit <= 0;
        end else begin
            if (w_btnR_posedge) begin
                if (r_r_state == S_R_IDLE) begin // If idle, start sequence
                    r_r_state <= S_R_261HZ;
                    r_r_duration_cnt <= 0;
                    r_r_freq_cnt <= 0;
                    r_r_freq_limit <= FREQ_261HZ_CNT;
                end else begin // If running, stop and go to idle
                    r_r_state <= S_R_IDLE;
                    r_r_duration_cnt <= 0;
                    r_r_freq_cnt <= 0;
                    r_r_buzzer_out <= 1'b0;
                end
            end else begin
                case (r_r_state)
                    S_R_IDLE: begin
                        r_r_buzzer_out <= 1'b0;
                    end

                    S_R_261HZ, S_R_329HZ, S_R_392HZ, S_R_554HZ: begin
                        if (r_r_freq_cnt >= r_r_freq_limit - 1) begin
                            r_r_freq_cnt <= 0;
                            r_r_buzzer_out <= ~r_r_buzzer_out;
                        end else begin
                            r_r_freq_cnt <= r_r_freq_cnt + 1;
                        end

                        if (r_r_duration_cnt >= DURATION_70MS - 1) begin
                            r_r_duration_cnt <= 0;
                            r_r_freq_cnt <= 0;
                            case (r_r_state)
                                S_R_261HZ: begin r_r_state <= S_R_329HZ; r_r_freq_limit <= FREQ_329HZ_CNT; end
                                S_R_329HZ: begin r_r_state <= S_R_392HZ; r_r_freq_limit <= FREQ_392HZ_CNT; end
                                S_R_392HZ: begin r_r_state <= S_R_554HZ; r_r_freq_limit <= FREQ_554HZ_CNT; end
                                S_R_554HZ: begin r_r_state <= S_R_SILENCE; r_r_buzzer_out <= 1'b0; end
                            endcase
                        end else begin
                            r_r_duration_cnt <= r_r_duration_cnt + 1;
                        end
                    end

                    S_R_SILENCE: begin
                        r_r_buzzer_out <= 1'b0;
                        if (r_r_duration_cnt >= DURATION_3S - 1) begin
                            r_r_state <= S_R_IDLE;
                        end else begin
                            r_r_duration_cnt <= r_r_duration_cnt + 1;
                        end
                    end
                    default: r_r_state <= S_R_IDLE;
                endcase
            end
        end
    end

    // -- Final Output Assignments --
    assign btn_clean = w_btnL | w_btnR;
    assign buzzer = r_l_buzzer_out | r_r_buzzer_out;

endmodule
