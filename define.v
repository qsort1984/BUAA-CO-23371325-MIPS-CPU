`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:54:43 11/05/2024 
// Design Name: 
// Module Name:    define 
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
`define DEBUG_DEV_DATA 32'h0000_0000
`define DEV0_START_ADDR 32'h0000_7f00
`define DEV0_END_ADDR 32'h0000_7f0b
`define DEV1_START_ADDR 32'h0000_7f10
`define DEV1_END_ADDR 32'h0000_7f1b
`define DM_START_ADDR 32'h0000_0000
`define DM_END_ADDR 32'h0000_2ffff
`define INTERRUPT_START_ADDR 32'h0000_7f20
`define INTERRUPT_END_ADDR 32'h0000_7f23

`define cp0_sr 5'd12
`define cp0_cause 5'd13
`define cp0_epc 5'd14

`define exc_none 5'd1
`define exc_int 5'd0
`define exc_adel 5'd4
`define exc_ades 5'd5
`define exc_syscall 5'd8
`define exc_ri 5'd10
`define exc_ov 5'd12

`define exc_pc 32'h0000_4180

`define cop0 6'b010000
`define eret_sign 20'b1000_0000_0000_0000_0000
`define funct_eret 6'b011000
`define mfc0 5'b00000
`define mtc0 5'b00100
`define syscall 6'b001100

//calc_r
//rd = f(rs, rt)
`define R 6'b000000
`define add 6'b100000
`define sub 6'b100010
`define and_ 6'b100100
`define or_ 6'b100101
`define slt 6'b101010
`define sltu 6'b101011

//lui
//rt = f(imm)
`define lui 6'b001111

//calc_i
//rt = f(rs, imm)
`define addi 6'b001000
`define andi 6'b001100
`define ori 6'b001101

//load and save
`define lb 6'b100000
`define lh 6'b100001
`define lw 6'b100011
`define sb 6'b101000
`define sh 6'b101001
`define sw 6'b101011

//mult and div(special == 6'b000000)
`define mult 	6'b011000
`define multu 	6'b011001
`define div 	6'b011010
`define divu 	6'b011011
`define mfhi	6'b010000
`define mflo	6'b010010
`define mthi 	6'b010001
`define mtlo 	6'b010011

//jump
`define beq 6'b000100
`define bne 6'b000101
`define jal 6'b000011
`define jr 6'b001000
`define j 6'b000010 //P6不要求实现

`define ALU_add 3'b000
`define ALU_sub 3'b001
`define ALU_or 3'b010
`define ALU_and 3'b011
`define ALU_slt 3'b100
`define ALU_sltu 3'b101

`define mult_cycle 5
`define div_cycle 10

`define md_mult 3'b000
`define md_multu 3'b001
`define md_div 3'b010
`define md_divu 3'b011
`define md_mthi 3'b100
`define md_mtlo 3'b101
`define md_not 3'b110

`define op 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define shamt 10:6
`define funct 5:0
`define imm16 15:0
`define imm26 25:0
