`timescale 1ns / 1ps

module btn_command_controller(
    input clk,
    input reset,
    input [7:0] sw,
    input [2:0] debounced_btn,      // [0]:모드변경, [1]:시작/정지, [2]:초기화
    input [4:0] hour_count,
    input [5:0] min_count,
    // sec_count, stopwatch_count의 비트 폭을 기능에 맞게 수정하는 것을 권장합니다.
    input [5:0] sec_count,          // 0~59 -> 6비트면 충분
    input [6:0] stopwatch_count,    // 0~99 -> 7비트면 충분
    output reg clear,
    output reg run_stop,
    output reg [13:0] seg_data,     // 0~9999 값을 표현해야 하므로 14비트 유지
    output reg [15:0] led
);

    // FSM 상태 정의
    localparam IDLE      = 2'b00;
    localparam MINSEC    = 2'b01;
    localparam STOPWATCH = 2'b10;

    // 상태 저장을 위한 레지스터
    reg [1:0] r_mode;       // 현재 모드 상태
    reg       r_run_stop;   // 현재 시작/정지 상태

    // 버튼 입력 에지(Edge) 감지용 레지스터
    reg [2:0] prev_btn;

    // 에지 감지 로직 (버튼을 눌렀다가 뗄 때 감지)
    wire mode_btn_pressed   = (prev_btn[0] == 1'b1) && (debounced_btn[0] == 1'b0);
    wire run_stop_btn_pressed = (prev_btn[1] == 1'b1) && (debounced_btn[1] == 1'b0);
    wire clear_btn_pressed    = (prev_btn[2] == 1'b1) && (debounced_btn[2] == 1'b0);

    //======================================================================
    // 순차 논리 (Sequential Logic): 모든 상태(mode, run_stop)를 여기서만 업데이트
    //======================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_mode <= IDLE;
            r_run_stop <= 1'b0;
            prev_btn <= 3'b0;
        end else begin
            // 버튼의 이전 상태를 매 클럭 저장
            prev_btn <= debounced_btn;

            // 모드 변경 로직
            if (mode_btn_pressed) begin
                case(r_mode)
                    IDLE:      r_mode <= MINSEC;
                    MINSEC:    r_mode <= STOPWATCH;
                    STOPWATCH: r_mode <= IDLE;
                    default:   r_mode <= IDLE;
                endcase
            end

            // 현재 모드에 따른 run_stop 상태 로직
            case(r_mode)
                IDLE: begin
                    r_run_stop <= 1'b0; // IDLE 모드에서는 항상 정지
                end
                MINSEC: begin
                    r_run_stop <= 1'b1; // 시계 모드에서는 항상 동작
                end
                STOPWATCH: begin
                    if (run_stop_btn_pressed) begin
                        r_run_stop <= ~r_run_stop; // 스톱워치 모드에서는 버튼으로 토글
                    end
                    // 모드 변경 시 스톱워치 정지
                    if (mode_btn_pressed) begin
                        r_run_stop <= 1'b0;
                    end
                end
            endcase
        end
    end

    //======================================================================
    // 조합 논리 (Combinational Logic): 현재 상태(r_mode)에 따라 출력만 결정
    //======================================================================
    always @(*) begin
        // 모든 출력의 기본값을 먼저 설정
        clear    = 1'b0;
        run_stop = r_run_stop; // 상태 레지스터 값을 출력에 바로 연결
        seg_data = 14'd0;
        led      = 16'b0;

        case (r_mode)
            IDLE: begin
                led[0]   = 1'b1; // IDLE 표시등
                clear    = 1'b1; // IDLE 모드에서는 항상 타이머 초기화
                seg_data = 14'd0; // FND에 0000 표시
            end

            MINSEC: begin
                led[1]   = 1'b1; // MINSEC 표시등
                // 분과 초를 조합하여 4자리 숫자로 만듦 (e.g., 12분 34초 -> 1234)
                seg_data = min_count * 100 + sec_count;
                if (mode_btn_pressed) begin // ★ MINSEC -> STOPWATCH 로 넘어갈 때 clear!
                    clear = 1'b1;
                end
            end
            
            STOPWATCH: begin
                led[2]   = 1'b1; // STOPWATCH 표시등
                led[15]  = r_run_stop; // 동작 상태 표시등
                // 초와 1/100초를 조합하여 4자리 숫자로 만듦 (e.g., 23초 45 -> 2345)
                seg_data = sec_count * 100 + stopwatch_count;

                // 정지 상태에서 clear 버튼이 눌렸을 때만 초기화 신호 발생
                if ((clear_btn_pressed && r_run_stop == 1'b0) || mode_btn_pressed) begin
                    clear = 1'b1;
                end
            end
        endcase
    end

endmodule