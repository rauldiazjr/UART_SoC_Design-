`timescale 1ns / 1ps
/********************************************************************************

*********************************************************************************/
module ad_mux( seg_sel, ad_hi, ad_lo, d_hi, d_lo, ad_out );
    input       [1:0] seg_sel;
    input       [3:0] ad_hi, ad_lo;
    input       [3:0] d_hi, d_lo;
    output reg  [3:0] ad_out;
    
    always @ (*) begin
      case (seg_sel)
         2'b00:   ad_out = d_lo[3:0];
         2'b01:   ad_out = d_hi[3:0];
         2'b10:   ad_out = ad_lo[3:0];
         2'b11:   ad_out = ad_hi[3:0];
         default: ad_out = 4'b0000;
      endcase
    end

endmodule
