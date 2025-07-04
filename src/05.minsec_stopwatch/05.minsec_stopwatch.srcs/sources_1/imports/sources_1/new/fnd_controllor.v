`timescale 1ns / 1ps

// 상위 모듈: 각 FND 기능 모듈들을 연결합니다.
module fnd_controllor(
    input clk,
    input reset,
    input [13:0] input_data,
    input animation_active,
    output [7:0] seg,
    output [3:0] an      // 자릿수 선택
);
    // 내부 신호선 선언
    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    // 1. FND 자릿수 선택기 모듈
    fnd_digit_select u_fnd_digit_select(
        .clk(clk),
        .reset(reset),
        .sel(w_sel)
    );
    
    // 2. 2진수 -> BCD 변환기 모듈
     bin2bcd u_bin2bcd(
        .in_data(input_data),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000)
    );

    // 3. FND 표시기 모듈
    fnd_display u_fnd_display(
        .clk(clk),
        .reset(clk),
        .digit_sel(w_sel),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000),
        .animation_active(animation_active),
        .an(an),
        .seg(seg) // 수정된 부분: seg_data -> seg
    );

endmodule


// 1ms 주기로 FND 자릿수를 선택하는 신호를 생성합니다.
module fnd_digit_select (
    input clk,
    input reset,
    output reg [1:0] sel // 00 01 10 11
);
    reg [16:0] r_1ms_counter = 0;
    
    // 이 모듈은 r_digit_sel이 없어도 구현 가능하여 코드를 간결화했습니다.
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_1ms_counter <= 0;
            sel <= 0;
        end else begin
            if(r_1ms_counter == 100_000-1) begin // 100MHz 클럭 기준 1ms
                r_1ms_counter <= 0;
                sel <= sel + 1; // sel이 직접 1씩 증가
            end else begin
                // 수정된 부분: 논블로킹 할당 사용
                r_1ms_counter <= r_1ms_counter + 1;
            end
        end
    end
endmodule


// 2진수 값을 10진수 각 자릿수(BCD)로 변환합니다.
module bin2bcd(
    input [13:0] in_data,
    output [3:0] d1,
    output [3:0] d10,
    output [3:0] d100,
    output [3:0] d1000
);
    // 조언: 이 방식은 합성이 매우 비효율적입니다. 아래 설명을 꼭 읽어보세요!
    assign d1    = in_data % 10;
    assign d10   = (in_data / 10) % 10;
    assign d100  = (in_data / 100) % 10;
    assign d1000 = (in_data / 1000) % 10;
endmodule


// 선택된 자리에 해당하는 BCD 데이터를 7-세그먼트 신호로 변환합니다.
module fnd_display(
    input clk,
    input reset,
    input [1:0] digit_sel,
    input [3:0] d1,
    input [3:0] d10,
    input [3:0] d100,
    input [3:0] d1000,
    input animation_active,
    output reg [3:0] an,
    output reg [6:0] seg
);
    reg [3:0] bcd_data;

    reg [2:0] anim_state;
    reg [23:0] anim_timer;

    always @(posedge clk or posedge reset) begin // 이 모듈에 클럭/리셋 추가 필요
        if(reset) begin
            anim_timer <= 0;
            anim_state <= 0;
        end else if (animation_active) begin
            // 약 0.17초마다 상태 변경
            if (anim_timer == 16_700_000 - 1) begin 
                anim_timer <= 0;
                anim_state <= (anim_state == 5) ? 0 : anim_state + 1;
            end else begin
                anim_timer <= anim_timer + 1;
            end
        end else begin
            anim_timer <= 0;
            anim_state <= 0;
        end
    end

    // FND 표시 로직 수정
    always @(*) begin
        // 애니메이션이 활성화되면 숫자 대신 애니메이션 표시
        if (animation_active) begin
            an = 4'b0000; // 4개 FND 모두 켜기
            case(anim_state)
                0: seg = 8'hFE; // a (gfedcba 순서, 0=ON) -> 11111110 -> FE
                1: seg = 8'hFD; // b
                2: seg = 8'hFB; // c
                3: seg = 8'hF7; // d
                4: seg = 8'hEF; // e
                5: seg = 8'hDF; // f
                default: seg = 8'hFF; // off
            endcase
        // 애니메이션 비활성화 시, 기존 숫자 표시 로직 동작
        end else begin
            case(digit_sel)
                2'b00: begin bcd_data = d1; an = 4'b1110; end
                2'b01: begin bcd_data = d10; an = 4'b1101; end
                2'b10: begin bcd_data = d100; an = 4'b1011; end
                2'b11: begin bcd_data = d1000; an = 4'b0111; end
                default: begin bcd_data = 4'b0000; an = 4'b1111; end
            endcase
            
            case(bcd_data)
                4'd0: seg = 8'hC0; 4'd1: seg = 8'hF9; 4'd2: seg = 8'hA4;
                4'd3: seg = 8'hB0; 4'd4: seg = 8'h99; 4'd5: seg = 8'h92;
                4'd6: seg = 8'h82; 4'd7: seg = 8'hF8; 4'd8: seg = 8'h80;
                4'd9: seg = 8'h90; default: seg = 8'hFF;
            endcase
        end
    end
endmodule