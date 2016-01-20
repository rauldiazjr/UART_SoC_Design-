`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: Shiftreg_Piso.v 
====================================================================================
* A Parallel IN Serial OUT shift register used to transmit an 11bit data bus from 
* from the system. Active on every rising edge of the Clk or falling edge of a 
* Rst bit, data is cleared on an active low reset. Loads new data on a ld assertion
* and on a shift enable signal, data is shifted to the right as the serial in signal 
* is shifted into the MSB. 
*
**********************************************************************************/
module Shiftreg_PISO(Clk, Rst, ld, sh_en, data_in, ser_in, ser_out );
     input Clk, Rst; 
     input ld, sh_en, ser_in; 
     input [10:0] data_in ; 
     output ser_out; 
     
     reg [10:0] transmit_data;
     
/*************Continous assignment******************/
     assign ser_out = transmit_data[0]; 
     
/*************Sequential block******************/     
     always @(posedge Clk, negedge Rst)
          if(!Rst)  transmit_data <= 10'b0;   else
          if(ld)    transmit_data <= data_in; else 
          if(sh_en) transmit_data <= { ser_in, transmit_data[10:1] } ; 
     
endmodule
