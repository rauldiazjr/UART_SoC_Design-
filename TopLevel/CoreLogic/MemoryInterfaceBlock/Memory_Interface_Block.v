`timescale 1ns / 1ps
/*********************************************************************************
## Engineer: Raul Diaz
## Course:   CECS460
## Semester: Sp 15
## Modified: 5/10/15
====================================================================================
* File: Memory_Interface_Block.v 
====================================================================================
*     The Memory Interface Block provides the communication link between 
* the PicoBlaze processor and the exterior memory interface. The design of the 
* MIB is constructed around the MIB State Machine which provides the necessary 
* load signals to the 2 read buffer register holding data from memory. The state 
* machine also provides read and write enable (OE_ & WE_) signals to the memory 
* chip on respective states the PicoBlaze may be in. 

*********************************************************************************/
module Memory_Interface_Block(clk, rst, wr_strb, rd_strb, data_from_mem, 
                  addr_to_mem, status, datain, data_to_mem,  dataout,
                  CE_,OE_, WE_, ADV_, CRE, UB_, LB_                              
                  );

   input     clk, rst; 
   input     [7:0]   datain; 
   input     [15:0]  data_from_mem; 
   input     [255:0] wr_strb, rd_strb; 
   output    CE_,OE_, WE_, ADV_, CRE, UB_, LB_;
   output    [7:0]  dataout; 
   output    [7:0]  status; 
   output    [15:0] data_to_mem; 
   output    [22:0] addr_to_mem; 
   
   wire      ld; 
   wire      [7:0] rd_data0, rd_data1; 
   
   assign    dataout = rd_strb[17] ? rd_data1 : rd_data0; 
   assign    {ADV_, CRE, UB_, LB_} = 4'b0;    /* Always low */ 
   
   /*****************************************************
   *   RS Flop: Sets and Reseting MIB Ready Status 
   ******************************************************/       
   RSFlop Mem_RDY(
     .Clk(clk), 
     .Rstb(rst), 
     .R(rd_strb[18]), 
     .S(ld), 
     .Q(status[0])
   );
     
   /*****************************************************
   *      MIB State Machine
   ******************************************************/ 
   MIB_SM SM(
     .Clk(clk), 
     .Rstb(rst), 
     .do_rd(rd_strb[18]), 
     .do_wr(wr_strb[19]), 
     .cs(CE_), 
     .rd_mem(OE_), 
     .wr_mem(WE_), 
     .ld(ld)
    ); 
      
   /*****************************************************
   *    Synch Clock; Active Low Rst: 8 bit Registers
   ******************************************************/       
   /* Address Registers */       
   LDRG_8bit  
       addr0(
          .Clk(clk), 
          .Rstb(rst), 
          .D(datain), 
          .en(wr_strb[11]), 
          .Q(addr_to_mem[7:0])
       ),
       addr1(
          .Clk(clk), 
          .Rstb(rst), 
          .D(datain), 
          .en(wr_strb[12]), 
          .Q(addr_to_mem[15:8])
       ),
       addr2(
          .Clk(clk), 
          .Rstb(rst), 
          .D(datain), 
          .en(wr_strb[13]), 
          .Q(addr_to_mem[22:16])
       ),
    
 /* Write Buffer Register */          
       wrdata0(
          .Clk(clk), 
          .Rstb(rst), 
          .D(datain), 
          .en(wr_strb[14]), 
          .Q(data_to_mem[7:0])
       ),   
       wrdata1(
          .Clk(clk), 
          .Rstb(rst), 
          .D(datain), 
          .en(wr_strb[15]), 
          .Q(data_to_mem[15:8])
       ),   
    
 /* Read Buffer Register */    
       ReadBuff_reg1(
          .Clk(clk), 
          .Rstb(rst), 
          .D(data_from_mem[15:8]), 
          .en(ld), 
          .Q(rd_data1)
       ),
       ReadBuff_reg0(
          .Clk(clk), 
          .Rstb(rst), 
          .D(data_from_mem[7:0]), 
          .en(ld), 
          .Q(rd_data0)
       );
endmodule
