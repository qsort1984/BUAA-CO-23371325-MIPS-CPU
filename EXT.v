`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:01:01 11/05/2024 
// Design Name: 
// Module Name:    EXT 
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
module EXT(
    input [15:0] in,
    input [1:0] EXTOp,
    output [31:0] out
    );
	 
	 assign out = EXTOp == 2'b10 ? {in,{16{1'b0}}} :
						EXTOp == 2'b01 ? {{16{in[15]}}, in} : {{16{1'b0}}, in};

endmodule
