`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:34:24 10/29/2024 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
	 input [31:0] PC,
    input clk,
    input reset,
    input WE,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    output [31:0] RD1,
    output [31:0] RD2
    );
	 
	 reg [31:0] grf[0:31];
	 
	 integer i;
	 
	 initial begin
		for (i = 0; i < 32; i = i + 1) begin
			grf[i] = 32'h0000_0000;
		end
	 end
	 
	 always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < 32; i = i + 1) begin
				grf[i] <= 32'h0000_0000;
			end
		end
		else begin
			if (WE) begin
				if (A3 != 5'b0_0000) grf[A3] <= WD;
			end
		end
	 end
	 
	 //GRF内部转发
	 assign RD1 = ( A1 == A3 && WE && A3 != 0) ? WD : grf[A1];
	 assign RD2 = ( A2 == A3 && WE && A3 != 0) ? WD : grf[A2];

endmodule
