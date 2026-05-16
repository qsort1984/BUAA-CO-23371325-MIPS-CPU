`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:20:04 11/05/2024 
// Design Name: 
// Module Name:    F_D_Register 
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
module F_D_Register(
		input [31:0] F_PC,
		input [31:0] F_Instr,
		input [4:0] F_exccode,
		input F_BD,
		input clk,
		input reset,
		input Req,
		input flush, //阻塞时寄存器刷新信号
		output reg [31:0] D_PC,
		output reg [31:0] D_Instr,
		output reg [4:0] D_exccode,
		output reg D_BD
    );
	
	initial begin
		D_PC <= 32'h0000_3000;
		D_Instr <= 32'h0000_0000;
		D_exccode <= `exc_none;
		D_BD <= 0;
	end
	
	always @(posedge clk) begin
		if (reset) begin
			//应该reset最优先
			D_PC <= 32'h0000_3000;
			D_Instr <= 32'h0000_0000;
			D_exccode <= `exc_none;
			D_BD <= 0;
		end else if (Req) begin
			D_PC <= `exc_pc;
			D_Instr <= 32'h0000_0000;
			D_exccode <= `exc_none;
			D_BD <= 0;
		end
		else if (flush) begin
			D_PC <= F_PC;
			D_Instr <= F_Instr;
			D_exccode <= F_exccode;
			D_BD <= F_BD;
		end
	end

endmodule
