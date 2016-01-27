`timescale 1ns / 1ps
/**********************************************************************************
* File: AISO.v
* The AISO module was taken from a paper on Asynchronous & Synchronous Reset
  Design Techniques by Clifford E. Cummings, Don Mills, and Steve Golson. 
  This AISO has small modifications to the original paper in order to meet 
  specifications presented in the outline of this project. 
  
* Async IN Sync OUT. Used to synchronize a hardware reset for the system. 
* This module uses 2 flip-flop registers to remove metastability which may occur 
* if the setup time for the first ff is violated from a hardware mechanical debounce.
* Ultimitely this module will synchronize the system with an active low reset. 
*      i.e If a mech. reset is asserted, the output will traverse a 0 through ff1, and
*      on the next clk, output a 0. 
*      else the output remains 0. 
**********************************************************************************/
module ASyncIn_SyncOut(Clk, async_rst, sync_rst);
   input       Clk, async_rst; 
   output reg  sync_rst; 
   reg         ff1; 
   
/*************Conditional block******************/
   always @(posedge Clk, negedge async_rst)        
      if(async_rst == 1'b0) ff1 <= 1'b1;     
      else                  ff1 <= 1'b0; 

   always @(posedge Clk)
      sync_rst <= ff1; 
      
endmodule
