`timescale 1ns / 1ps
/*********************************************************************************
* File: RSFlop.v
*
* The RS Flop is synchronous module with active low reset used to configure the 
* output Q based on 2 input signals. 

***********************************************************************************
* Reset- Set Flop: 

                 R  S  |      Q
               =====================
                 0  0  |      Q(i-1) 
                 0  1  |      1
                 1  0  |      0
                 1  1  |      1 
               ===================== 
               
***********************************************************************************
**********************************************************************************/
module RSFlop(Clk, Rstb, R, S, Q);
   input      Clk, Rstb; 
   input      R, S; 
   output reg Q;
     
/*************Sequential block******************/   
   always @(posedge Clk, negedge Rstb)
      if(Rstb == 1'b0)  Q <= 1'b0; else      
      if(S)             Q <= 1'b1; else
      if(R)             Q <= 1'b0; else
                        Q <= Q; 
                        
endmodule
