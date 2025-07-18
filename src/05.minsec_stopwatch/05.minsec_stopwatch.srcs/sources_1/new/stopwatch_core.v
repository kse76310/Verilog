`timescale 1ns / 1ps

module stopwatch_core(
    input clk,             // 시스템 클럭 (100MHz 가정)
    input reset,           // 전체 시스템 리셋
    input run_stop,        // 시작/정지 제어 신호
    input clear,           // 시간 초기화 신호
    output reg [4:0] hour_count,      // 시 (0-23)
    output reg [5:0] min_count,       // 분 (0-59)
    output reg [5:0] sec_count,       // 초 (0-59)
    output reg [13:0] stopwatch_count // FND 표시용 조합 데이터
);

    // 내부 상태 및 변수 선언
    localparam STATE_IDLE = 1'b0;
    localparam STATE_RUNNING = 1'b1;
    localparam TICK_MAX = 1_000_000; // 100MHz 클럭으로 10ms(1/100초)를 세는 값

    reg state;                  // 스톱워치 상태 (IDLE, RUNNING)
    reg [19:0] tick_counter;    // 10ms tick 생성용 카운터
    reg [6:0] ms_count;         // 1/100초 카운터 (0-99)

    // run_stop 버튼의 엣지(눌리는 순간)를 감지하기 위한 로직
    reg run_stop_ff1, run_stop_ff2;
    wire run_stop_edge;
    assign run_stop_edge = ~run_stop_ff2 && run_stop_ff1;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            run_stop_ff1 <= 0;
            run_stop_ff2 <= 0;
        end else begin
            run_stop_ff1 <= run_stop;
            run_stop_ff2 <= run_stop_ff1;
        end
    end

    // 스톱워치 핵심 로직 (상태 제어 및 시간 카운팅)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // 모든 값 초기화
            state <= STATE_IDLE;
            tick_counter <= 0;
            ms_count <= 0;
            sec_count <= 0;
            min_count <= 0;
            hour_count <= 0;

        // Clear 버튼이 눌리면 시간을 '0'으로 초기화하고 멈춤 상태로 전환
        end else if (clear) begin
            state <= STATE_IDLE;
            ms_count <= 0;
            sec_count <= 0;
            min_count <= 0;
            hour_count <= 0;
        
        // 그 외의 경우 (정상 동작)
        end else begin
            // 1. 상태 전환: run_stop 버튼이 눌리는 순간 상태를 변경 (IDLE <-> RUNNING)
            if (run_stop_edge) begin
                state <= ~state;
            end

            // 2. 시간 계산: RUNNING 상태일 때만 카운터 동작
            if (state == STATE_RUNNING) begin
                if (tick_counter == TICK_MAX - 1) begin
                    tick_counter <= 0;
                    
                    // 계단식 카운터 (Cascading Counter)
                    ms_count <= ms_count + 1;
                    if (ms_count == 99) begin
                        ms_count <= 0;
                        sec_count <= sec_count + 1;
                        if (sec_count == 59) begin
                            sec_count <= 0;
                            min_count <= min_count + 1;
                            if (min_count == 59) begin
                                min_count <= 0;
                                hour_count <= hour_count + 1;
                            end
                        end
                    end
                end else begin
                    tick_counter <= tick_counter + 1;
                end
            end
        end
    end
    
    always @(*) begin
        stopwatch_count = sec_count * 100 + ms_count;
    end
    
endmodule