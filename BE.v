`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:46:45 11/12/2024 
// Design Name: 
// Module Name:    BE 
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
module BE(
    input [31:0] MemAddr,
	 input [2:0] LWop,
	 input MemWrite,
    output [3:0] m_data_byteen
    );
	 
	 wire [3:0] sh_byteen, sb_byteen;
	 
	 assign sh_byteen = MemAddr[1] == 1'b1 ? 4'b1100 : 4'b0011;
	 assign sb_byteen = MemAddr[1:0] == 2'b00 ? 4'b0001 : 
								MemAddr[1:0] == 2'b01 ? 4'b0010 :
								MemAddr[1:0] == 2'b10 ? 4'b0100 : 4'b1000;
	 
	 assign m_data_byteen = MemWrite ? (LWop == 3'b000 ? 4'b1111 : 
									            LWop == 3'b100 ? sh_byteen : sb_byteen) : 4'b0000;


endmodule
