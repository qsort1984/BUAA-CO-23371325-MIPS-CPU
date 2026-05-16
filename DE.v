`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:35:08 11/12/2024 
// Design Name: 
// Module Name:    DE 
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
module DE(
    input [1:0] A,
    input [31:0] Din,
    input [2:0] Op,
    output [31:0] Dout
    );
	 
	 wire [7:0] byte_[0:3];
	 wire [15:0] half_word[0:1];
	 
	 assign {byte_[3], byte_[2], byte_[1], byte_[0]} = Din;
	 assign {half_word[1], half_word[0]} = Din;
	 
	 assign Dout = Op == 3'b000 ? Din :
						Op == 3'b001 ? {24'b0, byte_[A]} :
						Op == 3'b010 ? {{24{byte_[A][7]}}, byte_[A]} :
						Op == 3'b011 ? {16'b0, half_word[A[1]]} : {{16{half_word[A[1]][15]}},half_word[A[1]]};
	

endmodule
