`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: RxEngine.v 
====================================================================================
* Description: 
The Recieve Engine is a synchronous communications module capable of recieving 
serial data using an RS232 protocol. It outputs an 8 bit data to an exterior device 
and is capable of producing 4 status signals Rx Ready, Parity Error, Overflow Error
and a Framing Error. 
There are 4 main instantiations involved: Bitcountup.v, Bit_time_counter.v, Recieve_SM,
and the SIPO Shift Register. An 18 bit Baud Count value is also produced based on the 
start signal from the FSM. This signal will determine if the Baud Count is divided 
by 2, in order to shift the trigger mark to the midpoint of a serial transfer. A shift
signal is also produced upon a low start signal from the FSM and a BTU signal to 
determine a shift in the SIPO. 

*********************************************************************************/
module RxEngine(Clk, Rst, Rx_in, parity_en, bit8_en, odd_en, Baud_val, rd_strb,
                Rx_out, Rx_rdy, p_err, ov_err, frm_err  );
                
   input   Clk, Rst; 
   input   Rx_in, parity_en, bit8_en, odd_en, rd_strb; 
   input   [17:0] Baud_val; 
   
   output  Rx_rdy, p_err, ov_err, frm_err; 
   output  [7:0] Rx_out;
   
   wire [17:0] baud_count; 
   wire start, BTU; 
   
/**************************  Combo  Block  **********************************/
   assign baud_count = start ? (Baud_val >> 1) : Baud_val; 
   assign shift = ~start & BTU; 
   
/*************************  Instantiation Block  ****************************/    
   
   /*********************************************
              Bit Count up Module    
   **********************************************/   
   BitCountUp bitcounter(
      .Clk(Clk), 
      .Rst(Rst), 
      .start(doit), 
      .BTU(BTU), 
      .bitCount(4'ha), 
      .done(BCU) );
      
   /*********************************************
                Bit Time Counter Module    
   **********************************************/
   Bit_time_counter bittimecount(
      .Clk(Clk), 
      .Rst(Rst), 
      .start(doit), 
      .baud_count(baud_count), 
      .BTU(BTU) );
   /*********************************************
                Recieve State Machine     
   **********************************************/
   Recieve_StateMachine FSM(
      .Clk(Clk), 
      .Rstb(Rst), 
      .Rx(Rx_in), 
      .BCU(BCU), 
      .BTU(BTU), 
      .start(start), 
      .ld(ld), 
      .doit(doit) );

    /*********************************************
               Serial In Parallel Out Shift Reg    
     **********************************************/   
   Shiftreg_SIPO SIPO(
      .Clk(Clk), 
      .Rst(Rst), 
      .ld(ld), 
      .Rx_in(Rx_in), 
      .shift(shift), 
      .parity_en(parity_en), 
      .bit8_en(bit8_en), 
      .odd_en(odd_en), 
      .rd_srtb(rd_strb), 
      .frm_err(frm_err), 
      .par_err(p_err), 
      .ov_err(ov_err), 
      .Rx_rdy(Rx_rdy), 
      .data_out(Rx_out) );

endmodule
