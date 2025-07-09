`timescale 1ns / 1ps


module my_vending_machine(
    input clk,
    input reset,
    input [3:0] i_btn,
    output reg [14:0]cup,
    output reg [14:0]money
    );

    
   localparam COFFEE_COST = 300; //고정된 상수값은 localparam으로 선언
    reg [14:0] next_money;
    reg [14:0] next_cup;
    reg[1:0] state, next_state;
    parameter IDLE =1'b0 ;
    parameter COFFEE =1'b1 ;

    reg prev_btnL =0;
    reg prev_btnC =0;
    reg prev_btnR =0;
    reg prev_btnD =0;

    wire btnL_pulse = i_btn[0] & ~prev_btnL;
    wire btnC_pulse = i_btn[1] & ~prev_btnC;
    wire btnR_pulse = i_btn[2] & ~prev_btnR;
    wire btnD_pulse = i_btn[3] & ~prev_btnD;


  always@(posedge clk, posedge reset)begin
        if(reset)begin
           prev_btnL <= 0;
           prev_btnC <= 0;
           prev_btnR <= 0;
           prev_btnD <= 0; 
        end
        else begin
           prev_btnL <= i_btn[0];
           prev_btnC <= i_btn[1];
           prev_btnR <= i_btn[2];
           prev_btnD <= i_btn[3]; 
        end
        
        end

        always@(posedge clk, posedge reset)begin
            if(reset) begin
                state <= IDLE;
                cup <= 14'd0;
                money <= 14'd0;
            end
            else begin 
            state <= next_state;
            money <= next_money;
            if (state == COFFEE && btnC_pulse && (money >= COFFEE_COST)) begin
                cup <= {cup[13:0], 1'b1};
            end
        end
        end


      always@(*)begin
  // 기본값 할당 (Latch 방지)
    next_state = state;
    next_money = money;
    next_cup = cup;
 
        case(state)
        IDLE:begin //돈을 넣을 수 있는 상태 , 이다음에 
            if(btnL_pulse)begin
                next_money = (money >= 9900) ? money :(money + 100);
            end
            else if(btnD_pulse)begin
                 next_money = (money >= 9900) ? money :(money + 500);
            end
            else if(btnC_pulse)begin
                next_state = COFFEE;
            end
             else if(btnR_pulse)begin
                next_money = 0;
                next_cup = 14'd0;
             end
        end
        COFFEE:begin
            if(btnC_pulse && (money >= COFFEE_COST ))begin
                next_money = money - COFFEE_COST;
            end
            else if(btnC_pulse && (money < COFFEE_COST ))begin
                next_money = money; 
                next_state = IDLE;
            end
            else if(btnR_pulse)begin
                next_state = IDLE;
                next_money = 0;
                next_cup = 14'd0;
            end
           
        end
        default: begin
            next_state = IDLE;
        end

        endcase

    end
endmodule
