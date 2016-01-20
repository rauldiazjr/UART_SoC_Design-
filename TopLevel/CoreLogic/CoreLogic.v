`timescale 1ns / 1ps
/*********************************************************************************
## Engineer: Raul Diaz
## Course:   CECS460
## Semester: Sp 15
## Modified: 5/10/15
====================================================================================
* File: CoreLogic.v 
====================================================================================
*    The Core cell contains the logic flow of the SoC. By instantiating the embedded 
* Picoblaze processer, UART, and the Memory Interface block, the Core is capable 
* of providing system communication to an exterior device.  
*    A 4:1 selection case statement multiplexes the data going into the PicoBlaze 
* processor. The read strobes set within the decoder module determine the selection 
* of the multiplexer, which are set by software logic flow within the PicoBlaze. 
* The mux provides the PicoBlaze the option of reading received data from the UART, 
* the status of the UART, the data read from the embedded micron memory or the 
* status of the MIB module (Ready Flag). 

*********************************************************************************/
module CoreLogic(Clk, Rst, baud_sel, parity_en, odd_en, bit8_en, Rx_in,
					 Tx_data, a3, a2, a1, a0,
					 a, b, c, d, e, f, g, flagreg,	
					 data_from_mem, 
					 data_to_mem, addr_to_mem, 
					 cs, rd_mem, wr_mem, adv_mib, cre_mib, upperbyte_en, 
                          lowbyte_en
					 );
					 
       input  Clk, Rst; 
       input  parity_en, odd_en, bit8_en, Rx_in; 
       input  [3:0] baud_sel;      
     
       input  [15:0] data_from_mem;
       output [15:0] data_to_mem;
       output [22:0] addr_to_mem;  	
       
       output cs, rd_mem, wr_mem, adv_mib, cre_mib, upperbyte_en, lowbyte_en; 	
       
       
       output          Tx_data;
       output          a3, a2, a1, a0;
       output          a, b, c, d, e, f, g;	 
       output reg [2:0]flagreg; 
       
       wire   p_err, ov_err, frm_err;	   	  
       wire   Tx_rdy, wr_st, Rx_rdy, sRst, flag;
       wire   [7:0]        port_ID, port_out_data, status, Rx_out;	
       wire   [7:0]        data_to_pb; 
       wire   [17:0]       baud_val;
       wire   [255:0]      wr_decode, rd_decode;
       wire   [7:0]        MIB_status;        
       reg    [7:0]	      port_in_data;
       reg    [7:0]        rxdata, txdata;
	  
	assign   status = {1'b0, frm_err,ov_err, p_err, 2'b0, Tx_rdy, Rx_rdy };		
	assign   flag = frm_err | ov_err | p_err;	  
     
   /*********************************************
	Procedrual Combo block    
   **********************************************/ 

	always  @(*) begin 	
          /*********************************************
               4:1 Mux Input to PicoBlaze Data Port  
          **********************************************/ 		
	  casex({rd_decode[20], rd_decode[17], rd_decode[16], rd_decode[1], rd_decode[0]})
			5'bxxxx1: 	port_in_data = status;
			5'bxxx1x: 	port_in_data = Rx_out;
			5'bxx1xx: 	port_in_data = data_to_pb; 
			5'bx1xxx: 	port_in_data = data_to_pb; 
			5'b1xxxx: 	port_in_data = MIB_status; 
			default: port_in_data = port_in_data; 
	  endcase	
	end		

	/*********************************************
                  Sequential block    
     **********************************************/ 
	always @(posedge Clk, negedge sRst) begin 
		if(!sRst)	begin
		   {txdata,rxdata,flagreg}<= 19'b0; 
              
		end
		/********************************
             Rx buffer register 
          ********************************/ 
		else
		if(rd_decode[1]) 	rxdata <= Rx_out;		
		/********************************
             Tx buffer register 
          ********************************/ 
		else
		if(Tx_rdy && wr_decode[1])		txdata <= port_out_data; 		
		/********************************
             Flag buffer register 
          ********************************/ 
		else
		if(flag)		
               flagreg <= {frm_err,ov_err,p_err};

		
	end
	
     //*********************************************************
     // Memory Interface Block
     //*********************************************************       
       Memory_Interface_Block  MIB(
          .clk(Clk), 
          .rst(sRst), 
          .wr_strb(wr_decode), 
          .rd_strb(rd_decode), 
          .datain(port_out_data), 
          .data_from_mem(data_from_mem), 
          .data_to_mem(data_to_mem),			
          .addr_to_mem(addr_to_mem),  			
          .status(MIB_status),
          .CE_(cs),						 	
          .OE_(rd_mem), 
          .WE_(wr_mem),
          .ADV_(adv_mib), 
          .CRE(cre_mib), 
          .UB_(upperbyte_en), 
          .LB_(lowbyte_en),
          .dataout(data_to_pb)
     );	
	
   //*********************************************************
   // Recieve Engine 
   //********************************************************* 
	RxEngine RX(
		.Clk(Clk), 
		.Rst(sRst), 
		.Rx_in(Rx_in), 
		.parity_en(parity_en), 
		.bit8_en(bit8_en), 
		.odd_en(odd_en), 
		.Baud_val(baud_val), 
		.rd_strb(rd_decode[0]),
		.Rx_out(Rx_out), 
		.Rx_rdy(Rx_rdy), 
		.p_err(p_err), 
		.ov_err(ov_err), 
		.frm_err(frm_err)
	);	
     
   //*********************************************************
   // Transmit Engine 
   //*********************************************************         	
    TxEngine TX(
		 .Clk(Clk), 
		 .Rst(sRst), 
		 .data_in(port_out_data), 
		 .tx_start(wr_decode[1]), 
		 .parity_en(parity_en), 
		 .bit8_en(bit8_en), 
		 .odd_en(odd_en), 
		 .Baud_val(baud_val), 
		 .tx_out(Tx_data), 
		 .tx_rdy(Tx_rdy)
	 );   
      
   //*********************************************************
   // Baudrate value Decoder
   //*********************************************************             
    Baud_val_Decoder br_decode(
		 //.Clk(Clk), 
		 //.Rst(sRst), 
		 .Baudsel(baud_sel), 
		 .Baud_val(baud_val) 
	);    
     
     //*********************************************************
     // Decode Block Module 
     //*********************************************************             
     strobe_decode decode(
		  .port_id(port_ID), 
		  .rd_in(rd_st), 
		  .wr_in(wr_st), 
		  .rd_out(rd_decode), 
		  .wr_out(wr_decode) 
	  );     
     //*********************************************************
     // Asynchronous In Synchronous Out Module  
     //*********************************************************            
	ASyncIn_SyncOut aiso(
		  .Clk(Clk), 
	     .async_rst(Rst), 
		  .sync_rst(sRst)
	);
     //*********************************************************
     // PicoBlaze Processor 
     //*********************************************************       	
	embedded_kcpsm3 ROM(
		  .port_id(port_ID),
		  .write_strobe(wr_st),
		  .read_strobe(rd_st),
		  .out_port(port_out_data),
		  .in_port(port_in_data),
		  .interrupt(1'b0),
		  .interrupt_ack( ),
		  .reset(~sRst),
		  .clk(Clk)
	);
	
	//*********************************************************
     // Display Controller Module 
     //*********************************************************       
     display_controller  disp_cont( 
		  .clk_50Mhz(Clk), 
		  .reset(~sRst), 
		  .bytesel_hi(txdata[7:4]), 
		  .bytesel_lo(txdata[3:0]), 
		  .d_hi(rxdata[7:4]), 
		  .d_lo(rxdata[3:0]), 
		  .a3(a3), .a2(a2), .a1(a1), .a0(a0), 
		  .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g)
		);	  
endmodule
