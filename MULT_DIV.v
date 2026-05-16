`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:07:23 11/12/2024 
// Design Name: 
// Module Name:    MULT_DIV 
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
module MULT_DIV(
    input clk,
    input reset,
	 input Req,
    input start,
    input [31:0] A,
    input [31:0] B,
    input [2:0] MDop,
    output reg [31:0] hi,
    output reg [31:0] lo,
    output reg busy
    );
	 
	 reg [31:0] hi_reg, lo_reg;
	 reg [3:0] cycle_cnt;
	 
	 initial begin
		hi_reg <= 32'h0000_0000;
		lo_reg <= 32'h0000_0000;
		cycle_cnt <= 4'b0000;
		busy <= 0;
		hi <= 32'h0000_0000;
		lo <= 32'h0000_0000;
	 end
	 
	 always @(posedge clk) begin
		if (reset) begin
			hi_reg <= 32'h0000_0000;
			lo_reg <= 32'h0000_0000;
			cycle_cnt <= 4'b0000;
			busy <= 0;
			hi <= 32'h0000_0000;
			lo <= 32'h0000_0000;
		end else if (!busy && !Req) begin
			if (start) begin
				busy <= 1;
				case (MDop)
					`md_mult: begin
						{hi_reg, lo_reg} <= $signed(A) * $signed(B);
						cycle_cnt <= `mult_cycle;
					end
					`md_multu: begin
						{hi_reg, lo_reg} <= A * B;
						cycle_cnt <= `mult_cycle;
					end
					`md_div: begin
						hi_reg <= $signed(A) % $signed(B);
						lo_reg <= $signed(A) / $signed(B);
						cycle_cnt <= `div_cycle;
					end
					`md_divu: begin
						hi_reg <= A % B;
						lo_reg <= A / B;
						cycle_cnt <= `div_cycle;
					end
				endcase
			end else if (MDop == `md_mthi) begin
				hi_reg <= A;
				hi <= A;
			end else if (MDop == `md_mtlo) begin
				lo_reg <= A;
				lo <= A;
			end
		end else if (busy) begin
			if(cycle_cnt > 1) begin
				cycle_cnt <= cycle_cnt - 1;
			end else begin
					hi <= hi_reg;
					lo <= lo_reg;
					busy <= 0;
					cycle_cnt <= 0;
				end
			end
	 end


endmodule
