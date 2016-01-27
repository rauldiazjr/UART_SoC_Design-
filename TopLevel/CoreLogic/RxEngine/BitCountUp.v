`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: BitCountUp.v 
====================================================================================
* The BitCountUp module determines the number of transfered bits during an 
* operation. The done flag will signal when 'bitCount' bits have succesfully tranfered 
* based on the BTU(bit time up) flag from the system. 
* On Reset, count is set to bitCount in order to signal a done to the system.
*
**********************************************************************************/
module BitCountUp(Clk, Rst, start, BTU, bitCount, done);
     input Clk, Rst; 
     input start, BTU; 
     input [3:0] bitCount; 
     output done;  
     
     reg [3:0] count; 
     assign done = (count == bitCount); 
     
     /**********************Sequential Block**********************/ 
     always @(posedge Clk, negedge Rst)
          if(!Rst)          count <= bitCount;     else
          if(!start)        count <= 4'b0;         else
          if(!BTU)          count <= count;        else
                            count <= count +1; 
     
endmodule
