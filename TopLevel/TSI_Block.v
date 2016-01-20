`timescale 1ns / 1ps
/*********************************************************************************
## Engineer: Raul Diaz
## Course:   CECS460
## Semester: Sp 15
## Modified: 5/10/15
====================================================================================
* File: TSI_Block.v 
====================================================================================
*    The technology specific instance block allows for a real world application to be
*  applied to the SoC. By instantiating the I/O buffers provided by the Spartan 3E HDL
*  library, the TSI ensures a synchronized design to any exterior application. The TSI
*  also adds portability by providing flexible electrical to specification to the 
*  cores I/O ports. This can be done in the systems constrains file. 
*********************************************************************************/
module TSI_Block(
		  
	/* CORE Portlist */ 
	  input  Sys_Clk, Sys_Rst, Tx_data,	
	  input  cs, rd_mem, wr_mem, adv_mib, cre_mib, upperbyte_en, lowbyte_en,
	  input  [15:0] data_to_mem,	
       input  [22:0] addr_to_mem, 
	  input  [2:0] UART_error,
	  input  [3:0] anodes,
	  input  [6:0] cathodes,	
	  
 	  output  Rx_in, 	  	   
	  output  [15:0] data_from_mem,
	  output  [2:0] UART_Config,	  
       output  [3:0] baud_sel,        	  	 
	  
	  /* TSI Buffers */ 
	  output Clk_buf, Rst_buf,
	  output Tx_buf,
	  output	CE_,OE_, WE_, ADV_, CRE, UB_, LB_,
	  output  [22:0]Addr_buf,
	  output  [2:0] UART_error_buf,
	  output  [3:0] anodes_buf,
	  output  [6:0] cathodes_buf,
	  output  OCLKMEM ,
	  input  Rx_buf, 
	  input  [2:0] UART_Confg_buf,
	  input  [3:0] baud_sel_buf,
	  input  CLKMEM,
	  inout  [15:0] DQ
	 );

/*################ CLOCK BUFFER ########################### */

	IBUFG BUFG_CLK (
	    .O(Clk_buf), 		// 1-bit output: Clock buffer output
	    .I(Sys_Clk) 		// 1-bit input: Clock buffer input
	);


/*################ INPUT Buffers ########################### */	
	IBUFG 
          /* Reset Handler */
		IBUFG_RST (
               .I(Sys_Rst),	// Buffer input (connect directly to top-level port)
               .O(Rst_buf)	// Buffer output
		),
			
          /* Recieve RX Handler */
	     IBUFG_Rx (
               .I(Rx_buf),								
               .O(Rx_in)								
		);
		/* UART CONFIG Handler */
	IBUF	IBUF_UARTCONFIG [6:0] (
               .I({UART_Confg_buf,baud_sel_buf}),							
               .O({UART_Config, baud_sel})								
		);
					
/*################ OUTPUT Buffers ########################### */ 
	
		/* Address Handler */
	OBUF OBUF_ADDR[22:0]  (
		.O(Addr_buf[22:0]),	   // Buffer output (connect directly to top-level port)
		.I(addr_to_mem[22:0])  // Buffer input
		),
		/* Anodes/Cathodes Handler */
		OBUF_disp[10:0] (
			.O({anodes_buf, cathodes_buf}),
			.I({anodes, cathodes})	
		),			
		/* UART ERROR Handler */
		OBUF_UARTErr[2:0] (
			.O(UART_error_buf[2:0]),
			.I(UART_error[2:0])	
		),			
		/* Memory Control Handler */
		OBUF_MemCNTRL[6:0] (
			.O({CE_,OE_, WE_, ADV_, CRE, UB_, LB_ }),
			.I({cs, rd_mem, wr_mem, adv_mib, cre_mib, upperbyte_en, lowbyte_en})
		),	
		/* Tx Handler */
		OBUF_TX (
			.O(Tx_buf),
			.I(Tx_data)	
		),
          /* MemClock Handler */
          OBUF_CLKMEM(
                .O(OCLKMEM),
                .I(CLKMEM)
          ); 
            						
/*################ InOut Buffers ########################### */ 		
           /* Data Handler */
	IOBUF IOBUF_DQ[15:0]  (
			  .O(data_from_mem[15:0]),// Buffer output
			  .IO(DQ[15:0]),   		 // Buffer inout port 
			  .I(data_to_mem[15:0]),	 // Buffer input
			  .T(wr_mem)			 // 3-state enable input
			);

endmodule
