`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:44:40 11/12/2024 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input clk,
    input reset,
	 input Req,
    input PC_EN,
    input [31:0] nPC,
    output reg [31:0] PC
    );
	 
	 initial begin
		PC = 32'h0000_3000;
	 end
	 
	 always @(posedge clk) begin
		if (reset) begin
			PC <= 32'h00003000;
		end
		else if (PC_EN || Req) begin
			PC <= Req ? `exc_pc : nPC;
		end
	 end


endmodule
