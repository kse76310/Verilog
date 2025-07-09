`timescale 1ns / 1ps

// 새로운 모듈 이름으로 만듭니다.
module tb_minimal();
    reg clk;
    reg btnU, btnL, btnC, btnR, btnD;
    wire [7:0] seg;
    wire [3:0] an;

    // DUT 인스턴스화
    // ※ dut 이름이 vending_top이 맞는지 한번 더 확인해주세요.
    top dut (
        .clk(clk),
        .btnU(btnU),
        .btnL(btnL),
        .btnC(btnC),
        .btnR(btnR),
        .btnD(btnD),
        .seg(seg),
        .an(an)
    );

    // 클럭 생성
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ★★★ 오직 리셋과 100원 버튼 누르기만 테스트 ★★★
    initial begin
        $display(">>> 미니멀 테스트벤치 시작! <<<");

        // 1. 모든 버튼 0으로 초기화
        btnU = 0; btnL = 0; btnC = 0; btnR = 0; btnD = 0;
        #100;

        // 2. 리셋 신호
        $display("리셋 중...");
        btnU = 1; #100; btnU = 0;
        #1000;

        // 3. 100원 버튼을 20ms 동안 누르기
        $display("100원 버튼 누르기 시작...");
        btnL = 1;
        #20_000_000; // 20ms 동안 계속 누르고 있기
        btnL = 0;
        $display("100원 버튼 떼기.");
        #1000;

        $display("미니멀 테스트벤치 종료.");
        $finish;
    end
endmodule