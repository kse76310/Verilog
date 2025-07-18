`timescale 1ns / 1ps

// 시뮬레이션 속도 향상을 위한 매크로 정의
`define ONE_SECOND 1_000_000  // 1ms (원래 1,000,000,000ns)
`define BTN_PRESS  20_000     // 20us (원래 20,000,000ns)

// 파일명과 모듈명을 일치시킵니다.
module tb_microwave;

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


    // 2. DUT 선언 및 연결 (DUT 모듈 이름이 top_micro라고 가정)
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
        #100;
        $display("[%0t ns] SYSTEM RESET 완료. 문 닫힘.", $time);

        // --- 시나리오 1: 5초 조리 테스트 ---
        $display("----------------------------------------------------");
        $display("[%0t ns] SCENARIO 1: 5초 조리 테스트 시작", $time);
        
        // btnU를 5번 눌러 5초 설정 (가정: btnU는 1초씩 증가)
        $display("[%0t ns] 1초씩 5번 증가하여 5초를 설정합니다 (btnU x5).", $time);
        repeat(5) begin
            btnU = 1'b1; #`BTN_PRESS; btnU = 1'b0; #100;
        end
        #(`ONE_SECOND); // 1초(시뮬레이션 시간) 대기하여 FND 표시 확인

        // btnC를 눌러 조리 시작
        $display("[%0t ns] 조리를 시작합니다 (btnC).", $time);
        btnC = 1'b1; #`BTN_PRESS; btnC = 1'b0;
        
        // 5초 조리 + 3초 완료 알람 대기
        $display("[%0t ns] 5초 조리 및 3초 알람 대기 중...", $time);
        #(8 * `ONE_SECOND);

        $display("[%0t ns] SCENARIO 1 완료.", $time);
        #(2 * `ONE_SECOND); // 다음 시나리오를 위해 2초 대기

        // --- 시나리오 2: 조리 중 문 열기 테스트 ---
        $display("----------------------------------------------------");
        $display("[%0t ns] SCENARIO 2: 조리 중 문 열기 테스트 시작", $time);
        
        // 10초 설정 (가정: btnD는 10초씩 증가)
        $display("[%0t ns] 10초를 설정합니다 (btnD x1).", $time);
        btnD = 1'b1; #`BTN_PRESS; btnD = 1'b0; #100;
        #(`ONE_SECOND); // 1초 대기

        // 조리 시작
        $display("[%0t ns] 조리를 시작합니다 (btnC).", $time);
        btnC = 1'b1; #`BTN_PRESS; btnC = 1'b0;

        // 3초 후 문 열기
        $display("[%0t ns] 3초 후 문을 엽니다.", $time);
        #(3 * `ONE_SECOND);
        door_is_open = 1'b1;
        $display("[%0t ns] 문이 열렸습니다. 동작이 일시정지되어야 합니다.", $time);

        // 3초 동안 문 열린 상태 유지
        #(3 * `ONE_SECOND);

        // 문 닫기
        door_is_open = 1'b0;
        $display("[%0t ns] 문을 닫았습니다. FND에 남은 시간이 표시되어야 합니다.", $time);
        #(2 * `ONE_SECOND); // 2초 대기

        // 조리 재시작
        $display("[%0t ns] 조리를 재시작합니다 (btnC).", $time);
        btnC = 1'b1; #`BTN_PRESS; btnC = 1'b0;

        // 남은 시간 (7초) + 완료 알람 (3초) 대기
        $display("[%0t ns] 남은 시간 조리 및 알람 대기 중...", $time);
        #(10 * `ONE_SECOND);

        $display("[%0t ns] SCENARIO 2 완료.", $time);
        #(2 * `ONE_SECOND);

        // --- 시나리오 3: 리셋 버튼 테스트 ---
        $display("----------------------------------------------------");
        $display("[%0t ns] SCENARIO 3: 리셋(btnR) 버튼 테스트 시작", $time);
        
        // 10초 설정
        $display("[%0t ns] 10초를 설정합니다 (btnD x1).", $time);
        btnD = 1'b1; #`BTN_PRESS; btnD = 1'b0; #100;
        #(`ONE_SECOND); // 1초 대기

        // 조리 시작
        $display("[%0t ns] 조리를 시작합니다 (btnC).", $time);
        btnC = 1'b1; #`BTN_PRESS; btnC = 1'b0;

        // 3초 후 리셋
        $display("[%0t ns] 3초 후 리셋합니다 (btnR).", $time);
        #(3 * `ONE_SECOND);
        btnR = 1'b1; #`BTN_PRESS; btnR = 1'b0;
        $display("[%0t ns] 리셋 버튼 입력. 모든 동작이 중지되고 시간이 0으로 초기화되어야 합니다.", $time);

        #(2 * `ONE_SECOND); // 2초 대기

        $display("----------------------------------------------------");
        $display("[%0t ns] >> 모든 테스트 완료.", $time);
        $finish;
    end

endmodule