`timescale 1ns / 1ps

module my_btn_debounce(
    input i_clk, 
    input i_reset, 
    input i_btn,
    output reg o_led
    );

    reg r_btn_prev = 0;
    reg [$clog2(1_000_000)-1:0] r_10ms_counter = 0;

    always @(posedge i_clk or posedge i_reset) begin
        if(i_reset) begin
            r_btn_prev <= 0;
            r_10ms_counter <= 0;
            o_led <= 0;
        end else begin
            if(r_10ms_counter == 0) begin
                if(r_btn_prev != i_btn) begin
                    r_10ms_counter <= 1;
                    r_btn_prev = i_btn;
                end else begin
                end
            end else if(r_10ms_counter == 1_000_000) begin
                r_10ms_counter <= 0;
                if(r_btn_prev == i_btn) begin
                    o_led <= i_btn;
                end else begin    
                    r_10ms_counter <= 1;
                end
            end else begin
                r_10ms_counter <= r_10ms_counter + 1;
            end
        end

    end

endmodule


// module my_button_debounce(
//     input i_clk, 
//     input i_reset,
//     input i_btn,
//     output reg o_led
//     );
//     wire w_tick;
//     wire w_out_clk;
//     reg r_btn_prev = 0;
//     reg [3:0] stable_count = 0;

//     tick_gennerator u_tick_gen(
//         .clk(i_clk),
//         .reset(i_reset),
//         .tick(w_tick)
//     );

//       always @(posedge w_tick, posedge i_reset) begin
//         if(i_reset) begin
//             r_btn_prev <= 0;
//             stable_count <= 0;
//             o_led <= 0;
//         end else begin
//             if(i_btn == r_btn_prev) begin
//             if(stable_count < 10)
//             stable_count <= stable_count + 1;
//             end else begin
//                 stable_count <=0;
//                 r_btn_prev <= i_btn;
//             end

//             if(stable_count == 10)
//                 o_led <= r_btn_prev;
//         end

//      end

// endmodule