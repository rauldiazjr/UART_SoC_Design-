`timescale 1ns / 1ps
/**********************************************************************************
====================================================================================
* File: strobe_decode.v
====================================================================================
*
*	The decode module is used to interface with the picoblaze processor's port id and 
*  rd/wr strobes. The decoder is used to select and activate particular modules 
*  used throughout this project. By decoding the port ID, the system can determine 
*  which module is currenty INPUTTING or OUTPUTTING to the picoblaze. 
*
**********************************************************************************/
module strobe_decode(port_id, rd_in, wr_in, rd_out, wr_out);

	input 	  rd_in, wr_in ; 
	input 	  [7:0] port_id; 
	output reg [255:0] rd_out, wr_out; 
  /*********************************************
					 Procedual Combo block    
  **********************************************/		
	always @(*)		begin 
	/* Clear all previous values */ 
		rd_out = 8'b0; 
		wr_out = 8'b0; 
	/* Assign current values */ 
		rd_out[port_id] = rd_in ; 
		wr_out[port_id] = wr_in; 
		end

endmodule
