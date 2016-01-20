`timescale 1ns / 1ps


module LDRG_8bit(Clk, Rstb, D, en, Q);
     input Clk, Rstb; 
     input en; 
     input      [7:0] D; 
     output reg [7:0] Q; 

	always @(posedge Clk, negedge Rstb)
		if(Rstb == 1'b0)  Q <= 8'b0; else
		if(en)		   Q <= D;    else
					   Q <= Q; 
		

endmodule
