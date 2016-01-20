`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: Bit_time_counter.v 
====================================================================================
* The Bit time counter module generates a single clock pulse to signal the end of 
* a bit time transfer. A bit time for the system is determined by the baud_count 
* wire, an 18 bit wide bus. The following table determines signal handling logic 
*
**********************************************************************************/
module Bit_time_counter(Clk, Rst, start, baud_count, BTU);
     input Clk, Rst; 
     input start; 
     input [17:0] baud_count; 
     output BTU; 
     
     reg [17:0] count; 
     assign BTU = (count == (baud_count - 1)); 
     
     /**********************Sequential Block**********************/ 
     always @(posedge Clk, negedge Rst)
          if(!Rst)          count <= 18'b0;         else
          if(start & !BTU)  count <= count + 1;     else
                            count <= 18'b0; 
     
endmodule
