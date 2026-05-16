`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:02:25 11/25/2024 
// Design Name: 
// Module Name:    CP0 
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
module CP0(
	 input clk,
    input reset,
	 input WE, //写使能信号
    input [4:0] CP0Addr, //寄存器地址
    input [31:0] CP0In, //CP0写入数据
	 output [31:0] CP0Out, //CP0读出数据
    input [31:0] VPC, //受害PC
	 input BDIn, //是否是延迟槽指令
    input [6:2] ExcCode, //记录异常类型
    input [5:0] HWInt, //输入中断信号
    input EXLClr, //EXL复位信号
    output Req, //进入处理程序请求
    output [31:0] EPC //EPC的值
    );
	 
	 reg [31:0] sr, cause, epc;
	 
	 wire [5:0] sr_im = sr[15:10]; //分别对应六个外部中断，相应位置 1 表示允许中断，置 0 表示禁止中断。这是一个被动的功能，只能通过 mtc0 这个指令修改，通过修改这个功能域，我们可以屏蔽一些中断
	 wire sr_exl = sr[1]; //任何异常发生时置位，这会强制进入核心态（也就是进入异常处理程序）并禁止中断
	 wire sr_ie = sr[0]; //全局中断使能，该位置 1 表示允许中断，置 0 表示禁止中断
	 
	 wire Int = !sr_exl && sr_ie && ((HWInt & sr_im) != 0); //允许中断
    wire exc = (!Int) && ((ExcCode == `exc_adel) || (ExcCode == `exc_ades) ||(ExcCode == `exc_syscall) || (ExcCode == `exc_ri) || (ExcCode == `exc_ov)); //异常
	 
	 assign Req = Int || exc;
	 assign EPC = epc;
    assign CP0Out = (CP0Addr == `cp0_sr) ? sr :
                    (CP0Addr == `cp0_cause) ? cause :
                    (CP0Addr == `cp0_epc) ? epc : 32'hx0x0_x0x0; //32'hx0x0_x0x0用于debug
	 
	 
	 initial begin
		sr <= 32'h0000_0000;
		cause <= 32'h0000_0000;
		epc <= 32'h0000_0000;
	 end
	 
	 always @(posedge clk) begin
		if (reset) begin
			sr <= 32'h0000_0000;
			cause <= 32'h0000_0000;
			epc <= 32'h0000_0000;
		end else if (Int || exc) begin
			sr[1] <= 1;
			cause[6:2] <= Int ? `exc_int : ExcCode;
			cause[15:10] <= HWInt;
			cause[31] <= BDIn;
			epc <= BDIn ? VPC - 4 : VPC;
		end else if (WE) begin
			cause[15:10] <= HWInt;
			if (CP0Addr == `cp0_sr) begin 
            sr[0] <= CP0In[0];
				sr[1] <= CP0In[1];
				sr[15:10] <= CP0In[15:10];
			end else if (CP0Addr == `cp0_cause) begin
				//只读，无法写入
			end else if (CP0Addr == `cp0_epc) begin
				epc <= CP0In;
			end
		end else begin
			sr[1] <= (EXLClr) ? 0 : sr[1];
			cause[15:10] <= HWInt;
		end
	 end


endmodule
