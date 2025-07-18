`timescale 1ns / 1ps


module tb_fsm();

    // 1. 신호 선언
    reg clk;
    reg reset; // 포트 이름 'rst_n'으로 수정
    reg btnU;
    reg btnD;
    wire [6:0] led;

    // 2. DUT(Design Under Test) 인스턴스화
    //    모듈 이름과 포트 이름을 정확하게 맞춰주어야 합니다.
    fsm dut (
        .clk(clk),
        .reset(reset), // 포트 이름 'rst_n'으로 수정
        .btnU(btnU),
        .btnD(btnD),
        .led(led)
    );

    // 3. 클럭 생성
    always #5 clk = ~clk;

    // 4. 입력 신호 (Stimulus) 생성
    initial begin
        // 초기화: 클럭과 버튼은 0, 리셋은 Active Low이므로 0으로 시작
        clk = 0;
        reset = 0; 
        btnU = 0;
        btnD = 0;

        // 리셋을 20ns 동안 유지한 후 풀어준다 (rst_n = 1)
        #20 reset = 1;

        // 버튼 누르는 순서: 0 -> 0 -> 1 -> 0 -> 1 -> 1
        
        // btnD (0) 입력
        #20 btnD = 1;
        #10 btnD = 0; // 버튼을 누르고 1 클럭(10ns) 후에 뗀다

        // btnD (0) 입력 (연속된 00 입력 -> led[0]이 켜지는지 확인)
        #20 btnD = 1;
        #10 btnD = 0;

        // btnU (1) 입력
        #20 btnU = 1;
        #10 btnU = 0;

        // btnD (0) 입력
        #20 btnD = 1;
        #10 btnD = 0;

        // btnU (1) 입력
        #20 btnU = 1;
        #10 btnU = 0;
        
        // btnU (1) 입력 (연속된 11 입력 -> led[0]이 켜지는지 확인)
        #20 btnU = 1;
        #10 btnU = 0;

        // 시뮬레이션 종료
        #100 $finish;
    end
endmodule
