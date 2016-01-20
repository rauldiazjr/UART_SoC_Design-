`timescale 1ns / 1ps
/********************************************************************************
 *   Display Controller used to control the output of the 7segment display of 
     the nexys 2 board. This module instantiates 4 modules: 
     led_clk_250Hz: Slows down the frequency of the processor clk from 50Mhz to 
                    250hz.  
                    
     led_controller: Selects which of the 4 anodes to update on the display. 
                     and uses a 2 bit value to identify which of the 4 anodes 
                     are currently active 
     
     ad_mux:         Assigns the active anode its 4 bit hex value. 
     
     hex_to_7seg:    Decodes a 4bit value into a 7 bit translated value used to 
                     interface with the segment display. P
*********************************************************************************/
module display_controller( clk_50Mhz, reset, bytesel_hi, bytesel_lo, d_hi, d_lo, 
									a3, a2, a1, a0, a, b, c, d, e, f, g);
									
									
    input             clk_50Mhz, reset;
    input        [3:0] bytesel_hi, bytesel_lo;
    input        [3:0] d_hi, d_lo;
    output wire        a3, a2, a1, a0, a, b, c, d, e, f, g;

    wire [1:0]  seg_sel;
    wire        clk_250hz;
    wire  [3:0] disp_out;

   //**********************s***********************************
   // Module for led_clk_250Hz
   //*********************************************************     
                            //       clk, reset, clk_out
    led_clk_250Hz     led_clk( clk_50Mhz, reset, clk_250hz );


   //*********************************************************
   // Module for led_controller
   //*********************************************************     
                            // clk,  reset, a3, a2, a1, a0, seg_sel
    led_controller    control( clk_250hz, reset, a3, a2, a1, a0, seg_sel );

   //*********************************************************
   // Module for ad_mux
   //*********************************************************     
                         // seg_sel, bytesel_hi, bytesel_lo, d_hi, d_lo, disp_out
    ad_mux            mux0( seg_sel, bytesel_hi, bytesel_lo, d_hi, d_lo, disp_out );
	 
   //*********************************************************
   // Module for hex_to_7seg
   //*********************************************************
								// hex,    a, b, c, d, e, f, g
	 hex_to_7seg       hex( disp_out, a, b, c, d, e, f, g );
    
endmodule
