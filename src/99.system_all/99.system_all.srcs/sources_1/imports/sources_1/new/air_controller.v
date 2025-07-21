`timescale 1ns / 1ps

module air_controller(
    input clk, reset,
    input [7:0] sw,
    // Debounced button inputs
    input w_btnC_clean, w_btnU_clean, w_btnD_clean, w_btnL_clean,
    
    // Sensor inputs
    input [15:0] distance_cm,
    input [39:0] dht11_out_data,
    
    // Control outputs
    output reg [6:0] duty,
    output reg buzzer_enable,
    output reg [3:0] o_bcd_d1000,
    output reg [3:0] o_bcd_d100,
    output reg [3:0] o_bcd_d10,
    output reg [3:0] o_bcd_d1
);

    // --- Parameters for Modes ---
    parameter AUTO_MODE = 1'b0;
    parameter SETTING_MODE = 1'b1;

    // --- Wires ---
    // Button press event (rising edge) wires
    wire w_btnC_posedge, w_btnU_posedge, w_btnD_posedge, w_btnL_posedge;

    // --- Registers ---
    // State and control registers
    reg mode_reg;           // Current operation mode
    reg [7:0] set_temp;     // Target temperature in setting mode
    reg fan_on;             // Fan on/off state in setting mode

    // Registers for button edge detection
    reg r_btnC_clean_d1, r_btnU_clean_d1, r_btnD_clean_d1, r_btnL_clean_d1;
    
    // --- Data Extraction ---
    wire [7:0] current_temp = dht11_out_data[23:16];
    wire [7:0] current_humi = dht11_out_data[39:32];

    // --- Logic ---
    always @(*) begin
        if (mode_reg == AUTO_MODE) begin
            o_bcd_d1000 = current_temp / 10;
            o_bcd_d100  = current_temp % 10;
            o_bcd_d10   = current_humi / 10;
            o_bcd_d1    = current_humi % 10;
        end else begin // SETTING_MODE
            o_bcd_d1000 = current_temp / 10;
            o_bcd_d100  = current_temp % 10;
            o_bcd_d10   = set_temp / 10;
            o_bcd_d1    = set_temp % 10;
        end
    end

    // Button press event generation (rising edge detection)
    assign w_btnC_posedge = w_btnC_clean & ~r_btnC_clean_d1;
    assign w_btnU_posedge = w_btnU_clean & ~r_btnU_clean_d1;
    assign w_btnD_posedge = w_btnD_clean & ~r_btnD_clean_d1;
    assign w_btnL_posedge = w_btnL_clean & ~r_btnL_clean_d1;

    // Sequential logic for state updates
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mode_reg <= AUTO_MODE;
            set_temp <= current_temp; // Default set temperature
            fan_on <= 1'b0;
            // Reset button delay registers
            r_btnC_clean_d1 <= 0;
            r_btnU_clean_d1 <= 0;
            r_btnD_clean_d1 <= 0;
            r_btnL_clean_d1 <= 0;
        end else begin
            // Update button delay registers
            r_btnC_clean_d1 <= w_btnC_clean;
            r_btnU_clean_d1 <= w_btnU_clean;
            r_btnD_clean_d1 <= w_btnD_clean;
            r_btnL_clean_d1 <= w_btnL_clean;

            // Mode switching
            if (w_btnL_posedge) begin
                mode_reg <= ~mode_reg;
                // When entering setting mode, initialize set_temp with current temp
                if (mode_reg == AUTO_MODE) begin
                    fan_on <= 1'b0; // Turn off fan when switching modes
                end
            end

            // Logic for SETTING_MODE
            if (mode_reg == SETTING_MODE) begin
                set_temp <= current_temp;
                if (w_btnU_posedge) set_temp <= set_temp + 1;
                if (w_btnD_posedge) set_temp <= set_temp - 1;
                if (w_btnC_posedge) fan_on <= ~fan_on;
            end
        end
    end

    // Combinational logic for fan/buzzer control
    always @(*) begin
        // Ultrasonic sensor has highest priority
        if (distance_cm < 5) begin
            duty = 0; // Stop FAN
            buzzer_enable = 1'b1; // Enable buzzer
        end else begin
            buzzer_enable = 1'b0; // Disable buzzer

            // Control logic based on mode
            case (mode_reg)
                AUTO_MODE: begin
                    // Original automatic temperature control logic
                    if (current_temp > sw[7:0]) begin
                        duty = 7'd127; // Max speed
                    end else if (current_temp < sw[7:0]) begin
                        duty = 7'd0; // Min speed (FAN off)
                    end else begin
                        duty = 7'd60; // Moderate speed
                    end
                end
                
                SETTING_MODE: begin
                    if (!fan_on) begin
                        duty = 0; // Fan is off
                    end else begin
                        // Fan speed control based on comparison
                        if (current_temp > set_temp) begin
                            duty = 7'd127; // Current is hotter -> Fast fan
                        end else if (current_temp < set_temp) begin
                            duty = 7'd50;  // Current is cooler -> Slow fan
                        end else begin
                            duty = 7'd80;  // Target reached -> Medium fan
                        end
                    end
                end
            endcase
        end
    end
endmodule