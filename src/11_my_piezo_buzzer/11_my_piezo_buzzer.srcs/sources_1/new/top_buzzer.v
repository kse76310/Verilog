`timescale 1ns / 1ps


module top_buzzer(
    input clk, reset,
    input btnU,btnC,btnR,btnD,btnL,
    output btn_clean,
    output [1:0]led,
    output buzzer
    );

    parameter M500MS = 50000000 ;

    wire w_btnU, w_btnC, w_btnR, w_btnD, w_btnL;

    reg [21:0] r_clk_cnt[4:0]; //2d array
    reg [4:0] r_buzzer_frequency;

    button_debounce u_btnU_debounce(.i_clk(clk), .i_reset(reset), .i_btn(btnU), .o_btn_clean(w_btnU));
    button_debounce u_btnC_debounce(.i_clk(clk), .i_reset(reset), .i_btn(btnC), .o_btn_clean(w_btnC));
    button_debounce u_btnR_debounce(.i_clk(clk), .i_reset(reset), .i_btn(btnR), .o_btn_clean(w_btnR));
    button_debounce u_btnD_debounce(.i_clk(clk), .i_reset(reset), .i_btn(btnD), .o_btn_clean(w_btnD));
    button_debounce u_btnL_debounce(.i_clk(clk), .i_reset(reset), .i_btn(btnL), .o_btn_clean(w_btnL));

    // 도(130.8147Hz) <= 100M를 764,444분주
    always @(posedge clk or posedge reset) begin
        if(reset)begin
            r_clk_cnt[0] <= 22'd0;
            r_buzzer_frequency[0] <= 0;
        end else begin
            if(!w_btnU) begin
                r_clk_cnt[0] <= 22'd0;
                r_buzzer_frequency[0] <= 0;
            end else begin
                if(r_clk_cnt[0] == 22'd38_222-1)begin
                    r_clk_cnt[0] <= 0;
                    r_buzzer_frequency[0] <= ~r_buzzer_frequency[0];
                end else begin
                    r_clk_cnt[0] <= r_clk_cnt[0] + 1;
                end
            end
        end
    end

    // 레(130.8147Hz) <= 100M를 764,444분주
    always @(posedge clk or posedge reset) begin
        if(reset)begin
            r_clk_cnt[1] <= 22'd0;
            r_buzzer_frequency[1] <= 0;
        end else begin
            if(!w_btnL) begin
                r_clk_cnt[1] <= 22'd0;
                r_buzzer_frequency[1] <= 0;
            end else begin
                if(r_clk_cnt[1] == 22'd34_053-1)begin
                    r_clk_cnt[1] <= 0;
                    r_buzzer_frequency[1] <= ~r_buzzer_frequency[1];
                end else begin
                    r_clk_cnt[1] <= r_clk_cnt[1] + 1;
                end
            end
        end
    end

    // 미
    always @(posedge clk or posedge reset) begin
        if(reset)begin
            r_clk_cnt[2] <= 22'd0;
            r_buzzer_frequency[2] <= 0;
        end else begin
            if(!w_btnC) begin
                r_clk_cnt[2] <= 22'd0;
                r_buzzer_frequency[2] <= 0;
            end else begin
                if(r_clk_cnt[2] == 22'd30_337-1)begin
                    r_clk_cnt[2] <= 0;
                    r_buzzer_frequency[2] <= ~r_buzzer_frequency[2];
                end else begin
                    r_clk_cnt[2] <= r_clk_cnt[2] + 1;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if(reset)begin
            r_clk_cnt[3] <= 22'd0;
            r_buzzer_frequency[3] <= 0;
        end else begin
            if(!w_btnR) begin
                r_clk_cnt[3] <= 22'd0;
                r_buzzer_frequency[3] <= 0;
            end else begin
                if(r_clk_cnt[3] == 22'd28_635-1)begin
                    r_clk_cnt[3] <= 0;
                    r_buzzer_frequency[3] <= ~r_buzzer_frequency[3];
                end else begin
                    r_clk_cnt[3] <= r_clk_cnt[3] + 1;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if(reset)begin
            r_clk_cnt[4] <= 22'd0;
            r_buzzer_frequency[4] <= 0;
        end else begin
            if(!w_btnD) begin
                r_clk_cnt[4] <= 22'd0;
                r_buzzer_frequency[4] <= 0;
            end else begin
                if(r_clk_cnt[4] == 22'd25_510-1)begin
                    r_clk_cnt[4] <= 0;
                    r_buzzer_frequency[4] <= ~r_buzzer_frequency[4];
                end else begin
                    r_clk_cnt[4] <= r_clk_cnt[4] + 1;
                end
            end
        end
    end


    assign btn_clean = w_btnU;
    assign buzzer = r_buzzer_frequency[0] |
                    r_buzzer_frequency[1] |
                    r_buzzer_frequency[2] |
                    r_buzzer_frequency[3] |
                    r_buzzer_frequency[4];

endmodule
