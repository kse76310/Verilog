`timescale 1ns / 1ps

module top_micro_tb;

    // 1. 가상 입력/출력 신호 선언
    reg clk;
    reg reset;
    // 5개의 버튼을 하나의 벡터로 관리
    reg [4:0] btn; // [0]:L, [1]:C, [2]:R, [3]:U, [4]:D

    wire [15:0] led;
    wire [7:0]  seg;
    wire [3:0]  an;

    // 내부적으로 BCD 값을 모니터링하기 위한 wire
    wire [3:0] bcd_min_t, bcd_min_o, bcd_sec_t, bcd_sec_o;


    // 2. 테스트 대상(DUT) 선언 및 연결
    top_micro uut (
        .clk(clk),
        .reset(reset),
        .btnL(btn[0]),
        .btnC(btn[1]),
        .btnR(btn[2]),
        .btnU(btn[3]),
        .btnD(btn[4]),
        .led(led),
        .seg(seg),
        .an(an)
    );
    
    // Testbench 내부에서 BCD 값을 보기 위한 연결 (DUT 수정 필요 없음)
    // uut의 timer_counter 인스턴스의 BCD 출력에 직접 연결
    assign bcd_min_t = uut.u_time_counter.bcd_minutes_tens;
    assign bcd_min_o = uut.u_time_counter.bcd_minutes_ones;
    assign bcd_sec_t = uut.u_time_counter.bcd_seconds_tens;
    assign bcd_sec_o = uut.u_time_counter.bcd_seconds_ones;


    // 3. 클럭 생성
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz 클럭

    
    // [Pro-Tip] 버튼 누르기 동작을 task로 정의
    task press_button;
        input [2:0] btn_idx; // 누를 버튼의 인덱스
    begin
        btn[btn_idx] = 1'b1;
        // [수정] 100ns -> 20ms (20,000,000 ns)
        // 디바운스 시간(10ms)보다 충분히 길게 누름
        #20_000_000; 
        btn[btn_idx] = 1'b0;
        #100; // 버튼 떼고 100ns 대기
    end
    endtask


    // 4. 테스트 시나리오
    initial begin
        // --- 초기화 ---
        reset = 1'b1;
        btn = 5'b0;
        #200;
        reset = 1'b0;
        #200;

        // --- 시나리오 1: 시간 설정 (1분 20초) 후 시작 ---
        $display("[%0t ns] SCENARIO 1: Set time to 1:20 and Start", $time);
        press_button(3); // 1분 추가 (U)
        press_button(4); // 10초 추가 (D)
        press_button(4); // 10초 추가 (D)
        
        #1000; // 시간 설정 후 잠시 대기
        
        press_button(1); // 시작 (C)
        $display("[%0t ns] >> Cooking Started.", $time);
        
        // [수정] 5초 지연
        repeat(5) #1_000_000_000;


        // --- 시나리오 2: 일시정지 및 재시작 ---
        $display("[%0t ns] SCENARIO 2: Pause and Resume", $time);
        press_button(1); // 일시정지 (C)
        $display("[%0t ns] >> Paused.", $time);
        
        // [수정] 2초 지연
        repeat(2) #1_000_000_000; 

        press_button(1); // 재시작 (C)
        $display("[%0t ns] >> Resumed.", $time);

        // [수정] 3초 지연
        repeat(3) #1_000_000_000; 
        
        // --- 시나리오 3: 조리 중 취소 ---
        $display("[%0t ns] SCENARIO 3: Stop during cooking", $time);
        press_button(2); // 취소 (R)
        $display("[%0t ns] >> Stopped and Reset.", $time);

        // [수정] 2초 지연
        repeat(2) #1_000_000_000;

        // --- 시나리오 4: 간편 조리 (30초) ---
        $display("[%0t ns] SCENARIO 4: Quick Start (30s)", $time);
        press_button(0); // 간편조리 (L)
        $display("[%0t ns] >> Quick Start initiated.", $time);

        // [수정] 35초 지연
        repeat(35) #1_000_000_000;

        $display("[%0t ns] >> TEST FINISHED.", $time);
        $finish;

        
    end

endmodule