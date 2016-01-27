`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: Shiftreg_SIPO.v 
====================================================================================
Description: 
The sychronous 'Serial in Parallel out' Shift Register implemented in this design 
is used for the RX engine. This module also provides nessesary status flags to the
system for continous processing. On a shift signal from the system the SIPO will shift 
new bits to the right. On a load & RxReady signal, the SIPO will update the data out 
register with the recieved bits stored in the temp register. 

This SIPO module is constructed for the use of an RS232 protocol and provides error 
signals upon received data vs computed data such as a Framming Error, Parity Error 
and Overflow error. This module also provides logic for an RxReady signal which 
determines if the RX engine is ready too recieve a sequence of information. 
Upon a load signal, the last bit(stop bit) is excluded from the data_out register. 
Depending on the UART configuration, an optional 8th bit is loaded along with all 
other recieved bits. 
**********************************************************************************/
module Shiftreg_SIPO(Clk, Rst, ld, Rx_in, shift, parity_en, bit8_en, odd_en, rd_srtb, 
                        frm_err, par_err, ov_err, Rx_rdy, data_out);
                        
   input  Clk, Rst; 
   input  ld, Rx_in, shift, parity_en, bit8_en, odd_en, rd_srtb; 
   
   output  frm_err, par_err, ov_err, Rx_rdy;
   output reg [7:0] data_out;

   reg [8:0] temp; 
   wire bit7, recived_parity, computed_parity ; 
   wire sP_err, sOv_err, sRx_rdy, sFrm_err, bit7xortemp; 
   
/*************Combinational Block******************/     
   /* Bit 7 assignment */ 
   assign bit7 = bit8_en ?  temp[7]:0 ;    
   /*xor on 7 bits of shifted value and bit7 */ 
   assign bit7xortemp = temp[6:0] ^ bit7; 
   
   /* Compute parity from recived data*/ 
   assign computed_parity = ~odd_en ? bit7xortemp : ~bit7xortemp ;  
   /* Locate recived parity */ 
   assign recived_parity = bit8_en ? temp[8] : temp[7];    
   
   /* Set signal for p_err register & ov_err register*/ 
   assign sP_err = ld & parity_en & ~Rx_rdy & (computed_parity ^ recived_parity);   
   assign sOv_err = Rx_rdy & ld;    
   
   /* set signal for Rx_rdy register & frm_err register*/ 
   assign sRx_rdy = ~Rx_rdy & ld; 
   assign sFrm_err = ~Rx_rdy & ld  & sP_err & temp[8]; //Stopbit && parity error    
/*************Instantiation Block******************/ 
   RSFlop   perror(
               .Clk(Clk), 
               .Rstb(Rst), 
               .R(rd_srtb), 
               .S(sP_err), 
               .Q(par_err)) ;
               
   RSFlop   overror(
               .Clk(Clk), 
               .Rstb(Rst), 
               .R(rd_srtb), 
               .S(sOv_err), 
               .Q(ov_err)) ;
   
   RSFlop   frmerror(
               .Clk(Clk), 
               .Rstb(Rst), 
               .R(rd_srtb), 
               .S(sFrm_err), 
               .Q(frm_err)) ;
   
   RSFlop   rxRdy(
               .Clk(Clk), 
               .Rstb(Rst), 
               .R(rd_srtb), 
               .S(sRx_rdy), 
               .Q(Rx_rdy)) ;            
               
/*************Sequential block******************/  
   always @(posedge Clk, negedge Rst) begin       
      if(!Rst) {temp, data_out} <= 17'b0;                   else
      if(shift) temp <= {Rx_in, temp[8:1]};                 else
      if(ld && ~Rx_rdy)   data_out <= { bit7, temp[6:0] };          
   end

endmodule
