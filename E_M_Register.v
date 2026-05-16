`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:21:16 11/05/2024 
// Design Name: 
// Module Name:    E_M_Register 
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
module E_M_Register(
		input [31:0] E_PC,
		input [31:0] E_Instr,
		input [31:0] E_reg,
		input [31:0] E_grf_rt,
		input [31:0] E_ALU_ans,
		input [4:0] E_exccode,
		input E_overflow,
		input E_BD,
		input clk,
		input reset,
		input Req,
		input flush, //×èÈûÊ±¼Ä´æÆ÷Ë¢ÐÂÐÅºÅ
		output reg [31:0] M_PC,
		output reg [31:0] M_Instr,
		output reg [31:0] M_reg,
		output reg [31:0] M_grf_rt,
		output reg [31:0] M_ALU_ans,
		output reg [4:0] M_exccode,
		output reg M_overflow,
		output reg M_BD
    );
	
	initial begin
		M_PC <= 32'h0000_3000;
		M_Instr <= 32'h0000_0000;
		M_grf_rt <= 32'h0000_0000;
		M_ALU_ans <= 32'h0000_0000;
		M_reg <= 32'h0000_0000;
		M_exccode <= `exc_none;
		M_overflow <= 0;
		M_BD <= 0;
	end
	
	always @(posedge clk) begin
		if (reset || Req) begin
			M_PC <= Req ? `exc_pc : 32'h0000_3000;
			M_Instr <= 32'h0000_0000;
			M_grf_rt <= 32'h0000_0000;
			M_ALU_ans <= 32'h0000_0000;
			M_reg <= 32'h0000_0000;
			M_exccode <= `exc_none;
			M_overflow <= 0;
			M_BD <= 0;
		end
		else begin
			M_PC <= E_PC;
			M_Instr <= E_Instr;
			M_grf_rt <= E_grf_rt;
			M_ALU_ans <= E_ALU_ans;
			M_reg <= E_reg;
			M_exccode <= E_exccode;
			M_overflow <= E_overflow;
			M_BD <= E_BD;
		end
	end


endmodule
