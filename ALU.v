`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:29:50 10/29/2024 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] a,
    input [31:0] b,
    input [2:0] ALUop,
    output [31:0] result,
	 output overflow
    );
	 
	 wire slt, sltu;
	 
	 wire [32:0] a_tem = {a[31], a};
    wire [32:0] b_tem = {b[31], b};
    wire [32:0] add = a_tem + b_tem;
    wire [32:0] sub = a_tem - b_tem;
    assign overflow = (ALUop == `ALU_add) ? add[32] != add[31] :
							 (ALUop == `ALU_sub) ? sub[32] != sub[31] : 0;
	 
	 assign slt = $signed(a) < $signed(b);
	 assign sltu = a < b;
	 
	 assign result = ALUop == `ALU_add ? a + b :
							ALUop == `ALU_sub ? a - b :
							ALUop ==	`ALU_or ? a | b : 
							ALUop == `ALU_and ? a & b :
							ALUop == `ALU_slt ? {{31{1'b0}}, slt} : {{31{1'b0}}, sltu};
	//////////Òì³£´¦Àí
	 
endmodule
