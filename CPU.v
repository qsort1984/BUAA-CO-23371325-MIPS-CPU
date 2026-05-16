`timescale 1ns / 1ps
`include "define.v"
module CPU(
    input clk,
    input reset,
	 input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen,
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr,
	 input [5:0] HWInt,
	 output [31:0] macroscopic_pc,
	 output PrWE
    );

	//Controller
	wire [31:0] F_Instr, D_Instr, E_Instr, M_Instr, W_Instr;
	wire [31:0] F_PC, D_PC, E_PC, M_PC, W_PC;
	wire [5:0] opcode;
	wire [5:0] funct;
	wire [25:0] imm26;
	wire [15:0] imm16;
	wire [4:0] D_rs, D_rt, D_rd;
	wire [4:0] E_rs, E_rt, E_rd;
	wire [4:0] M_rs, M_rt, M_rd;
	wire [4:0] W_rs, W_rt, W_rd;
	wire beq_jump;
	
	wire [2:0] E_RegDst, M_RegDst, W_RegDst;
	wire [1:0] ALUsrc;
   wire [2:0] D_MemtoReg, E_MemtoReg, M_MemtoReg, W_MemtoReg;
   wire D_RegWrite, E_RegWrite, M_RegWrite, W_RegWrite;
   wire MemWrite;
   wire [2:0] PCsrc;
   wire [2:0] ALUop;
	wire [1:0] EXTOp;
	wire [2:0] LWop;
	wire [2:0] MDop;
	wire D_md, D_mt, D_mf;
	wire E_md, E_mt, E_mf;
	wire D_eret, M_eret;
	wire E_mtc0, M_mtc0;
	wire E_alu_ov;
	wire M_save, M_load;
	//EXT
	wire [31:0] D_imm32, E_imm32;
	//ALU
	wire [31:0] E_ALU_ans, M_ALU_ans;
	wire [31:0] b;
	wire E_overflow, M_overflow;
	//GRF
	wire [31:0] RegData;
	//PC
	wire [31:0] F_PC_tem;
	//NPC
	wire [31:0] nPC;
	//BE
	wire [3:0] byteen;
	//DM
	wire [31:0] MemAddr;
	wire [31:0] M_DM_data;
	//DE
	wire [31:0] Dout;
	//MULT_DIV
	wire [31:0] hi, lo;
	wire busy;
	//EXC
	wire F_exc_adel, M_exc_adel, M_exc_ades, D_exc_syscall, D_exc_ri, E_exc_ov;
	wire [4:0] F_exccode, D_exccode, E_exccode, M_exccode;
	wire [4:0] D_exccode_tem, E_exccode_tem, M_exccode_tem;
	//CP0
	wire [31:0] EPC;
	wire [31:0] CP0Out;
	wire CP0_WE;
	wire F_BD, D_BD, E_BD, M_BD;
	
	//Stall
	
	wire [2:0] rs_Tuse;
   wire [2:0] rt_Tuse; 
   wire [2:0] E_Tnew;
   wire [2:0] M_Tnew;
   wire [2:0] W_Tnew;
	wire [31:0] D_reg, E_reg, M_reg, W_reg;//将要写入寄存器的值
	wire [31:0] E_reg_tem, M_reg_tem;
	wire [4:0] D_A1;
	wire [4:0] D_A2;
	wire [4:0] E_A1;
	wire [4:0] E_A2;
	wire [4:0] E_A3;
	wire [4:0] M_A2;
	wire [4:0] M_A3;
	wire [4:0] W_A3;
   wire [31:0] D_rs_data;
   wire [31:0] D_rt_data;
   wire [31:0] E_rs_data;
   wire [31:0] E_rt_data; 
   wire [31:0] M_rt_data;
   wire Stall;
	wire [31:0] D_MF_rs;
   wire [31:0] D_MF_rt;
   wire [31:0] E_MF_rs;
   wire [31:0] E_MF_rt;
   wire [31:0] M_MF_rt;
	
	wire PC_EN;
	wire F_D_EN;
	wire D_E_Clr;
	
	assign PC_EN = ~Stall;
	assign F_D_EN = ~Stall;
	assign D_E_Clr = Stall;
	
	///////////////////////阻塞/转发
	
	stall stall (
    .rs_Tuse(rs_Tuse), 
    .rt_Tuse(rt_Tuse), 
    .E_Tnew(E_Tnew), 
    .M_Tnew(M_Tnew), 
    .W_Tnew(W_Tnew), 
    .D_A1(D_A1), 
    .D_A2(D_A2), 
    .E_A1(E_A1), 
    .E_A2(E_A2), 
    .E_A3(E_A3), 
    .M_A2(M_A2), 
    .M_A3(M_A3), 
    .W_A3(W_A3), 
    .E_reg(E_reg), 
    .M_reg(M_reg), 
    .W_reg(W_reg), 
    .E_RegWrite(E_RegWrite), 
    .M_RegWrite(M_RegWrite), 
    .W_RegWrite(W_RegWrite), 
    .D_rs_data(D_rs_data), 
    .D_rt_data(D_rt_data), 
    .E_rs_data(E_rs_data), 
    .E_rt_data(E_rt_data), 
    .M_rt_data(M_rt_data), 
    .Stall(Stall), 
    .D_MF_rs(D_MF_rs), 
    .D_MF_rt(D_MF_rt), 
    .E_MF_rs(E_MF_rs), 
    .E_MF_rt(E_MF_rt), 
    .M_MF_rt(M_MF_rt),
	 .md_start(E_md),
	 .md_busy(busy),
	 .md(D_md),
	 .mt(D_mt),
	 .mf(D_mf),
	 .D_eret(D_eret),
	 .E_mtc0(E_mtc0),
	 .M_mtc0(M_mtc0),
	 .E_rd(E_rd),
	 .M_rd(M_rd)
    );
	
	
	///////////////////////F
	PC F_pc (
	 .clk(clk), 
    .reset(reset), 
	 .Req(Req),
    .PC_EN(PC_EN), 
    .nPC(nPC), 
    .PC(F_PC_tem)
	 );
	 
	 assign F_PC = D_eret ? EPC : F_PC_tem;
	 
	 assign F_exc_adel = ((|F_PC[1:0]) | (F_PC < 32'h0000_3000 || F_PC > 32'h0000_6ffc)) && !D_eret;
	 
	 assign i_inst_addr = F_PC;
	 assign F_Instr = F_exc_adel ? 32'd0 : i_inst_rdata;
	 
	 assign F_exccode = F_exc_adel ? `exc_adel : `exc_none;
	 
	 ///////////////获得延迟槽指令信号
	 assign F_BD = PCsrc != 3'b000;
	
	////////////////////////D
	Controller D_controller (
    .Instr(D_Instr), 
    .rs(D_rs), 
    .rt(D_rt), 
    .rd(D_rd), 
    .imm16(imm16), 
    .imm26(imm26), 
    .rs_Tuse(rs_Tuse), 
    .rt_Tuse(rt_Tuse), 
	 .MemtoReg(D_MemtoReg),
    .RegWrite(D_RegWrite), 
    .PCsrc(PCsrc),  
    .EXTOp(EXTOp),
	 .md(D_md),
	 .mf(D_mf),
	 .mt(D_mt),
	 .eret(D_eret),
	 .syscall(D_exc_syscall),
	 .RI(D_exc_ri)
    );
	 
	 assign D_A1 = D_rs;
	 assign D_A2 = D_rt;
	 
	 assign D_reg = D_MemtoReg == 3'b011 ? D_PC + 8 : 
						 D_MemtoReg == 3'b010 ? D_imm32 : 0;
	 
	 F_D_Register F_D (
    .F_PC(F_PC), 
    .F_Instr(F_Instr), 
	 .F_exccode(F_exccode),
	 .F_BD(F_BD),
    .clk(clk), 
    .reset(reset), 
	 .Req(Req),
    .flush(F_D_EN), 
    .D_PC(D_PC), 
    .D_Instr(D_Instr),
	 .D_exccode(D_exccode_tem),
	 .D_BD(D_BD)
    );
	 
	 assign D_exccode = (D_exccode_tem != `exc_none) ? D_exccode_tem :
								D_exc_ri ? `exc_ri :
								D_exc_syscall ? `exc_syscall : `exc_none;
	 
	 GRF D_grf (
		.PC(W_PC), 
		.clk(clk), 
		.reset(reset), 
		.WE(W_RegWrite), 
		.A1(D_rs), 
		.A2(D_rt), 
		.A3(W_A3), 
		.WD(W_reg), 
		.RD1(D_rs_data), 
		.RD2(D_rt_data)
    );
	 
	 assign w_grf_we = W_RegWrite;
    assign w_grf_addr = W_A3;
    assign w_grf_wdata = W_reg;
    assign w_inst_addr = W_PC;
	 
	 EXT D_ext (
    .in(imm16), 
    .EXTOp(EXTOp), 
    .out(D_imm32)
    );
	 
	 CMP D_cmp (
    .a(D_MF_rs), 
    .b(D_MF_rt), 
    .equal_sign(beq_jump)
    );
	 
	 NPC D_npc (
	 .F_PC(F_PC),
    .D_PC(D_PC), 
    .beq_jump(beq_jump), 
    .PCsrc(PCsrc), 
    .grf_rs(D_MF_rs), 
    .imm32(D_imm32), 
    .instr_index(imm26),
	 .Req(Req),
	 .eret(D_eret),
	 .EPC(EPC),
    .nPC(nPC)
    );
	 
	 /////////////////////E
	 Controller E_controller (
    .Instr(E_Instr), 
    .rs(E_rs), 
    .rt(E_rt), 
    .rd(E_rd), 
    .E_Tnew(E_Tnew),  
    .RegDst(E_RegDst), 
    .ALUsrc(ALUsrc),
	 .MemtoReg(E_MemtoReg), 
    .RegWrite(E_RegWrite),  
    .ALUop(ALUop),
	 .MDop(MDop),
	 .md(E_md),
	 .mt(E_mt),
	 .mf(E_mf),
	 .mtc0(E_mtc0),
	 .alu_ov(E_alu_ov)
    );
	 
	 assign E_A1 = E_rs;
	 assign E_A2 = E_rt;
	 
	 assign E_A3 = E_RegDst == 3'b010 ?	5'b11111 :
						E_RegDst == 3'b001 ? E_rd : E_rt;
						
	 assign E_reg_tem =  E_MemtoReg == 3'b101 ? lo :
								E_MemtoReg == 3'b100 ? hi :
								E_MemtoReg == 3'b000 ? E_ALU_ans : E_reg;
	 
	 D_E_Register D_E (
    .D_PC(D_PC), 
    .D_Instr(D_Instr), 
    .D_grf_rs(D_MF_rs), 
    .D_grf_rt(D_MF_rt),
	 .D_reg(D_reg),
    .D_imm32(D_imm32),
	 .D_exccode(D_exccode),
	 .D_BD(D_BD),
    .clk(clk), 
    .reset(reset),
	 .Req(Req),
    .flush(D_E_Clr), 
    .E_PC(E_PC), 
    .E_Instr(E_Instr), 
    .E_grf_rs(E_rs_data), 
    .E_grf_rt(E_rt_data), 
	 .E_reg(E_reg),
    .E_imm32(E_imm32),
	 .E_exccode(E_exccode_tem),
	 .E_BD(E_BD)
    );
	 
	 assign E_exccode = (E_exccode_tem != `exc_none) ? E_exccode_tem :
								E_exc_ov ? `exc_ov : `exc_none;
	 
	 ALU E_alu (
		.a(E_MF_rs), 
		.b(b), 
		.ALUop(ALUop),  
		.result(E_ALU_ans),
		.overflow(E_overflow)
    );
	 
	 assign E_exc_ov = E_overflow && E_alu_ov;
	 
	 MULT_DIV E_mult_div (
    .clk(clk), 
    .reset(reset), 
	 .Req(Req),
    .start(E_md), 
    .A(E_MF_rs), 
    .B(E_MF_rt), 
    .MDop(MDop), 
    .hi(hi), 
    .lo(lo), 
    .busy(busy)
    );
	 
	 assign b = ALUsrc == 2'b01 ? E_imm32 : E_MF_rt;
	 
	 
	 ////////////////////////M
	 Controller M_controller (
    .Instr(M_Instr), 
    .rs(M_rs), 
    .rt(M_rt), 
    .rd(M_rd),   
    .M_Tnew(M_Tnew), 
    .RegDst(M_RegDst), 
    .MemtoReg(M_MemtoReg), 
    .RegWrite(M_RegWrite),
	 .MemWrite(MemWrite),
	 .LWop(LWop),
	 .save(M_save),
	 .load(M_load),
	 .mtc0(M_mtc0),
	 .eret(M_eret)
    );
	 
	 assign M_A2 = M_rt;
	 assign M_A3 = M_RegDst == 3'b010 ?	5'b11111 :
						M_RegDst == 3'b001 ? M_rd : M_rt;
						
	 assign M_reg_tem =  M_MemtoReg == 3'b110 ? CP0Out :
								M_MemtoReg == 3'b001 ? M_DM_data : M_reg;
	 
	 E_M_Register E_M (
    .E_PC(E_PC), 
    .E_Instr(E_Instr),
	 .E_reg(E_reg_tem),
    .E_grf_rt(E_MF_rt), 
    .E_ALU_ans(E_ALU_ans),
	 .E_exccode(E_exccode),
	 .E_overflow(E_overflow),
	 .E_BD(E_BD),
    .clk(clk), 
    .reset(reset), 
	 .Req(Req),
    .M_PC(M_PC), 
    .M_Instr(M_Instr),
	 .M_reg(M_reg),
    .M_grf_rt(M_rt_data), 
    .M_ALU_ans(M_ALU_ans),
	 .M_exccode(M_exccode_tem),
	 .M_overflow(M_overflow),
	 .M_BD(M_BD)
    );
	 
	 assign M_exccode = (M_exccode_tem != `exc_none) ? M_exccode_tem :
								M_exc_adel ? `exc_adel :
								M_exc_ades ? `exc_ades : `exc_none;
	 
	 BE M_be (
    .MemAddr(MemAddr), 
	 .LWop(LWop),
	 .MemWrite(MemWrite),
    .m_data_byteen(byteen)
    );
	 
	 ///////////
	 wire be_align, be_timer, be_ov, be_outofrange;
	 
	 assign be_align = M_load && ((LWop == 3'b000 && |MemAddr[1:0]) || (LWop == 3'b100 && MemAddr[0])); 
	 assign be_timer = M_load && LWop != 3'b000 && ((MemAddr >= 32'h0000_7f00 && MemAddr <= 32'h0000_7f0b) || (MemAddr >= 32'h0000_7f10 && MemAddr <= 32'h0000_7f1b));
	 assign be_ov = M_load && M_overflow; 
	 assign be_outofrange = M_load && !((MemAddr >= 32'h0000_0000 && MemAddr <= 32'h0000_2fff) ||
													(MemAddr >= 32'h0000_7f00 && MemAddr <= 32'h0000_7f0b) ||
													(MemAddr >= 32'h0000_7f10 && MemAddr <= 32'h0000_7f1b) ||
													(MemAddr >= 32'h0000_7f20 && MemAddr <= 32'h0000_7f23));
	 
	 assign M_exc_adel = be_align | be_timer | be_ov | be_outofrange;
	 /////////
	 
	 DE M_de (
    .A(MemAddr[1:0]), 
    .Din(m_data_rdata), 
    .Op(LWop), 
    .Dout(Dout)
    );
	 
	 /////////
	 wire de_align, de_timer, de_ov, de_outofrange, de_timer_count;
	 
	 assign de_align = M_save && ((LWop == 3'b000 && |MemAddr[1:0]) || (LWop == 3'b100 && MemAddr[0])); 
	 assign de_timer = M_save && LWop != 3'b000 && ((MemAddr >= 32'h0000_7f00 && MemAddr <= 32'h0000_7f0b) || (MemAddr >= 32'h0000_7f10 && MemAddr <= 32'h0000_7f1b));
	 assign de_ov = M_save && M_overflow; 
	 assign de_timer_count = M_save && (MemAddr[3:2] == 2) && ((MemAddr >= 32'h0000_7f00 && MemAddr <= 32'h0000_7f0b) || (MemAddr >= 32'h0000_7f10 && MemAddr <= 32'h0000_7f1b));
	 assign de_outofrange = M_save && !((MemAddr >= 32'h0000_0000 && MemAddr <= 32'h0000_2fff) ||
													(MemAddr >= 32'h0000_7f00 && MemAddr <= 32'h0000_7f0b) ||
													(MemAddr >= 32'h0000_7f10 && MemAddr <= 32'h0000_7f1b) ||
													(MemAddr >= 32'h0000_7f20 && MemAddr <= 32'h0000_7f23));
	 
	 
	 
	 assign M_exc_ades = de_align | de_timer | de_ov | de_outofrange | de_timer_count;
	 ////////////
	 
	 assign MemAddr = M_ALU_ans;
	 assign m_data_addr = MemAddr;
	 
	 
	 assign m_data_wdata =  byteen == 4'b1100 ? {M_MF_rt[15:0], M_MF_rt[31:16]} : 
									byteen == 4'b0010 ? {M_MF_rt[23:16], M_MF_rt[15:8], M_MF_rt[7:0], M_MF_rt[31:24]} : 
									byteen == 4'b0100 ? {M_MF_rt[15:8], M_MF_rt[7:0], M_MF_rt[31:24], M_MF_rt[23:16]} :
									byteen == 4'b1000 ? {M_MF_rt[7:0], M_MF_rt[31:24], M_MF_rt[23:16], M_MF_rt[15:8]} : M_MF_rt;
	 
	 assign m_data_byteen = Req ? 4'h0 : byteen;
	 assign PrWE = byteen != 4'h0;
									
	 assign m_inst_addr = M_PC;
	 assign macroscopic_pc = M_PC;
	 assign M_DM_data = Dout;
	 
	 CP0 M_cp0 (
    .clk(clk), 
    .reset(reset), 
    .WE(CP0_WE), 
    .CP0Addr(M_rd), 
    .CP0In(M_MF_rt), 
    .CP0Out(CP0Out), 
    .VPC(M_PC), 
    .BDIn(M_BD), 
    .ExcCode(M_exccode), 
    .HWInt(HWInt), 
    .EXLClr(M_eret), 
    .Req(Req), 
    .EPC(EPC)
    );
	 
	 assign CP0_WE = M_mtc0;
	 
	 
	 ///////////////////W
	 Controller W_controller (
    .Instr(W_Instr), 
    .rs(W_rs), 
    .rt(W_rt), 
    .rd(W_rd),  
    .W_Tnew(W_Tnew), 
    .RegDst(W_RegDst),  
    .MemtoReg(W_MemtoReg), 
    .RegWrite(W_RegWrite)
    );
	 
	 assign W_A3 = W_RegDst == 3'b010 ?	5'b11111 :
						W_RegDst == 3'b001 ? W_rd : W_rt;
	 
	 M_W_Register M_W (
    .M_PC(M_PC), 
    .M_Instr(M_Instr), 
	 .M_reg(M_reg_tem),
    .clk(clk), 
    .reset(reset),  
	 .Req(Req),
    .W_PC(W_PC), 
    .W_Instr(W_Instr), 
	 .W_reg(W_reg)
    );
							

endmodule
