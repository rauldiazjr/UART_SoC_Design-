`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: Baud_val_Decoder.v 
====================================================================================
	The Baudrae Value Decoder module will determine the magnitude of the count value 
used throughout the transmit engine. A 4 bit baude select value is recieved from 
the system and used to select its corresponding Count value as shown in the table
below. The baud value is an 18 bit number and is set one time only on reset. 

************************************************************************************
							 Sel 	BR	           BT     # CLKS
							===================================
							 0	   300	     3.33E-03	166667
							 1		600	     1.67E-03	83333
							 2		1200	     8.33E-04	41667
							 3		2400	     4.17E-04	20833
							 4		4800	     2.08E-04	10417
							 5		9600	     1.04E-04	5208
							 6		19200		  5.21E-05	2604
							 7		38400		  2.60E-05	1302
							 8		76800		  1.30E-05	651
							 9		153600	  6.51E-06	326
							 10	307200	  3.26E-06	163
							 11	614400	  1.63E-06	81
							 12	1228800	  8.14E-07	41
			 
***********************************************************************************/
module Baud_val_Decoder(Baudsel, Baud_val);
  //input 		 Clk, Rst; 
  input 		 [3:0] Baudsel; 
  output reg [17:0] Baud_val; 
  /*********************************************
				 Decode Sequential block    
  **********************************************/ 
  always @(*)
     
          case(Baudsel)  
               0:  Baud_val = 166667;
               1:  Baud_val = 83333;
               2:  Baud_val = 41667;
               3:  Baud_val = 20833;
               4:  Baud_val = 10417;
               5:  Baud_val = 5208;
               6:  Baud_val = 2604;
               7:  Baud_val = 1302;
               8:  Baud_val = 868;
               9:  Baud_val = 434;
               10: Baud_val = 217;
               11: Baud_val = 109;
               12: Baud_val = 54;
               default: Baud_val = 166667;
          endcase           
endmodule
