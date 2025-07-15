`timescale 1ns / 1ps

module top_micro_tb;

    // 1. DUT 입력/출력 신호 선언
    // 입력은 reg, 출력은 wire
    reg clk;
    reg reset;
    reg btnL, btnC, btnR, btnU, btnD;
    reg door_is_open;
    

    wire [15:0] led;
    wire [7:0]  seg;
    wire [3:0]  an;
    wire fan_in1, fan_in2, fan_ena;
    wire pwm_out;
    wire buzzer_out;


    // 2. DUT(테스트 대상) 선언 및 연결
    top_micro uut (
        .clk(clk),
        .reset(reset),
        .btnL(btnL), .btnC(btnC), .btnR(btnR), .btnU(btnU), .btnD(btnD),
        .door_is_open(door_is_open),
        .led(led),
        .seg(seg),
        .an(an),
        .fan_in1(fan_in1), .fan_in2(fan_in2), .fan_ena(fan_ena),
        .pwm_out(pwm_out),
        .buzzer_out(buzzer_out)
    );
    
    // 3. 클럭 생성 (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. 테스트 시나리오
    // 4. 테스트 시나리오 (최종 수정본)
    initial begin
        // --- 초기화 ---//
        clk = 0;
        reset = 1'b1;
        {btnL, btnC, btnR, btnU, btnD} = 5'b0;
        door_is_open = 1'b0; 
    
        #200;
        reset = 1'b0;
        #200;

        // --- 시나리오 1: 문 제어 테스트 --

        // --- 시나리오 2: 안전장치 테스트 (문 열고 시작 시도) ---
        $display("[%0t ns] SCENARIO 2: Safety test (Door is open)", $time);
        door_is_open = 1'b1; // 센서: 문이 열림
        #200;
        btnC = 1'b1; #200; btnC = 1'b0; // 시작 버튼 누르기 -> 동작 안해야 함
        #200; // 50ms 대기하며 상태 변화 없는지 확인
        door_is_open = 1'b0; // 센서: 문이 닫힘
        #200;
        
        // --- 시나리오 3: 조리 및 완료 테스트 (10초) ---
        $display("[%0t ns] SCENARIO 3: Cooking test (10s)", $time);
        btnD = 1'b1; #200; btnD = 1'b0; // 10초 설정
        #500; // 50ms 대기

        btnC = 1'b1; #200; btnC = 1'b0; // 시작
        $display("[%0t ns] >> Cooking started for 10s. Fan should be ON.", $time);
        
        // [수정] 10초 조리 + 2초 알람 확인 = 총 12초 기다리기
        repeat(12) #1000; 

        $display("[%0t ns] >> TEST FINISHED.", $time);
        $finish;
    end


endmodule