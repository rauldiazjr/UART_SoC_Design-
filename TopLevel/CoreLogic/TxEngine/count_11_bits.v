`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: count_11_bits.v 
====================================================================================
* The count 11 bits module determines the number of transfered bits during an 
* operation. The done flag will signal when 11 bits have succesfully tranfered based
* on the BTU(bit time up) flag from the system. 
* On Reset, count is set to 11 in order to signal a done to the system.
*
**********************************************************************************/
module count_11_bits(Clk, Rst, start, BTU, done);
     input Clk, Rst; 
     input start, BTU;      
     output done;  
     
     reg [3:0] count; 
     assign done = (count == 4'hB); 
     
     /**********************Sequential Block**********************/ 
     always @(posedge Clk, negedge Rst)
          if(!Rst)          count <= 4'hB;         else
          if(!start)        count <= 4'b0;         else
          if(!BTU)          count <= count;         else
                            count <= count +1; 
     
endmodule
