`timescale 1ns / 1ps


module uart_controller(
    input clk,
    input reset,
    input  [15:0] send_data, // Changed to 16-bit
    input rx,
    output [7:0] rx_data,
    output rx_done,
    output tx
    );

    wire w_tick_1Hz;
    // Wires and regs for UART TX control
    wire tx_busy;
    wire tx_done;
    reg [7:0] tx_data_reg;
    reg tx_start_reg;
    reg [3:0] uart_state;
    reg [15:0] data_to_send_reg; // Data to be sent via UART


    tick_generator #(
        .INPUT_FREQ(100_000_000),
        .TICK_HZ(0.5) // Changed to 0.5Hz for slower updates
    ) u_tick_1Hz(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1Hz)
    );

    uart_tx u_uart_tx(
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data_reg),
        .tx_start(tx_start_reg),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    // 초음파 측정값 UART 전송 로직
    parameter UART_IDLE = 4'd0,
              UART_SEND_DIGIT_THOUSANDS = 4'd1, // 천의 자리 추가
              UART_SEND_DIGIT_HUNDREDS = 4'd2,
              UART_SEND_DIGIT_TENS = 4'd3,
              UART_SEND_DIGIT_UNITS = 4'd4,
              UART_SEND_CM_C = 4'd5,
              UART_SEND_CM_M = 4'd6,
              UART_SEND_CR = 4'd7,
              UART_SEND_LF = 4'd8;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            uart_state <= UART_IDLE;
            tx_start_reg <= 1'b0;
            tx_data_reg <= 8'd0;
            data_to_send_reg <= 16'd0;
        end else begin
            tx_start_reg <= 1'b0; // 기본적으로 펄스

            case (uart_state)
                UART_IDLE: begin
                    // send_data 값이 변경되면 전송 시작
                    if (send_data != data_to_send_reg) begin
                        data_to_send_reg <= send_data;
                        uart_state <= UART_SEND_DIGIT_THOUSANDS; // 천의 자리부터 시작
                    end
                end

                UART_SEND_DIGIT_THOUSANDS: begin
                    if (!tx_busy) begin
                        tx_data_reg <= (data_to_send_reg / 1000) % 10 + 8'h30; // 천의 자리
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_SEND_DIGIT_HUNDREDS;
                    end
                end

                UART_SEND_DIGIT_HUNDREDS: begin
                    if (!tx_busy) begin
                        tx_data_reg <= (data_to_send_reg / 100) % 10 + 8'h30; // 백의 자리
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_SEND_DIGIT_TENS;
                    end
                end

                UART_SEND_DIGIT_TENS: begin
                    if (!tx_busy) begin
                        tx_data_reg <= (data_to_send_reg / 10) % 10 + 8'h30; // 십의 자리
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_SEND_DIGIT_UNITS;
                    end
                end

                UART_SEND_DIGIT_UNITS: begin
                    if (!tx_busy) begin
                        tx_data_reg <= data_to_send_reg % 10 + 8'h30; // 일의 자리
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_SEND_CR; // Directly go to CR
                    end
                end

                UART_SEND_CM_C: begin
                    if (!tx_busy) begin
                        tx_data_reg <= "c"; // 'c'
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_SEND_CM_M;
                    end
                end

                UART_SEND_CM_M: begin
                    if (!tx_busy) begin
                        tx_data_reg <= "m"; // 'm'
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_SEND_CR;
                    end
                end

                UART_SEND_CR: begin
                    if (!tx_busy) begin
                        tx_data_reg <= 8'h0D; // Carriage Return
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_SEND_LF;
                    end
                end

                UART_SEND_LF: begin
                    if (!tx_busy) begin
                        tx_data_reg <= 8'h0A; // Line Feed
                        tx_start_reg <= 1'b1;
                        uart_state <= UART_IDLE; // 전송 완료, 다시 대기
                    end
                end

                default: uart_state <= UART_IDLE;
            endcase
        end
    end

    
    uart_rx u_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(rx_data),
        .rx_done(rx_done)
    );
    


endmodule