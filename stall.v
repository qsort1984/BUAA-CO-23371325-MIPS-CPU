`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:00:18 11/05/2024 
// Design Name: 
// Module Name:    stall 
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
module stall(
		//在D级阻塞流水线
		input [2:0] rs_Tuse,
		input [2:0] rt_Tuse,
		input [2:0] E_Tnew,//E级指令算出结果并存入流水线寄存器的时间
		input [2:0] M_Tnew,//M级指令算出结果并存入流水线寄存器的时间
		input [2:0] W_Tnew,//M级指令算出结果并存入流水线寄存器的时间
		input [4:0] D_A1,//rs
		input [4:0] D_A2,//rt
		input [4:0] E_A1,
		input [4:0] E_A2,
		input [4:0] E_A3,//E级指令写入寄存器的地址
		input [4:0] M_A2,
		input [4:0] M_A3,//M级指令写入寄存器的地址
		input [4:0] W_A3,//W级指令写入寄存器的地址
		// E_reg表示 E 级流水寄存器中储存着的lui结果或jal中将要写回寄存器的值，即 E 级转发数据
		// M_reg表示 M 级流水寄存器中储存着的 ALU 结果，即 M 级转发数据
		// W_reg表示 W 级流水寄存器中将要写回到寄存器堆的值，即 W 级转发数据
		input [31:0] E_reg,
		input [31:0] M_reg,
		input [31:0] W_reg,
		input E_RegWrite,
		input M_RegWrite,
		input W_RegWrite,
		input [31:0] D_rs_data,
		input [31:0] D_rt_data,
		input [31:0] E_rs_data,
		input [31:0] E_rt_data,
		input [31:0] M_rt_data,
		input md_start,
		input md_busy,
		input md,
		input mt,
		input mf,
		input D_eret,
		input E_mtc0,
		input M_mtc0,
		input [4:0] E_rd,
		input [4:0] M_rd,
		output Stall,
		//D/E/M级rs/rt端接受转发的结果
		//转发接受端口，NPC的rs端，CMP的rs、rt端，ALU的rs、rt端，DM的rt端
		output [31:0] D_MF_rs,
		output [31:0] D_MF_rt,
		output [31:0] E_MF_rs,
		output [31:0] E_MF_rt,
		output [31:0] M_MF_rt
    );
	
	////////////////////////阻塞
	wire Stall_RS, Stall_RT, Stall_MD, Stall_ERET;
	
	assign Stall_RS = (rs_Tuse < E_Tnew && D_A1 != 0 && D_A1 == E_A3 && E_RegWrite) ||
							(rs_Tuse < M_Tnew && D_A1 != 0 && D_A1 == M_A3 && M_RegWrite);
	assign Stall_RT = (rt_Tuse < E_Tnew && D_A2 != 0 && D_A2 == E_A3 && E_RegWrite) ||
							(rt_Tuse < M_Tnew && D_A2 != 0 && D_A2 == M_A3 && M_RegWrite);
							
	assign Stall_MD =	(mt | mf | md) && (md_start | md_busy);
	
	assign Stall_eret = D_eret && ((E_mtc0 && E_rd == 5'd14) || (M_mtc0 && M_rd == 5'd14));
	
	assign Stall = Stall_RS | Stall_RT | Stall_MD | Stall_eret;
	
	////////////////////////转发
	
	
	//转发更“新鲜”的数据
	assign D_MF_rs = (D_A1 == E_A3 && D_A1 != 0 && E_Tnew == 0 && E_RegWrite) ? E_reg :
							(D_A1 == M_A3 && D_A1 != 0 && M_Tnew == 0 && M_RegWrite) ? M_reg : D_rs_data;
							
	assign D_MF_rt = (D_A2 == E_A3 && D_A2 != 0 && E_Tnew == 0 && E_RegWrite) ? E_reg :
							(D_A2 == M_A3 && D_A2 != 0 && M_Tnew == 0 && M_RegWrite) ? M_reg : D_rt_data;

	assign E_MF_rs = (E_A1 == M_A3 && E_A1 != 0 && M_Tnew == 0 && M_RegWrite) ? M_reg :
							(E_A1 == W_A3 && E_A1 != 0 && W_Tnew == 0 && W_RegWrite) ? W_reg : E_rs_data;
	
	assign E_MF_rt = (E_A2 == M_A3 && E_A2 != 0 && M_Tnew == 0 && M_RegWrite) ? M_reg :
							(E_A2 == W_A3 && E_A2 != 0 && W_Tnew == 0 && W_RegWrite) ? W_reg : E_rt_data;
							
	assign M_MF_rt = (M_A2 == W_A3 && M_A2 != 0 && W_Tnew == 0 && W_RegWrite) ? W_reg : M_rt_data;
	 


endmodule
