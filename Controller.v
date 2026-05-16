`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:48:30 10/29/2024 
// Design Name: 
// Module Name:    Controller 
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
module Controller(
    input [31:0] Instr,
	 //分割解码
	 output [4:0] rs,
	 output [4:0] rt,
	 output [4:0] rd,
	 output [15:0] imm16,
	 output [25:0] imm26,
	 //Tuse,Tnew解码
	 output [2:0] rs_Tuse,
	 output [2:0] rt_Tuse,
	 output [2:0] E_Tnew,
	 output [2:0] M_Tnew,
	 output [2:0] W_Tnew,
	 //控制信号解码
    output [2:0] RegDst,
    output [1:0] ALUsrc,
    output [2:0] MemtoReg,
    output RegWrite,
    output MemWrite,
    output [2:0] PCsrc,
    output [2:0] ALUop,
	 output [1:0] EXTOp,
	 output [2:0] LWop,
	 output [2:0] MDop,
	 output md,
	 output mt,
	 output mf,
	 output mtc0,
	 output eret,
	 output syscall,
	 output RI,
	 output alu_ov,
	 output save,
	 output load
    );
	 
	 
	 //分割解码
	 assign rs = Instr[`rs];
	 assign rt = Instr[`rt];
	 assign rd = Instr[`rd];
	 assign imm16 = Instr[`imm16];
	 assign imm26 = Instr[`imm26];
	 
	 
	 wire special, add, sub, and_, or_, slt, sltu;
	 wire lui, addi, andi, ori;
	 wire lb, lh, lw, sb, sh, sw;
	 wire mult, multu, div, divu, mfhi, mflo, mthi, mtlo;
	 wire beq, bne, jal, jr, j;
	 wire cop0, mfc0;
	 wire nop;
	 
	 wire calc_r, calc_i, jump;
	 
	 assign cop0 = Instr[`op] == `cop0;
	 assign special = Instr[`op] == `R;
	 assign nop = Instr == 0;
	 
	 /////////////////calc_r
	 assign add = special && Instr[`funct] == `add;
	 assign sub = special && Instr[`funct] == `sub;
	 assign and_ = special && Instr[`funct] == `and_;
	 assign or_ = special && Instr[`funct] == `or_;
	 assign slt = special && Instr[`funct] == `slt;
	 assign sltu = special && Instr[`funct] == `sltu;
	 
	 assign calc_r = add | sub | and_ | or_ | slt | sltu;
	 
	 /////////////////lui
	 assign lui = Instr[`op] == `lui;
	 
	 ////////////////calc_i
	 assign ori = Instr[`op] == `ori;
	 assign addi = Instr[`op] == `addi;
	 assign andi = Instr[`op] == `andi;
	 
	 assign calc_i = ori | addi | andi;
	 
	 /////////////////jump
	 assign jr = special && Instr[`funct] == `jr;
	 assign beq = Instr[`op] == `beq;
	 assign bne = Instr[`op] == `bne;
	 assign jal = Instr[`op] == `jal;
	 assign j = 0; //不应该实现的指令
	 
	 /////////////////load and save
	 assign lw = Instr[`op] == `lw;
	 assign sw = Instr[`op] == `sw;
	 assign lb = Instr[`op] == `lb;
	 assign sb = Instr[`op] == `sb;
	 assign lh = Instr[`op] == `lh;
	 assign sh = Instr[`op] == `sh;
	 
	 assign load = lw | lb | lh;
	 assign save = sw | sb | sh;
	 
	 ///////////////mult and div
	 assign mult = special && Instr[`funct] == `mult;
	 assign multu = special && Instr[`funct] == `multu;
	 assign div = special && Instr[`funct] == `div;
	 assign divu = special && Instr[`funct] == `divu;
	 assign mfhi = special && Instr[`funct] == `mfhi;
	 assign mflo = special && Instr[`funct] == `mflo;
	 assign mthi = special && Instr[`funct] == `mthi;
	 assign mtlo = special && Instr[`funct] == `mtlo;
	 
	 assign md = mult | multu | div | divu;
	 assign mf = mfhi | mflo;
	 assign mt = mthi | mtlo;
	 
	 ////////////////special
	 assign syscall = special && Instr[`funct] == `syscall;
	 assign eret = cop0 && Instr[25:6] == `eret_sign && Instr[`funct] == `funct_eret;
	 assign mfc0 = cop0 && rs == `mfc0;
	 assign mtc0 = cop0 && rs == `mtc0;
	 
	 
	 assign RI = !(calc_r | lui | calc_i | jr | beq | bne | jal | load | save | md | mf | mt | nop | syscall | eret | mfc0 | mtc0);
	 assign alu_ov = add | addi | sub;
	 
	 
	 //Tuse,Tnew解码
	 //3'b111模拟无穷大
	 assign rs_Tuse = j | jal | lui | mf | mtc0 | mfc0 | syscall | eret ? 3'b111 :
							calc_r | calc_i | load | save | md | mt ? 3'b001 : 3'b000;
	 assign rt_Tuse = j | jr | jal | calc_i | mt | load | lui | mf | mfc0 | syscall | eret ? 3'b111 :
							save | mtc0 ? 3'b010 :
							calc_r | md ? 3'b001 : 3'b000;
	 assign E_Tnew = load | mfc0 ? 3'b010 :
							calc_r | calc_i | mf ? 3'b001 : 3'b000;
	 assign M_Tnew = load | mfc0 ? 3'b001 : 3'b000;
	 assign W_Tnew = 3'b000;
												
	 
	 //控制信号解码
	 
	 //RegDst 10 -> $ra/$31 01 -> $rd 00 -> $rt
	 //ALUsrc 01 -> imm32 00 -> GRF
	 //MemtoReg  110 -> cp0 101 -> lo 100 -> hi 011 -> PC + 8 010 -> imm16 || 16'h0000 001 -> DM 000 -> result of ALU
	 //RegWrite 1 -> yes 0 -> no
	 //MemWrite 1 -> yes 0 -> no
	 //PCsrc 101 -> eret 100 -> bne 011 -> jr 010 -> j | jal 01 -> beq 00 -> PC + 4
	 //ALUOp 101 -> sltu 100 -> slt 011 -> a & b 010 -> a | b 001 -> a - b 000 -> a + b
	 //EXTOp 10 -> imm || 16'h0000 01 -> sign 00 -> zero
	 //LWop 000 -> word 001 -> unsigend byte 010 -> signed byte 011 -> unsigned half word 100 -> signed half word 101 -> not save/load
	 
	 assign RegDst = jal ? 3'b010 :
						  calc_r | mf ? 3'b001 : 3'b000;
	 assign ALUsrc = (load | save | calc_i) ? 2'b01 : 2'b00;
	 assign MemtoReg = 	mfc0 ? 3'b110 :
								mflo ? 3'b101 :
								mfhi ? 3'b100 :
								jal ? 3'b011 :
								lui ? 3'b010 :
								load ? 3'b001 : 3'b000;
	 assign RegWrite = mfc0 | calc_i | calc_r | load | lui | jal | mf;
	 assign MemWrite = save;
	 assign PCsrc = 	bne ? 3'b100 :
							jr ? 3'b011 :
							j | jal ? 3'b010 :
							beq ? 3'b001 : 3'b000;
	 assign ALUop = 	sltu ? `ALU_sltu :
							slt ? `ALU_slt :
							and_ | andi ? `ALU_and :
							ori | or_ ? `ALU_or :
							sub ? `ALU_sub : `ALU_add;
	 assign EXTOp = lui ? 2'b10 :
						 load | save | beq | bne | addi ? 2'b01 : 2'b00;

	 assign LWop = (lw | sw) ? 3'b000 :
						(lb | sb) ? 3'b010 : 
						(lh | sh) ? 3'b100 : 3'b101;
							
	 assign MDop = mult ? `md_mult :
						multu ? `md_multu :
						div ? `md_div : 
						divu ? `md_divu :
						mthi ? `md_mthi : 
						mtlo ? `md_mtlo : `md_not;

endmodule
