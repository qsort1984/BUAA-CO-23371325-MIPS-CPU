`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:20:39 11/05/2024 
// Design Name: 
// Module Name:    D_E_Register 
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
module D_E_Register(
		input [31:0] D_PC,
		input [31:0] D_Instr,
		input [31:0] D_grf_rs,
		input [31:0] D_grf_rt,
		input [31:0] D_reg, //D级指令将要写入寄存器的值
		input [31:0] D_imm32,
		input [4:0] D_exccode,
		input D_BD,
		input clk,
		input reset,
		input Req,
		input flush, //阻塞时寄存器刷新信号
		output reg [31:0] E_PC,
		output reg [31:0] E_Instr,
		output reg [31:0] E_grf_rs,
		output reg [31:0] E_grf_rt,
		output reg [31:0] E_reg, //E级指令将要写入寄存器的值
		output reg [31:0] E_imm32,
		output reg [4:0] E_exccode,
		output reg E_BD
    );
	
	////////////////////流水延迟槽指令信号
	
	initial begin
		E_PC <= 32'h0000_3000;
		E_Instr <= 32'h0000_0000;
		E_grf_rs <= 32'h0000_0000;
		E_grf_rt <= 32'h0000_0000;
		E_reg <= 32'h0000_0000;
		E_imm32 <= 32'h0000_0000;
		E_exccode <= `exc_none;
		E_BD <= 0;
	end
	
	always @(posedge clk) begin
		if (reset || flush || Req) begin
			E_PC <= flush ? D_PC : (Req ? `exc_pc : 32'h0000_3000);
			E_Instr <= 32'h0000_0000;
			E_grf_rs <= 32'h0000_0000;
			E_grf_rt <= 32'h0000_0000;
			E_reg <= 32'h0000_0000;
			E_imm32 <= 32'h0000_0000;
			E_exccode <= `exc_none;
			E_BD <= flush ? D_BD : 0;
		end
		else begin
			E_PC <= D_PC;
			E_Instr <= D_Instr;
			E_grf_rs <= D_grf_rs;
			E_grf_rt <= D_grf_rt;
			E_reg <= D_reg;
			E_imm32 <= D_imm32;
			E_exccode <= D_exccode;
			E_BD <= D_BD;
		end
	end
	

endmodule
