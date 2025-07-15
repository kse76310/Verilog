`timescale 1ns / 1ps

module beep_generator (
    input clk,
    input reset,

    // FSM으로부터 받는 요청 (1-cycle 펄스)
    input beep_trigger,  // 짧은 비프음 요청
    input alarm_trigger, // 알람 요청 (조리 완료 시)

    // buzzer_driver로 보낼 출력
    output reg buzzer_en
);

    // --- 상수 정의 ---
    localparam BEEP_DURATION   = 10_000_000;  // 100ms
    localparam ALARM_DURATION  = 20_000_000;  // 200ms
    localparam ALARM_REPEATS   = 3;

    // --- FSM 상태 정의 ---
    parameter S_IDLE      = 2'b00;
    parameter S_BEEP      = 2'b01;
    parameter S_ALARM_ON  = 2'b10;
    parameter S_ALARM_OFF = 2'b11;

    // --- 내부 레지스터 ---
    reg [1:0] current_state, next_state;
    reg [25:0] timer_counter; // 200ms 이상을 셀 수 있는 크기
    reg [1:0] alarm_count;   // 알람 반복 횟수 카운트

    // --- FSM 로직 ---

    // 1. State Register: 클럭에 따라 상태 업데이트
    always @(posedge clk or posedge reset) begin
        if (reset) current_state <= S_IDLE;
        else       current_state <= next_state;
    end

    // 2. Next-State Logic: 다음 상태 결정
    always @(*) begin
        next_state = current_state;
        case (current_state)
            S_IDLE: begin
                if (beep_trigger) next_state = S_BEEP;
                else if (alarm_trigger) next_state = S_ALARM_ON;
            end
            S_BEEP: begin
                if (timer_counter >= BEEP_DURATION - 1) next_state = S_IDLE;
            end
            S_ALARM_ON: begin
                // 이 부분을 채워보세요
                if(timer_counter >= ALARM_DURATION - 1) next_state = S_ALARM_OFF;
            end
            S_ALARM_OFF: begin
                // 이 부분을 채워보세요
                if (timer_counter >= ALARM_DURATION - 1) begin
                    // 그 다음, 알람 반복 횟수를 확인합니다.
                    if (alarm_count < ALARM_REPEATS - 1) begin
                        next_state = S_ALARM_ON; // 아직 3번이 안됐으면 다시 켜기
                    end else begin
                        next_state = S_IDLE; // 3번 반복했으면 종료
                    end
                end
            end
        endcase
    end

    // 3. Output Logic: 현재 상태에 따라 출력 결정
    always @(*) begin
        case (current_state)
            S_BEEP, S_ALARM_ON: buzzer_en = 1'b1;
            default:            buzzer_en = 1'b0;
        endcase
    end
    
    // 4. 타이머 및 알람 카운터 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            timer_counter <= 0;
            alarm_count <= 0;
        end else begin
            // 상태가 바뀌면 타이머 리셋
            if (next_state != current_state) begin
                timer_counter <= 0;
            end else begin
                timer_counter <= timer_counter + 1;
            end

            // 알람 카운트 로직
            if (next_state == S_IDLE) begin // IDLE로 돌아갈 때 알람 카운트 초기화
                 alarm_count <= 0;
            end else if (current_state == S_ALARM_OFF && next_state == S_ALARM_ON) begin
                 alarm_count <= alarm_count + 1; // 알람이 한번 끝나고 다시 시작될 때 카운트 증가
            end
        end
    end

endmodule