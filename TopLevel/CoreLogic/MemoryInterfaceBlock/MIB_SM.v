`timescale 1ns / 1ps
/*********************************************************************************
## Engineer: Raul Diaz
## Course:   CECS460
## Semester: Sp 15
## Modified: 5/10/15
====================================================================================
* File: MIB_SM.v 
====================================================================================
*  The MIB Finite State Machine is an essential component to MIB. It controls the Chip
*  Select, Read, and Write enable strobes used to activate the micron memory chip. 
*  Upon reset, this FSM remains in idle waiting for rdstrobe[18] or wrstrobe[19] from 
*  the system. Based on received strobe, the FSM goes into an uninterrupted 6 state 
*  transition changing on each rising edge of the system clock.  Details on 
*  communication can be found in the Micron Memory Datasheet. 

*********************************************************************************/
module MIB_SM(Clk, Rstb, do_rd, do_wr, cs, rd_mem, wr_mem, ld);
	input      Clk, Rstb; 
	input      do_rd, do_wr; 
	output reg cs, rd_mem, wr_mem, ld; 
	
	reg ns_cs, ns_rd, ns_wr, ns_ld; 
	reg [3:0] state_reg, state_next; 
	
	/* Symbolic State Declorations */ 
	localparam [3:0] 
		idle 	= 4'h0,  
		wr_1		= 4'h1,   rd_1		= 4'h7, 
		wr_2 	= 4'h2,   rd_2 	= 4'h8, 
		wr_3 	= 4'h3,   rd_3 	= 4'h9, 
		wr_4		= 4'h4,   rd_4		= 4'hA, 
		wr_5		= 4'h5,   rd_5		= 4'hB, 
		wr_6		= 4'h6,   rd_6		= 4'hC; 		
		
/*****************  Sequential block  **********************/		
	always @(posedge Clk, negedge Rstb) 
		if(!Rstb) begin 
			state_reg  <= idle;
			{cs, rd_mem, wr_mem, ld} <= 4'b1110;		
		end		
          else		 begin 
			state_reg <= state_next; 
			{cs, rd_mem, wr_mem, ld} <= {ns_cs, ns_rd, ns_wr, ns_ld};
		end
		
/*************Combo & Next State Logic block******************/			
	always @(*) begin 
		/* Default Assignments */ 
		state_next = state_reg;
		{ns_cs, ns_rd, ns_wr, ns_ld} = 4'b1110;
		
		case(state_reg) 
			idle: 
			begin 
				if(do_rd)	
					{state_next, ns_cs} = {rd_1, 1'b0}; /* Enable Chip Sel */ 
				else
				if(do_wr)
					{state_next, ns_cs} = {wr_1, 1'b0}; /* Enable Chip Sel */ 
				
				else
					state_next = idle ;
			end
/************* Write Cycle ******************/					
			wr_1: 
			begin 
				state_next = wr_2; 
				
				/* Enable Chip Sel & Enable Memory Write */ 
				{ns_cs, ns_wr} = 2'b0;	
			end		
			wr_2 : 
			begin 
				state_next = wr_3; 
				
				/* Enable Chip Sel & Enable Memory Write */ 
				{ns_cs, ns_wr} = 2'b0;
			end		
			wr_3 : 
			begin 
				state_next = wr_4; 
				
				/* Enable Chip Sel & Enable Memory Write */ 
				{ns_cs, ns_wr} = 2'b0;
			end		
			wr_4: 
			begin 
				state_next = wr_5; 
				
				/* Enable Chip Sel & Enable Memory Write */ 
				{ns_cs, ns_wr} = 2'b0;
			end		
			wr_5: 
			begin 
				state_next = wr_6; 
				
				/* Disable Memory Write */ 						
				{ns_cs, ns_wr} = 2'b01;
			end		
			wr_6: state_next = idle;
			
/************* Read Cycle ******************/							
			rd_1: 
			begin 
				state_next = rd_2; 						
				/* Enable Chip Sel & Enable Memory Read */ 
				{ns_cs, ns_rd} = 2'b0;
			end		
			rd_2 : 
			begin 
				state_next = rd_3; 						
				/* Enable Chip Sel & Enable Memory Read */ 
				{ns_cs, ns_rd} = 2'b0;
			end		
			rd_3: 
			begin 
				state_next = rd_4; 						
				/* Enable Chip Sel & Enable Memory Read */ 
				{ns_cs, ns_rd} = 2'b0;
			end 		
			rd_4: 
			begin 
				state_next = rd_5; 						
				/* Enable Chip Sel & Enable Memory Read */ 
				{ns_cs, ns_rd, ns_ld} = 3'b001;
			end		
			rd_5: 
			begin 
				state_next = rd_6; 						
				/* Disable Read Write */ 
				{ns_cs, ns_rd} = 2'b01;
			end	
					
			rd_6: state_next = idle;					
		endcase
	end
endmodule
