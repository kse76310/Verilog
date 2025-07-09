module my_button_debounce(
    input i_clk, 
    input i_reset,
    input i_btn,
    output reg o_btn
    );
    wire w_tick;
    wire w_out_clk;
    reg r_btn_prev = 0;
    reg [3:0] stable_count = 0;

    tick_gennerator u_tick_gen(
        .clk(i_clk),
        .reset(i_reset),
        .tick(w_tick)
    );

      always @(posedge w_tick, posedge i_reset) begin
        if(i_reset) begin
            r_btn_prev <= 0;
            stable_count <= 0;
            o_btn <= 0;
        end else begin
            if(i_btn == r_btn_prev) begin
            if(stable_count < 10)
            stable_count <= stable_count + 1;
            end else begin
                stable_count <=0;
                r_btn_prev <= i_btn;
            end

            if(stable_count == 10)
                o_btn <= r_btn_prev;
        end

     end

endmodule