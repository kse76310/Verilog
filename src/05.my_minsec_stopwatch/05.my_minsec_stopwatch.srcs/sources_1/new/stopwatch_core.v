`timescale 1ns / 1ps

// =================================================================
// Verilog 스톱워치 로직 (ms 정밀도)
// - 입력 클럭: 50MHz
// - 기능: 시작/정지, 리셋
// - 카운트: 분, 초, 밀리초
// =================================================================
module stopwatch_ms (
    input clk,              // 50MHz 클럭 입력
    input reset,            // 리셋 버튼 (Active High)
    input run_stop,       // 시작/정지 토글 버튼
    input clear,
    output reg [9:0] ms,    // 밀리초 출력 (0-999, 10비트 필요)
    output reg [5:0] sec,   // 초 출력 (0-59, 6비트 필요)
    output reg [5:0] min    // 분 출력 (0-59, 6비트 필요)
);

    // --- 내부 신호 선언 ---
    // 1. 클럭 분주기용 (1kHz 틱 생성)
    reg [15:0] clk_counter; // 50,000을 세기 위한 카운터 (2^16 > 50000)
    wire one_ms_tick;       // 1ms마다 한 펄스씩 나오는 신호

    // 2. 제어 로직용
    reg enable;             // 스톱워치 동작(1)/정지(0) 상태
    reg start_stop_sync;
    reg start_stop_prev;

    // --- 1. 클럭 분주기 (50MHz -> 1kHz) ---
    // 50MHz 클럭을 50,000번 세면 1ms가 됩니다. (50,000,000 Hz / 1,000 Hz = 50,000)
    assign one_ms_tick = (clk_counter == 49999); // 0~49999까지 5만 번

    always @(posedge clk) begin
        if (reset || one_ms_tick) begin
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end

    // --- 2. 제어 로직 (리셋, 시작/정지) ---
    // (이전 코드와 동일)
    always @(posedge clk) begin
        start_stop_sync <= run_stop;
        start_stop_prev <= start_stop_sync;
    end
    
    wire start_stop_edge = start_stop_sync & ~start_stop_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            enable <= 0;
        end else if (start_stop_edge) begin
            enable <= ~enable;
        end
    end

    // --- 3. 분/초/밀리초 카운터 ---
    // enable 상태일 때만 1ms 틱에 맞춰 카운트합니다.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ms <= 0;
            sec <= 0;
            min <= 0;
        end else if (one_ms_tick && enable) begin // 스톱워치가 동작 중이고 1ms가 되면
            if (ms == 999) begin
                ms <= 0;
                if (sec == 59) begin
                    sec <= 0;
                    if (min == 59) begin
                        min <= 0; // 59분 59초 999ms 다음은 0
                    end else begin
                        min <= min + 1; // 분 증가
                    end
                end else begin
                    sec <= sec + 1; // 초 증가
                end
            end else begin
                ms <= ms + 1; // 밀리초 증가
            end
        end
    end

endmodule
