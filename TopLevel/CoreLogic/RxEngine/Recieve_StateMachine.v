`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: Recieve_StateMachine.v 
====================================================================================
Description: 
This sychronous State Machine provides the Recieve Engine the nessary signals 
for recieving and processing particular bits based on the current state of 
the RS232 protocol transfer. 

There are 4 states exercised at all times during execution: 
The Idle state will wait for the start bit during an RS232 protocol, it ensures
grounded signals from all counters used in the RX Engine. Upon a low signal from 
the Rx data input, the State will transition to the Start state for further 
processing. 

At the Start State, the system is processing the start bit from an exterior device 
and will set the trigger for shifting and storing values at the middle of a bit 
transfer from the percpective of the exterior device. (i.e sampling is performed 
at the middle of a bit transfer to ensure proper processing of a bit, this will 
reduce timing errors due too baudrates of other devices). The Start state also
begins all counters used in the RX engine. When a BTU signal is recieved, the system 
will transistion into the Get state. 

The Get state provides the nessasary signals used to store the incomming bits in the 
RX engine. It will transition into the load state on a high BTU signal. 

At the Load state, the system is checking for the BCU signal which signals the maximum 
allowable bits for in transfer has occured. At which point, the FSM will provide a 
load signal to the system to allow access to the recieved data.The state will then 
transistion into the Idle state and wait for the next start bit.However if a low 
BCU signal is read, the state will reseed to the get state for further processing.  
**********************************************************************************/
module Recieve_StateMachine(Clk, Rstb, Rx, BCU, BTU, 
									 start, ld, doit);
	input Clk, Rstb; 
	input Rx, BCU, BTU; 
	
	output reg start, ld, doit; 
	
	reg [1:0] state_reg, state_next; 
	reg nxt_start, nxt_ld, nxt_doit; 
	
	/* Symbolic State Declorations */ 
	localparam [1:0] 
		idle 		= 2'b00, 
		startbit = 2'b01, 
		get 		= 2'b10, 
		load 		= 2'b11; 
		
/*****************  Sequential block  **********************/	
	always @(posedge Clk, negedge Rstb)
		if(!Rstb)	begin 
			state_reg <= idle;
			start     <= 1'b0; 
			ld	       <= 1'b0; 
			doit      <= 1'b0; 
		end
		else			begin 
			state_reg <= state_next; 
			start 	 <= nxt_start ;
			ld			 <= nxt_ld	 ;
			doit		 <= nxt_doit ; 			
		end
		
/*************Combo & Next State Logic block******************/	

/*******************  FSM Content  *****************************
Idle 		 : Waits for start bit 
Startbit  : Sets trigger point, and begins counters to system
Get		 : Recieves bits from exterior device
Load	    : Allows access system to read recieved data	
****************************************************************/
	
	always @(*)	begin
	/* Default Assignments */ 	
		state_next = state_reg;
		nxt_start = start ;
		nxt_ld	 = ld 	; 
		nxt_doit  = doit ; 		  
		
		case(state_reg)
			idle : 	
				begin					
					if(!Rx)	begin 
						state_next = startbit; 	
						nxt_start   = 1'b1;
						nxt_ld 	   = 1'b0; 
						nxt_doit 	= 1'b1;
					end 
					else	begin 
						state_next = idle; 
						nxt_start   = 1'b0;
						nxt_ld 	   = 1'b0; 
						nxt_doit 	= 1'b0;
					end
				end	
				
			startbit : 
				begin
					
					if(~Rx && BTU)	begin 
						state_next = get; 
						nxt_start   = 1'b0;
						nxt_ld 	   = 1'b0; 
						nxt_doit 	= 1'b1;
					end 
					else
					if(Rx)	begin 
						state_next = idle; 
						nxt_start   = 1'b0;
						nxt_ld 	   = 1'b0; 
						nxt_doit 	= 1'b0;
					end 
				end
				
			get: 
				begin					
					if(BTU) begin 
						state_next = load;
						nxt_start   = 1'b0;					 
						nxt_doit 	= 1'b1;
						nxt_ld 	   = 1'b0;
					end 
				end
				
			load: 
				begin
					if(BCU) begin 
						state_next = idle; 
						nxt_start   = 1'b0;
						nxt_ld 	   = 1'b1; 
						nxt_doit 	= 1'b0;
						
					end 
					else	begin 
						state_next = get; 
						nxt_start   = 1'b0;
						nxt_ld 	   = 1'b0; 
						nxt_doit 	= 1'b1;
					end
				end
				
			default: 
				begin 
					state_next = idle; 
					nxt_start   = 1'b0;
					nxt_ld 	   = 1'b0; 
					nxt_doit 	= 1'b0;
				end 					
		endcase
		/************  END FSM  ****************/
	end
			
endmodule
