`timescale 1ns / 1ps

// DUT가 사용하는 tick_generator 모듈
// 이 모듈도 시뮬레이션에 필요합니다.
module tick_generator (
    input clk, 
    input reset, 
    output reg tick
);
    parameter INPUT_FREQ = 100_000_000; // 100MHz 클럭
    parameter TICK_HZ = 1000;          // 1000Hz = 1ms tick
    parameter TICK_COUNT = INPUT_FREQ / TICK_HZ;

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_tick_counter <= 0;
            tick           <= 1'b0;
        end else begin
            if(r_tick_counter == TICK_COUNT - 1) begin
                r_tick_counter <= 0;
                tick           <= 1'b1;
            end else begin
                r_tick_counter <= r_tick_counter + 1;
                tick           <= 1'b0;
            end
        end
    end
endmodule


// my_btn_debounce 모듈을 위한 테스트벤치
module tb_my_btn_debounce;
    // --- 신호 선언 ---
    reg  clk; 
    reg  reset; 
    reg  btn;
    wire led;

    // --- DUT (Device Under Test) 인스턴스화 ---
    my_btn_debounce u_my_btn_debounce(
        .i_clk(clk), 
        .i_reset(reset), 
        .i_btn(btn),
        .o_led(led)
    );

    // --- 클럭 생성 (100MHz) ---
    initial begin
        clk = 0;
    end
    always #5 clk = ~clk; // 10ns period = 100MHz

    // --- 테스트 시나리오 ---
    initial begin
        // 1. 초기화 및 리셋
        reset = 1'b0;
        btn   = 1'b0;
        #10;
        reset = 1'b1; // 리셋 활성화
        #20;
        reset = 1'b0; // 리셋 비활성화
        
        #50;

        // 2. 채터링(Chattering) 시뮬레이션
        // 1ms(1,000,000ns) 보다 짧은 간격으로 여러 번 토글
        $display("--- Start Chattering Test ---");
        #100_000 btn = 1;
        #200_000 btn = 0;
        #150_000 btn = 1;
        #300_000 btn = 0;
        #100_000 btn = 1; // 채터링이 끝나고 버튼이 안정적으로 눌림

        // 3. 안정된 눌림 상태 유지 (Debounce 시간보다 길게)
        // Debounce 시간은 10 ticks = 10ms. 15ms 동안 유지하여 출력이 1이 되는지 확인
        $display("--- Start Stable Press Test (Expecting led to be 1) ---");
        #15_000_000; 

        // 4. 안정된 떼어짐 상태 유지
        $display("--- Start Stable Release Test (Expecting led to be 0) ---");
        btn = 0;
        #15_000_000;

        // 5. 시뮬레이션 종료
        $display("--- Test Finished ---");
        $stop;
    end

endmodule