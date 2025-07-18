`timescale 1ns / 1ps

module top_micro_tb;

    // 1. DUT 입력/출력 신호 선언
    reg clk;
    reg reset;
    reg btnL, btnC, btnR, btnU, btnD;
    reg door_is_open; // 실제 문 센서의 상태를 시뮬레이션

    wire [15:0] led;
    wire [7:0]  seg;
    wire [3:0]  an;
    wire fan_in1, fan_in2, fan_ena;
    wire pwm_out;
    wire buzzer_out;


    // 2. DUT 선언 및 연결
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
    initial begin
        // --- 초기화 ---
        reset = 1'b1;
        {btnL, btnC, btnR, btnU, btnD} = 5'b0;
        door_is_open = 1'b0; // 문은 닫힌 상태로 시작
        #200;
        reset = 1'b0;
        #200;
        $display("[%0t ns] SYSTEM RESET", $time);

        // --- 시나리오 1: 문 제어 테스트 (btnR 토글) ---
        $display("[%0t ns] SCENARIO 1: Door control test with btnR", $time);
        btnR = 1'b1; #20_000_000; btnR = 1'b0; // btnR 눌러서 문 열기 명령
        #100;
        door_is_open = 1'b1; // 센서: 문이 실제로 열림 (부저음 발생 확인)
        repeat(2) #1_000_000_000; // 2초 대기
        
        btnR = 1'b1; #20_000_000; btnR = 1'b0; // btnR 다시 눌러서 문 닫기 명령 + 시간 초기화
        #100;
        door_is_open = 1'b0; // 센서: 문이 실제로 닫힘 (부저음 발생 확인)
        repeat(2) #1_000_000_000; // 2초 대기

        // --- 시나리오 2: 조리 및 완료 테스트 (5초) ---
        $display("[%0t ns] SCENARIO 2: Cooking test (5s)", $time);
        btnD = 1'b1; #20_000_000; btnD = 1'b0; // 10초 설정
        btnD = 1'b1; #20_000_000; btnD = 1'b0; // 20초 설정
        btnR = 1'b1; #20_000_000; btnR = 1'b0; // 시간 초기화 (0초)
        
        btnD = 1'b1; #20_000_000; btnD = 1'b0; // 다시 5초 설정
        btnD = 1'b1; #20_000_000; btnD = 1'b0;
        btnD = 1'b1; #20_000_000; btnD = 1'b0;
        btnD = 1'b1; #20_000_000; btnD = 1'b0;
        btnD = 1'b1; #20_000_000; btnD = 1'b0;

        #100;
        btnC = 1'b1; #20_000_000; btnC = 1'b0; // 시작
        $display("[%0t ns] >> Cooking started for 5s.", $time);
        
        // 5초 조리 + 3초 알람 + 2초 여유 = 10초 기다리기
        repeat(10) #1_000_000_000; 

        $display("[%0t ns] >> TEST FINISHED.", $time);
        $finish;
    end

endmodule