`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:07:19 10/29/2024 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3:0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3:0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4:0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
	);
	
	wire [31:0] DEV_Addr;
	wire [31:0] DEV_WD;
	wire [31:0] PrRD, DEV0_RD, DEV1_RD;
	wire PrWE, DEV0_WE, DEV1_WE;
	
	wire Stop0, Stop1;
	
	wire [3:0] byteen;
	
	CPU CPU (
    .clk(clk), 
    .reset(reset), 
    .i_inst_rdata(i_inst_rdata), 
    .m_data_rdata(PrRD), 
    .i_inst_addr(i_inst_addr), 
    .m_data_addr(m_data_addr), 
    .m_data_wdata(m_data_wdata), 
    .m_data_byteen(byteen), 
    .m_inst_addr(m_inst_addr), 
    .w_grf_we(w_grf_we), 
    .w_grf_addr(w_grf_addr), 
    .w_grf_wdata(w_grf_wdata), 
    .w_inst_addr(w_inst_addr),
	 .HWInt({3'b000, interrupt, Stop1, Stop0}),
	 .macroscopic_pc(macroscopic_pc),
	 .PrWE(PrWE)
    );
	 
	 Bridge Bridge (
    .PrAddr(m_data_addr), 
    .PrWD(m_data_wdata), 
    .PrWE(PrWE), 
    .PrRD(PrRD), 
    .DM_RD(m_data_rdata), 
    .DEV0_RD(DEV0_RD), 
    .DEV1_RD(DEV1_RD),  
    .DEV0_WE(DEV0_WE), 
    .DEV1_WE(DEV1_WE), 
    .DEV_Addr(DEV_Addr), 
    .DEV_WD(DEV_WD),
	 .byteen(byteen),
    .m_data_byteen(m_data_byteen), 
    .m_int_addr(m_int_addr), 
    .m_int_byteen(m_int_byteen)
    );

	 TC Timer0 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DEV_Addr[31:2]), 
    .WE(DEV0_WE), 
    .Din(DEV_WD), 
    .Dout(DEV0_RD), 
    .IRQ(Stop0)
    );
	 
	TC Timer1 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DEV_Addr[31:2]), 
    .WE(DEV1_WE), 
    .Din(DEV_WD), 
    .Dout(DEV1_RD), 
    .IRQ(Stop1)
    );



endmodule
