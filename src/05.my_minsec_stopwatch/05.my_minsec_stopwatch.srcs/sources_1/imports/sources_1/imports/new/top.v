`timescale 1ns / 1ps

module top(
    input clk,
    input reset,        // btnU
    input [2:0] btn,
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
);

    // --- 내부 신호 선언 ---
    wire [2:0] w_btn_debounce;
    wire w_tick; // 1ms tick from tick_generator

    // FND 컨트롤러로 전달할 시간 데이터 (16비트로 가정, 예: {2'b0, min, 2'b0, sec})
    wire [15:0] w_fnd_input_data; 
    
    // LED 토글용 레지스터
    reg [$clog2(500)-1:0] r_500ms_count = 0;
    reg [$clog2(100)-1:0] r_100ms_count = 0;
    reg r_led_500mstoggle = 1'b0;
    reg r_led_100mstoggle = 1'b0;

    // --- 모듈 인스턴스 ---

    // 1. 버튼 디바운서
    btn_debouncer U_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .debounce_btn(w_btn_debounce) // 수정: 출력 와이어 이름 통일
    );

    // 2. 1ms 틱 생성기
    tick_generator u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    btn_command_controller u_btn_command_controller(
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .debounce_btn(debounce_btn),    // [0]:모드변경, [1]:시작/정지, [2]:초기화
        .ms(ms),              // ms 입력은 현재 사용되지 않으나, 추후 표시를 위해 유지
        .sec(sec),             // 초 입력
        .min(min),             // 분 입력
        .clear(clear),           // 스톱워치 초기화 신호
        .run_stop(run_stop),        // 스톱워치 시작/정지 신호
        .fnd_data(fnd_data)         // FND에 표시될 데이터
);
    
    // 4. 7세그먼트 표시장치(FND) 제어
    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .input_data(w_fnd_input_data), // 수정: btn_command_controller로부터 데이터 입력
        .seg(seg),
        .an(an)
    );

    stopwatch_ms u_stopwatch_ms(
        .clk(clk),              // 50MHz 클럭 입력
        .reset(reset),            // 리셋 버튼 (Active High)
        .run_stop(run_stop),       // 시작/정지 토글 버튼
        .ms(ms),    // 밀리초 출력 (0-999, 10비트 필요)
        .sec(sec),   // 초 출력 (0-59, 6비트 필요)
        .min(min)    // 분 출력 (0-59, 6비트 필요)
    );

    // --- LED 점멸 로직 ---
    // 1ms 틱을 기준으로 100ms, 500ms 주기로 LED를 토글합니다.
    always @(posedge w_tick or posedge reset) begin
        if (reset) begin
            r_500ms_count <= 0; 
            r_100ms_count <= 0;
            r_led_500mstoggle <= 0;
            r_led_100mstoggle <= 0;
        end else begin
            // 500ms 토글 로직
            if (r_500ms_count == 500-1) begin
                r_500ms_count <= 0;
                r_led_500mstoggle <= ~r_led_500mstoggle;
            end else begin
                r_500ms_count <= r_500ms_count + 1;
            end 
            
            // 100ms 토글 로직
            if (r_100ms_count == 100-1) begin
                r_100ms_count <= 0;
                r_led_100mstoggle <= ~r_led_100mstoggle;
            end else begin
                r_100ms_count <= r_100ms_count + 1;
            end 
        end
    end

    // --- 최종 출력 할당 ---
    assign led[1] = r_led_100mstoggle;
    assign led[0] = r_led_500mstoggle;
    // 참고: led[15:2]는 현재 사용되지 않으므로 0으로 출력됩니다.

endmodule