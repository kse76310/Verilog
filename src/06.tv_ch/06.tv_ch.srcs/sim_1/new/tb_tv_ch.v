`timescale 1ns / 1ps

// 테스트벤치 모듈
module tb_tv_ch();

    // 신호 선언
    reg         clk;
    reg         rstn;
    reg         up;
    reg         dn;
    wire [3:0]  ch; // DUT의 출력은 wire로 받습니다.

    // 테스트할 모듈(DUT)을 인스턴스화 (연결)
    tv_ch dut(
        .clk(clk),
        .rstn(rstn),
        .up(up),
        .dn(dn),
        .ch(ch)
    );

    //=================================================
    // 1. Clock 생성 블록 (이 부분이 빠져있었습니다)
    //=================================================
    // 10ns의 주기를 갖는 클럭(100MHz)을 생성합니다.
    parameter CLK_PERIOD = 10;
    initial begin
        clk = 0; // 시뮬레이션 시작 시 clk를 0으로 초기화
        forever begin
            #(CLK_PERIOD / 2) clk = ~clk; // 반 주기마다 clk 값을 뒤집음
        end
    end

    //=================================================
    // 2. 테스트 시나리오 블록
    //=================================================
    initial begin
        // 시뮬레이션 동안 주요 신호들을 콘솔 창에 출력
        $monitor("Time=%0t | Reset=%b, Up=%b, Dn=%b | Channel Output = %d", $time, rstn, up, dn, ch);

        // --- 초기화 및 리셋 ---
        rstn = 1; up = 0; dn = 0;
        #5;
        rstn = 0; // 리셋 활성화 (신호를 0으로)
        #20;
        rstn = 1; // 리셋 비활성화 (정상 동작 시작)
        #10;

        // --- 채널 증가 테스트 ---
        $display("\n--- Channel UP Test ---");
        up = 1; dn = 0;
        repeat (12) @(posedge clk); // 12 클럭 동안 up=1 유지
        up = 0;
        #20;

        // --- 채널 감소 테스트 ---
        $display("\n--- Channel DOWN Test ---");
        dn = 1;
        repeat (5) @(posedge clk); // 5 클럭 동안 dn=1 유지
        dn = 0;
        #20;

        // --- 동시 입력 테스트 ---
        $display("\n--- Both Inputs Test ---");
        up = 1; dn = 1;
        repeat (5) @(posedge clk); // 5 클럭 동안 둘 다 1 유지
        up = 0; dn = 0;
        #20;

        $display("\n--- Test Finished ---");
        $finish; // 시뮬레이션 종료
    end

endmodule