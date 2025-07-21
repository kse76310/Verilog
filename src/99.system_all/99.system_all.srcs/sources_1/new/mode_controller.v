`timescale 1ns / 1ps

module mode_controller(
    input [1:0] sw,     // Switch input to select the mode
    output reg [1:0] mode  // 00: Idle, 01: Microwave, 10: Stopwatch, 11: Air Controller
);

    always @(*) begin
        case (sw)
            2'b01: mode = 2'b01;  // Microwave
            2'b10: mode = 2'b10;  // Stopwatch
            2'b11: mode = 2'b11;  // Air Controller
            default: mode = 2'b00; // Idle
        endcase
    end

endmodule