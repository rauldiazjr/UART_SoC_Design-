`timescale 1ns / 1ps
// ********************************************************************************
   // DATE:      2/26/14  
   // AUTHOR:    Raul Diaz 
   // EMAIL:     raul.diaz91@live.com
   // MODULE:    hex_to_7seg
   // FILENAME:  hex_to_7seg.v 
   // PROJECT:   Lab 3 
   // Discription: The hex_to_7 segment module controls the 7 segment display on 
   //              the fpga board. This module will recieve a 4bit value and translate
   //              it into its corresponding hex value to be displayed tothe anodes
	//
// ********************************************************************************
module hex_to_7seg(hex, a, b, c, d, e, f, g);

input        [3:0] hex; 
output		  a,b,c,d,e,f,g; 
reg			  a,b,c,d,e,f,g; 

always @(hex) begin
	case(hex)
		4'b0000: {a,b,c,d,e,f,g} = 7'b0000001; // 7-seg: 0
		4'b0001: {a,b,c,d,e,f,g} = 7'b1001111; // 7-seg: 1
		4'b0010: {a,b,c,d,e,f,g} = 7'b0010010; // 7-seg: 2
		4'b0011: {a,b,c,d,e,f,g} = 7'b0000110; // 7-seg: 3
		4'b0100: {a,b,c,d,e,f,g} = 7'b1001100; // 7-seg: 4
		4'b0101: {a,b,c,d,e,f,g} = 7'b0100100; // 7-seg: 5
		4'b0110: {a,b,c,d,e,f,g} = 7'b0100000; // 7-seg: 6
		4'b0111: {a,b,c,d,e,f,g} = 7'b0001111; // 7-seg: 7
		4'b1000: {a,b,c,d,e,f,g} = 7'b0000000; // 7-seg: 8
		4'b1001: {a,b,c,d,e,f,g} = 7'b0001100; // 7-seg: 9
		4'b1010: {a,b,c,d,e,f,g} = 7'b0001000; // 7-seg: A
		4'b1011: {a,b,c,d,e,f,g} = 7'b1100000; // 7-seg: B
		4'b1100: {a,b,c,d,e,f,g} = 7'b0110001; // 7-seg: C
		4'b1101: {a,b,c,d,e,f,g} = 7'b1000010; // 7-seg: D
		4'b1110: {a,b,c,d,e,f,g} = 7'b0110000; // 7-seg: E
		4'b1111: {a,b,c,d,e,f,g} = 7'b0111000; // 7-seg: F
		default: {a,b,c,d,e,f,g} = 7'b1111111; // 7-seg: Blank
	endcase
end


endmodule
