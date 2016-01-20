`timescale 1ns / 1ps
/*********************************************************************************
## Engineer: Raul Diaz
## Course:   CECS460
## Semester: Sp 15
## Modified: 5/10/15
====================================================================================
* File: TopLevel.v 
====================================================================================
* The Top level module implements the Core design and the TSI Block which are used 
* to communicate with an exterior interface. For the purposes of this project, the 
* micron memory located on the Nexys2 board will be used. It is the functionality 
* of the TSI block to handle the I/O used by the core. The TSI block can be 
* modified to handle various electrical characteristics which may be presented in 
* a real world application. However for the sake of simplicity, the I/O ports of 
* the top level design is assumed to handle the standard electrical inputs and 
* distribute the standard electrical output. If one may choose to alter the 
* electrical I/O, one may do so in the constraints file
*********************************************************************************/
module TopLevel(	SYS_CLK, SYS_RST, RX_IN, UART_CONFIG, BAUD_SEL,
						TX_OUT, UART_ERROR,  MEM_ADDR, DQ,
						CE_, OE_, WE_, ADV_, CRE, UB_, LB_,OCLKMEM,
                              ANODES, CATHODES,
			);	
          
     input  SYS_CLK, SYS_RST;      
     input  RX_IN; 
	input  [2:0] UART_CONFIG; 
	input  [3:0] BAUD_SEL; 
	output TX_OUT, CE_, OE_, WE_, ADV_, CRE, UB_, LB_, OCLKMEM;
	output [2:0] UART_ERROR; 
	output [3:0] ANODES; 
	output [6:0] CATHODES;
	output [22:0]MEM_ADDR;  
	inout  [15:0] DQ; 	  
	  
     /* Interconnects */ 
     wire       Clk, Rst, parity_en, odd_en, bit8_en, Rx_in, Tx_data;
     wire       cs, rd_mem, wr_mem, adv_mib, cre_mib,  upperbyte_en, lowbyte_en;
     wire [3:0] baud_sel;
     wire [15:0] data_to_mem, data_from_mem;
     wire [22:0] addr_to_mem;
            
     CoreLogic CORE(
         .Clk(Clk), 			     .Rst(Rst), 
         .baud_sel(baud_sel), 	     .parity_en(parity_en), 
	    .odd_en(odd_en), 		     .bit8_en(bit8_en), 
         .Rx_in(Rx_in),	
         .data_from_mem(data_from_mem),
            
         /*************** OUTPUTS *********************/            
         .Tx_data(Tx_data),          .flagreg(flagreg),		  		  	     
         .data_to_mem(data_to_mem),  .addr_to_mem(addr_to_mem), 
         .cs(cs), 			       .rd_mem(rd_mem), 
         .wr_mem(wr_mem), 		  .adv_mib(adv_mib), 
         .cre_mib(cre_mib), 	       .upperbyte_en(upperbyte_en), 
         .lowbyte_en(lowbyte_en),
         .a3(a3),                    .a2(a2), 
         .a1(a1),                    .a0(a0), 
	    .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g)	
	  );
					                            
	  TSI_Block TSI(
	   /* TSI SYSTEM INPUT Buffers */   /* INPUTS TO CORE LOGIC  */   
	  	.Sys_Clk(SYS_CLK),             .Clk_buf(Clk), 
		.Sys_Rst(SYS_RST),             .Rst_buf(Rst),	  
		.Rx_buf(RX_IN),                .Rx_in(Rx_in), 	  	   
		.UART_Confg_buf(UART_CONFIG),  .UART_Config({bit8_en, parity_en, odd_en}),
		.baud_sel_buf(BAUD_SEL),	      .baud_sel(baud_sel),
		.DQ(DQ),		                .data_from_mem(data_from_mem),
               
	   /* OUTPUTS FROM CORE LOGIC  */        /* TSI SYSTEM OUTPUT Buffers */ 
		.data_to_mem(data_to_mem),
          .Tx_data(Tx_data),	               .Tx_buf(TX_OUT),
		.cs(cs),                           .CE_(CE_),
		.rd_mem(rd_mem),                   .OE_(OE_), 
		.wr_mem(wr_mem),                   .WE_(WE_), 
		.adv_mib(adv_mib),                 .ADV_(ADV_), 
		.cre_mib(cre_mib),                 .CRE(CRE), 
		.upperbyte_en(upperbyte_en),       .UB_(UB_), 
		.lowbyte_en(lowbyte_en),           .LB_(LB_),
		.addr_to_mem(addr_to_mem),         .Addr_buf(MEM_ADDR),
          .anodes({a3, a2, a1, a0}),         .anodes_buf(ANODES),
		.cathodes({a, b, c, d, e, f, g}),  .cathodes_buf(CATHODES),
          .UART_error(flagreg),              .UART_error_buf(UART_ERROR),
          .CLKMEM(1'b0),                     .OCLKMEM(OCLKMEM)               
	 );
           
endmodule
