`timescale 1ns / 1ps
/********************************************************************************
 * Filename:    led_clk_250Hz.v
 * Description: This module slows down the frequency of the incoming clock to 250Hz 
 *              The code will "divide" an incoming clock by the counter in
 *              if statement below.
 *
*********************************************************************************/
module led_clk_250Hz( clk, reset, clk_out );
   input    clk, reset;
   output   clk_out;
   reg      clk_out;
   integer  i;
      
   always @ (posedge clk or posedge reset)
      begin
         if (reset == 1'b1) //reset clock
            begin
               i=0;
               clk_out=0;
            end
         else  // theres a clock, increment counter and test
            begin
               i = i + 1;
               //The value of the counter that counts the incoming
               if (i >= 100000)    begin      
                //clock ticks is equal to [(incoming freq/outgoing freq)/2]
                clk_out = ~clk_out;
                i = 0;
                end // if
            end // else
      end // always
	
endmodule 