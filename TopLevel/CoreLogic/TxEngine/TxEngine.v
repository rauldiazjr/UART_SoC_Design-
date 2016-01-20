`timescale 1ns / 1ps
/*********************************************************************************
====================================================================================
* File: TxEngine.v 
====================================================================================
	The TxEngine module is an 8 bit sychronous loadable transmit engine. Operation is 
executed on a high signal fron the tx_start port which triggers the load of an 
8 bit register and signals 2 counters which handle baud rate timing and bit 
transfers for the system. The tx_out will transmit an 11 bit value using a
'Parallel In- Serial out' shift register module. The 11 bit value exercises an 
RS232 protocol which includes: 1 stop bit, 1 start bit, 8 bit data , and based on 
the UART Config register, a Parity bit. Trailing ones, are followed after data has
completed transmission. 
	The UART configeration is set one time upon reset and stored in a 3 bit register 
used in a procedural case statment. bit8_en port will determine if an 8 bit value 
is transmitted, if the port is low by default the system will transmit 7 bits.
parity_en port will determine if parity is detected on the input, and Odd_en
port will check for an Odd parity or even parity if bit is set low. 
The baudrate timing detection is handled with an 18 bit counter value 
corresponding to a specific baudrate requested by the system. 
high to signal the Tx_engine is ready for another transfer. 
After the timming is complete on an 11 bit transfer, the tx_rdy port will output 
**********************************************************************************/
module TxEngine(Clk, Rst, data_in, tx_start, parity_en, bit8_en, 
                odd_en, Baud_val, tx_out, tx_rdy);
                
     input Clk, Rst; 
     input bit8_en, parity_en, odd_en, tx_start; 
     input [7:0]  data_in; 
     input [17:0] Baud_val; 
         
     output tx_out, tx_rdy; 
       
     /* PIPO Buffer register */ 
     reg [7:0] pipo_buf;  
     /*Decode load buffer */
     reg ld_buf;      
     /* PISO Data bus*/
     reg [10:0] parallel_in;           
     /* Uart Config */ 
     wire [2:0] Uart_config;      
     /* Data signals */      
     wire A, B, C, D,BTU, bc_11_done; 
            
      /*********************************************
                   Continous  Assignments    
      **********************************************/    
     assign A = ^pipo_buf[6:0]; 
     assign B = ~^pipo_buf[6:0]; 
     assign C = ^pipo_buf[7:0]; 
     assign D = ~^pipo_buf[7:0]; 
     
     /*********************************************
                   Procedrual Combo block    
     **********************************************/           
     always @(*)  begin       
          case(Uart_config)
               /*7N1*/  0: parallel_in = { 1'b1, 1'b1, pipo_buf[6:0], 1'b0, 1'b1 }; 
               /*7N1*/  1: parallel_in = { 1'b1, 1'b1, pipo_buf[6:0], 1'b0, 1'b1 }; 
               /*7E1*/  2: parallel_in = { 1'b1, A   , pipo_buf[6:0], 1'b0, 1'b1 }; 
               /*7O1*/  3: parallel_in = { 1'b1, B   , pipo_buf[6:0], 1'b0, 1'b1 }; 
               /*8N1*/  4: parallel_in = { 1'b1, pipo_buf[7:0], 1'b0, 1'b1 }; 
               /*8N1*/  5: parallel_in = { 1'b1, pipo_buf[7:0], 1'b0, 1'b1 }; 
               /*8E1*/  6: parallel_in = { C   , pipo_buf[7:0], 1'b0, 1'b1 }; 
               /*8O1*/  7: parallel_in = { D   , pipo_buf[7:0], 1'b0, 1'b1 }; 
					/*7N1*/	default:parallel_in = { 1'b1,1'b1,pipo_buf[6:0],1'b0,1'b1}; 
          endcase
    
    end
    
    /*********************************************
               Parallel In Serial Out Shift Reg    
     **********************************************/     
    Shiftreg_PISO piso(
      .Clk(Clk), 
      .Rst(Rst), 
      .ld(ld_buf), 
      .sh_en(BTU), 
      .data_in(parallel_in), 
      .ser_in(1'b1), 
      .ser_out(tx_out) );
                       
    /*********************************************
                11 bit Counter Module    
     **********************************************/ 
    count_11_bits count11(
      .Clk(Clk), 
      .Rst(Rst), 
      .start(start_count), 
      .BTU(BTU), 
      .done(bc_11_done) );
                          
    /*********************************************
                Bit Time Counter Module    
     **********************************************/ 
    Bit_time_counter btc(
      .Clk(Clk), 
      .Rst(Rst),
      .start(start_count), 
      .baud_count(Baud_val), 
      .BTU(BTU) );
                         
    /*********************************************
                RS Start Transmit module    
     **********************************************/                      
    RSFlop start_transmit_ff(
      .Clk(Clk), 
      .Rstb(Rst), 
      .R(bc_11_done), 
      .S(ld_buf), 
      .Q(start_count) );
    /*********************************************
                RS TX Ready module    
     **********************************************/                 
     RSFlop tx_ready(
      .Clk(Clk), 
      .Rstb(Rst), 
      .R(tx_start), 
      .S(bc_11_done), 
      .Q(tx_rdy) );               
    /*********************************************
                Sequential block    
     **********************************************/  
	 assign  Uart_config = {bit8_en, parity_en, odd_en};
    always @(posedge Clk, negedge Rst) begin  
          /********************************
             One shot Uart Configuration 
                    if(!Rst)  
               Uart_config <= {bit8_en, parity_en, odd_en};
               ********************************/ 

          /********************************
             Load Enable buffer register 
          ********************************/ 
          
          if(!Rst) 		  ld_buf <= 0;            else
								  ld_buf <= tx_start; 
                   
          /********************************
             PIPO buffer register 
          ********************************/ 
          
          if(!Rst)        pipo_buf <= 8'b0;        else
          if(tx_start)    pipo_buf <= data_in;     else
                          pipo_buf <= pipo_buf;
								  
     end 
endmodule
