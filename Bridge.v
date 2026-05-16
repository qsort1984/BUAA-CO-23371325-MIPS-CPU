`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:04:12 11/23/2024 
// Design Name: 
// Module Name:    Bridge 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "define.v"
module Bridge(
	input [31:0] PrAddr,
	input [31:0] PrWD,
	input PrWE,
	
	output [31:0] PrRD,
	input [31:0] DM_RD,
	input [31:0] DEV0_RD,
	input [31:0] DEV1_RD,
	
	output DEV0_WE,
	output DEV1_WE,
	output [31:0] DEV_Addr,
	output [31:0] DEV_WD,
	
	input [3:0] byteen,
	output [3:0] m_data_byteen,
	output [31:0] m_int_addr,     // 中断发生器待写入地址
   output [3:0] m_int_byteen   // 中断发生器字节使能信号
   );
	
	wire DEV0, DEV1, DM, INTERRUPT;
	
	wire DM_WE, INTERRUPT_WE;
	
	assign DEV0 = (PrAddr >= `DEV0_START_ADDR && PrAddr <= `DEV0_END_ADDR);
   assign DEV1 = (PrAddr >= `DEV1_START_ADDR && PrAddr <= `DEV1_END_ADDR);
	assign DM = (PrAddr >= `DM_START_ADDR && PrAddr <= `DM_END_ADDR);
	assign INTERRUPT = (PrAddr >= `INTERRUPT_START_ADDR && PrAddr <= `INTERRUPT_END_ADDR);
	
	assign DEV0_WE = DEV0 & PrWE;
	assign DEV1_WE = DEV1 & PrWE;
	assign DM_WE = DM & PrWE;
	assign INTERRUPT_WE = INTERRUPT & PrWE;
	
	assign m_data_byteen = DM_WE ? byteen : 0;
	assign m_int_byteen = INTERRUPT_WE ? byteen : 0;
	
	assign PrRD =  DM ? DM_RD :
						DEV0 ? DEV0_RD :
						DEV1 ? DEV1_RD : `DEBUG_DEV_DATA;
						
	assign m_int_addr = PrAddr;
	
	assign DEV_addr = PrAddr;
	
	assign DEV_WD = PrWD;


endmodule
