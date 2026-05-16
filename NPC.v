`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:57:08 11/05/2024 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
		input [31:0] F_PC,
		input [31:0] D_PC,
		input beq_jump, //ÅÐ¶ÏbeqÖ¸ÁîÊÇ·ñÌø×ª
		input [2:0] PCsrc,
		input [31:0] grf_rs,
		input [31:0] imm32,
		input [25:0] instr_index,
		input Req,
		input eret,
		input [31:0] EPC,
		output [31:0] nPC
    );
	 
	 //PCsrc 11 -> $rs 10 -> PC[31:28]||instr_index||2'00 01 -> PC + 4 + imm32(signed expansion) 00 -> PC + 4
	 
	 assign nPC = 	Req ? `exc_pc :
						eret ? EPC + 4 :
						PCsrc == 3'b100 ? (!beq_jump ? D_PC + 4 + (imm32 << 2) : F_PC + 4) :
						PCsrc == 3'b011 ? grf_rs :
						PCsrc == 3'b010 ? {D_PC[31:28], instr_index, 2'b00} :
						PCsrc == 3'b001 ? (beq_jump ? D_PC + 4 + (imm32 << 2) : F_PC + 4) : F_PC + 4;


endmodule
