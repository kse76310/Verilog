`timescale 1ns / 1ps

module data_sender(
    input               clk,
    input               reset,
    input               start_trigger,
    input        [13:0] send_data,
    input               tx_busy,
    input               tx_done,
    output reg          tx_start,
    output reg    [7:0] tx_data

    );

    // 상태(state) 정의
    localparam S_IDLE      = 3'd0; // 대기 상태
    localparam S_SEND_THOU = 3'd1; // 천의 자리 전송
    localparam S_SEND_HUND = 3'd2; // 백의 자리 전송
    localparam S_SEND_TENS = 3'd3; // 십의 자리 전송
    localparam S_SEND_UNIT = 3'd4; // 일의 자리 전송
    localparam S_SEND_CR   = 3'd5; // 줄바꿈 (CR)
    localparam S_SEND_LF   = 3'd6; // 줄바꿈 (LF)

    reg [2:0] state;

    // 전송할 각 자릿수를 저장하는 레지스터
    reg [7:0] digit_thou, digit_hund, digit_tens, digit_unit;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= S_IDLE;
            tx_start   <= 1'b0;
            tx_data    <= 8'h00;
            digit_thou <= 0;
            digit_hund <= 0;
            digit_tens <= 0;
            digit_unit <= 0;
        end else begin
            // tx_start는 1클럭 펄스로 만들기 위해 매 클럭 0으로 초기화
            tx_start <= 1'b0;

            case (state)
                S_IDLE: begin
                    // 1초 틱(start_trigger)이 들어오면 숫자 변환 및 전송 준비
                    if (start_trigger) begin
                        // 1. 입력된 카운터 값을 각 10진수 자릿수로 분리
                        digit_thou <= send_data / 1000;
                        digit_hund <= (send_data % 1000) / 100;
                        digit_tens <= (send_data % 100) / 10;
                        digit_unit <= send_data % 10;
                        
                        // 2. 첫 번째 자릿수(천의 자리) 전송 시작
                        tx_data    <= (send_data / 1000) + 8'h30; // 숫자 -> ASCII 변환
                        tx_start   <= 1'b1;
                        state      <= S_SEND_HUND; // 다음 상태로
                    end
                end

                S_SEND_HUND: begin
                    // 이전 전송이 완료되면(tx_done) 다음 자릿수 전송
                    if (tx_done) begin
                        tx_data  <= digit_hund + 8'h30;
                        tx_start <= 1'b1;
                        state    <= S_SEND_TENS;
                    end
                end

                S_SEND_TENS: begin
                    if (tx_done) begin
                        tx_data  <= digit_tens + 8'h30;
                        tx_start <= 1'b1;
                        state    <= S_SEND_UNIT;
                    end
                end

                S_SEND_UNIT: begin
                    if (tx_done) begin
                        tx_data  <= digit_unit + 8'h30;
                        tx_start <= 1'b1;
                        state    <= S_SEND_CR;
                    end
                end

                S_SEND_CR: begin
                    if (tx_done) begin
                        tx_data  <= 8'h0D; // Carriage Return
                        tx_start <= 1'b1;
                        state    <= S_SEND_LF;
                    end
                end

                S_SEND_LF: begin
                    if (tx_done) begin
                        tx_data  <= 8'h0A; // Line Feed
                        tx_start <= 1'b1;
                        state    <= S_IDLE; // 모든 전송 완료, 대기 상태로 복귀
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

// // ----- 이름 출력 ---------
//     reg [1:0] r_char;
//     reg is_sending;
//     localparam CHAR_K = 8'h4B;
//     localparam CHAR_S = 8'h53;
//     localparam CHAR_E = 8'h45;
//     // print(KSE)
//     always @(posedge clk or posedge reset) begin
//         if(reset) begin
//             tx_start    <= 0;
//             r_data_cnt  <= 0;
//             r_char      <= 0;
//             is_sending  <= 0;
//             tx_data     <= 0;
//         end else begin
//             tx_start <= 0;
//             if(start_trigger && !is_sending) begin
//                 is_sending <= 1'b1;
//                 r_char <= 2'd0;
//                 tx_data <= CHAR_K;
//                 tx_start <= 1'b1;
//             end else if( is_sending && tx_done) begin
//                 if(r_char == 2'd2)begin
//                     is_sending <= 1'b0;
//                 end else begin
//                     r_char <= r_char + 1;
//                     tx_start <= 1'b1;
//                     case (r_char + 1)
//                         2'd1: tx_data <= CHAR_S;
//                         2'd2: tx_data <= CHAR_E; 
//                         default: tx_data <= 0;
//                     endcase
//                 end
//             end
//         end
//     end


    // ascii code
    // always @(posedge clk or posedge reset) begin
    //     if(reset) begin
    //         tx_start    <= 0;
    //         r_data_cnt  <= 0;
    //     end else begin
    //         if(start_trigger && !tx_busy) begin
    //             tx_start <= 1'b1;         
    //             if(r_data_cnt == 7'd10) begin   // 0 ~ 9 10자
    //                 r_data_cnt  <= 1;
    //                 tx_data <= send_data;
    //             end else begin
    //                 tx_data <= send_data + r_data_cnt;
    //                 r_data_cnt  <= r_data_cnt + 1;
    //             end   
    //         end else begin
    //             tx_start <= 1'b0;
    //         end
    //     end
    // end

endmodule
