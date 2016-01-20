`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  
// Engineer: Ruben Diaz
// 
// Create Date:    	11:10:54 04/20/2014 
// Target Devices: 	NEXYS 2
// Tool versions: 	Xilinx 12.2
//
// Dependencies: MemoryControlUnitFSM.v,  
//				FourTo16Decoder.v, SixteenToEightDataGateKeeper.v,
//				loadRegiste8bit.v. 
//
// Description: This module instantiates and interconnects the components
//			of the Memory Control Module. The memory control module is in charge
//			of saving and reading data from the SDRAM 128Mbit Micron M45W8MW.
//			In order to write data into the memory the control unit needs to hold
//			CE = 0, WE = 0, for 85ns. In order to read from memory the control
//			unit needs to hold CE = 0, WE = 1, OE = 0 for 85ns.
//			
//			Inputs:
//			-------------------------------------------------
//			Clock: Clock input 50MHz.
//			Resetb: synchronous reset signal.
//			Write: Write Strobe.
//			Read: Read Strobe.
//			ChipSelect: Chip select signal.
//			DataIn: 8 bit data input. 
//			Address: 4 bit input that selects the correct operation for the control
//						unit.
//			DataOut: 8 bit output that will hold the data or status from the control
//						unit.
//			CE: One bit output that connects to the memory Chip Select.
//			WE: One bit output that connects to the write enable of the memory.
//			OE: One bit output that connects to the read enable of the memory.
//			ADV: One bit output that connects to the ADV input of the memory.
//			CRE: One bit output that connects to the CRE input of the memory.
//			UB: One bit output that connects to the UB input of the memory.
//			LB: One bit output that connects to the LB input of the memory.
//			AD: 16 bit output that connects to the AD input of the memory for address
//						to use while reading and writing.
//			DQ: 24 bit input/output that carries the data to write and read.
//
//			ADDRESS |			OPERATION
//			_________________________________________
//			0			|	No Operation
//			1			|	Write Address Register 0
//			2			|	Write Address Register 1
//			3			|	Write Address Register 2
//			4			|	Write Data Out Register 0
//			5			|	Write Data Out Register 1
//			6			|	Read Data in Register 0
//			7			|	Read Data in Register 1
//			8			|	Perform Memory Read
//			9			|	Perform Memory Write
//			A			|	Read MIB Status
//			B-F		|	No Operation
//////////////////////////////////////////////////////////////////////////////////
module MemoryInterfaceBlock(Clock, Resetb, Write, Read, ChipSelect, DataIn, 
									Address, DataOut,CE,WE,OE,ADV,CRE,UB,LB,AD,DQin,DQout);
	
	/////////////////
	//		Inputs	//
	/////////////////
	input Clock, Resetb, Write, Read, ChipSelect;
	input [3:0] Address;
	input [7:0] DataIn;
	input [15:0]DQin;
	
	/////////////////
	//		Outputs	//
	/////////////////
	output [7:0] DataOut;
	output [15:0] DQout;
	output CE,WE,OE,ADV,CRE,UB,LB;
	output [23:0]AD;
	
	///////////////////////////////////
	//	Internal Wires and register	//
	///////////////////////////////////
	wire Load,RDY;
	wire [15:0] dataFromReadRegister, decoderOutput;
	reg [15:0] dqReg;
	wire [7:0] statusWire, ReadRegWire;
	
	
	/////////////////////////////
	//		Status or Data Mux	//
	/////////////////////////////
	assign DataOut = (decoderOutput[10])? statusWire : ReadRegWire;
	
	////////////////////////////////////
	//		Assign 0 to {ADV,CRE,UB,LB} //
	////////////////////////////////////
	assign {ADV,CRE,UB,LB} = 4'b0000;
	
	
	////////////////////////////////
	//		Module Instantiation		//
	////////////////////////////////	
	
	MemoryControlUnitFSM 
					FSM(.Clock(Clock), .Resetb(Resetb), 
					.Read(decoderOutput[8] && (ChipSelect) && Write), 
					.Write(decoderOutput[9] && (ChipSelect)&& Write), 
					.CE(CE),.WE(WE),.OE(OE),.RDY(RDY),.Load(Load));

	
	
	FourTo16Decoder 
					RegDecoder(.inputSelect(Address),.enable(ChipSelect) , 
					.Output(decoderOutput));
	
	SixteenToEightDataGateKeeper 
					GateKeeper(.DataIn(dataFromReadRegister),
					.ReadLowByte(decoderOutput[6]),.ReadHighByte(decoderOutput[7]),
					.OutData(ReadRegWire));

	loadRegiste8bit 	
							ADDReg0(.Clock(Clock),.Resetb(Resetb),
							.Load(decoderOutput[1] && Write),.D(DataIn),.Q(AD[8:1])),
							ADDReg1(.Clock(Clock),.Resetb(Resetb),
							.Load(decoderOutput[2] && Write),.D(DataIn),.Q(AD[16:9])),
							ADDReg2(.Clock(Clock),.Resetb(Resetb),
							.Load(decoderOutput[3] && Write),.D(DataIn),.Q(AD[23:17])),
							WReg0(.Clock(Clock),.Resetb(Resetb),
							.Load(decoderOutput[4] && Write),.D(DataIn),.Q(DQout[7:0])),
							WReg1(.Clock(Clock),.Resetb(Resetb),
							.Load(decoderOutput[5] && Write),.D(DataIn),.Q(DQout[15:8])),
							RReg0(.Clock(Clock),.Resetb(Resetb),
							.Load(Load),.D(DQin[7:0]),.Q(dataFromReadRegister[7:0])),
							RReg1(.Clock(Clock),.Resetb(Resetb),
							.Load(Load),.D(DQin[15:8]),.Q(dataFromReadRegister[15:8])),
							MIBSta(.Clock(Clock),.Resetb(Resetb),
							.Load(1'b1),.D({7'b0000000,RDY}),.Q(statusWire));
endmodule
