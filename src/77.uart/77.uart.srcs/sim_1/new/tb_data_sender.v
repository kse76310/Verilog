`timescale 1ns / 1ps

module tb_data_sender;

    // DUT(Device Under Test)의 입력으로 사용할 reg 타입 변수
    reg             clk;
    reg             reset;
    reg             start_trigger;
    reg    [13:0]   send_data;
    reg             tx_done;
    // tx_busy는 현재 로직에서 사용되지 않지만, 포트 연결을 위해 선언
    reg             tx_busy;

    // DUT의 출력으로 사용할 wire 타입 변수
    wire            tx_start;
    wire    [7:0]   tx_data;


    // 테스트 대상 모듈(DUT)인 data_sender를 인스턴스화
    data_sender u_dut (
        .clk(clk),
        .reset(reset),
        .start_trigger(start_trigger),
        .send_data(send_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_start(tx_start),
        .tx_data(tx_data)
    );

    // 1. 클럭(100MHz) 생성
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 주기의 클럭 생성 (5ns high, 5ns low)
    end

    // 2. 테스트 시나리오
    initial begin
        // 초기화
        reset = 1;
        start_trigger = 0;
        send_data = 0;
        tx_done = 0;
        tx_busy = 0;

        // 리셋 신호 20ns 동안 인가
        #20;
        reset = 0;
        
        // 1초 틱 신호를 100ms 마다 발생시켜서 시뮬레이션 시간 단축
        // 실제 하드웨어에서는 1초지만, 시뮬레이션에서는 더 짧게 테스트
        forever begin
            #100_000_000; // 100ms 대기
            start_trigger = 1; // 1초 틱 발생!
            send_data = send_data + 1; // 카운터 값 증가
            #10; // 1클럭 동안만 유지
            start_trigger = 0;
        end
    end
    
    // 3. 가상 UART TX 모듈 (tx_done 신호 생성)
    // tx_start 신호가 들어오면, 일정 시간 후 tx_done 신호를 1클럭 동안 발생시킴
    always @(posedge clk) begin
        if (tx_start) begin
            // 115200 보드레이트 기준 1비트 전송 시간은 약 8.6us
            // 10비트(start+data+stop) 전송 시간은 약 86us
            #86_000; // 86us 대기
            tx_done <= 1;
            #10;
            tx_done <= 0;
        end
    end

    // 4. 모니터링: DUT의 출력을 관찰
    // tx_start가 1일 때, 어떤 문자가 전송되는지 콘솔에 출력
    always @(posedge clk) begin
        if (tx_start) begin
            // %t: 현재 시뮬레이션 시간 출력
            // %c: 데이터를 ASCII 문자로 출력
            $display("Time: %t,  UART TX -> %c", $time, tx_data);
        end
    end

endmodule