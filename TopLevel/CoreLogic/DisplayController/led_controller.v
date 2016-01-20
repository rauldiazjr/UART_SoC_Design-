`timescale 1ns / 1ps
/********************************************************************************
 * led_controller.v 
 * Description: The led controller module will traverse through each anode on 
                every clock. Using state machine logic, each state is assigned the 
                to the next state using a combinational block. The seg_sel is used
                to identify which of the 4 anodes are selected. 
*********************************************************************************/
module led_controller( clk, reset, a3, a2, a1, a0, seg_sel );
    input            clk, reset;
    output reg       a3, a2, a1, a0;
    output reg [1:0] seg_sel;
    
    reg [1:0] PS, NS; 
    
   //*********************************************************
   // Next State Combinational Logic
   //*********************************************************   
    always @ (PS) begin
        case (PS)
            2'b00:   NS = 2'b01;
            2'b01:   NS = 2'b10;
            2'b10:   NS = 2'b11;
            2'b11:   NS = 2'b00;
            default: NS = 2'b00;
        endcase
    end
   //*********************************************************
   // State Register Logic
   //*********************************************************
   always @ (posedge clk or posedge reset)
      begin
         if (reset==1'b1)
            begin
               PS = 2'b00;
            end
         else
            begin
               PS = NS;
            end
      end
   //*********************************************************
   // Output Combinational Logic	
   //*********************************************************
   always @ (PS) begin
      case (PS)
         2'b00  : {a3,a2,a1,a0,seg_sel} = 6'b1110_00;
         2'b01  : {a3,a2,a1,a0,seg_sel} = 6'b1101_01;
         2'b10  : {a3,a2,a1,a0,seg_sel} = 6'b1011_10;
         2'b11  : {a3,a2,a1,a0,seg_sel} = 6'b0111_11;
         default: {a3,a2,a1,a0,seg_sel} = 6'b1111_00;
      endcase
   end  
endmodule
