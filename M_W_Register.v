`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:21:39 11/05/2024 
// Design Name: 
// Module Name:    M_W_Register 
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
module M_W_Register(
		input [31:0] M_PC,
		input [31:0] M_Instr,
		input [31:0] M_reg,
		input clk,
		input reset,
		input Req,
		output reg [31:0] W_PC,
		output reg [31:0] W_Instr,
		output reg [31:0] W_reg
    );
	
	initial begin
		W_PC <= 32'h0000_3000;
		W_Instr <= 32'h0000_0000;
		W_reg <= 32'h0000_0000;
	end
	
	always @(posedge clk) begin
		if (reset || Req) begin
			W_PC <= Req ? `exc_pc : 32'h0000_3000;
			W_Instr <= 32'h0000_0000;
			W_reg <= 32'h0000_0000;
		end
		else begin
			W_PC <= M_PC;
			W_Instr <= M_Instr;
			W_reg <= M_reg;
		end
	end

endmodule
