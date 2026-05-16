# 带中断/异常与定时器外设的流水线 MIPS CPU（Verilog / ISE）

本工程是一个面向课程实验的 MIPS-like 处理器系统，采用经典 5 级流水线（F/D/E/M/W），实现了数据前递与暂停（stall），并支持异常/中断处理（CP0 + `eret`），通过总线桥接（Bridge）实现对数据存储器（DM）与两个定时器外设（Timer0/Timer1）的存取。

项目入口与工程文件：
- 顶层模块：[mips.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/mips.v)
- ISE 工程：[P7.xise](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/P7.xise)

## 1. 总体结构

顶层 [mips](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/mips.v) 将系统拆为三块：
- [CPU](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/CPU.v)：5 级流水线 CPU，本身只看到“处理器数据总线”（PrAddr/PrWD/PrRD/PrWE）。
- [Bridge](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/Bridge.v)：地址译码与外设选择，把 CPU 的访问路由到 DM / Timer0 / Timer1 / 中断应答端口。
- [TC（标准定时器）](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/P7_standard_timer_2019.v)：实现两个实例 Timer0/Timer1，产生 IRQ，接入 CPU 的硬件中断输入。

CPU 内部的典型模块包括：
- 指令译码/控制：[Controller](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/Controller.v)
- 寄存器堆：[GRF](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/GRF.v)
- 运算单元：[ALU](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/ALU.v)，乘除单元：[MULT_DIV](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/MULT_DIV.v)
- 冒险处理：暂停与前递 [stall](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/stall.v)
- CP0/异常中断：[CP0](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/CP0.v)，下一条 PC 计算：[NPC](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/NPC.v)
- 访存字节使能与读数据扩展：[BE](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/BE.v) / [DE](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/DE.v)
- 流水寄存器：F_D/D_E/E_M/M_W（同目录下 `*_Register.v`）

## 2. 指令子集（Controller 解码）

在 [define.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/define.v) 与 [Controller.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/Controller.v) 中可看到支持的指令类型，主要包括：
- 算术/逻辑：`add`, `sub`, `and`, `or`, `slt`, `sltu`
- 立即数：`addi`, `andi`, `ori`, `lui`
- 访存：`lw`, `sw`, `lb`, `sb`, `lh`, `sh`（配套字节使能与符号/零扩展）
- 分支/跳转：`beq`, `bne`, `jr`, `jal`
- 乘除与 HI/LO：`mult`, `multu`, `div`, `divu`, `mfhi`, `mflo`, `mthi`, `mtlo`
- 特权/异常：`mfc0`, `mtc0`, `syscall`, `eret`

## 3. 地址空间与外设映射（Bridge）

地址译码常量在 [define.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/define.v)：
- DM（数据存储器）：`0x0000_0000 ~ 0x0000_2FFF`
- Timer0 寄存器窗口：`0x0000_7F00 ~ 0x0000_7F0B`
- Timer1 寄存器窗口：`0x0000_7F10 ~ 0x0000_7F1B`
- 中断应答窗口（用于写回“中断已处理”）：`0x0000_7F20 ~ 0x0000_7F23`

CPU 在 M 级把 ALU 结果作为访存地址，并对对齐/越界/非法访问做异常判定（见 [CPU.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/CPU.v) 中 `M_exc_adel/M_exc_ades` 的组合逻辑）。

定时器 [TC](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/P7_standard_timer_2019.v) 的寄存器（按 `Addr[3:2]` 选择）：
- `0`：CTRL（`[0]` 使能计数；`[2:1]` 模式；`[3]` 中断输出使能）
- `1`：PRESET（装载值）
- `2`：COUNT（计数值）

## 4. 异常/中断与 CP0

异常/中断相关关键点：
- 异常入口地址：`0x0000_4180`（见 [define.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/define.v) 的 `exc_pc`）
- 取指地址范围检查：PC 复位为 `0x0000_3000`，取指合法范围约束在 `0x3000 ~ 0x6FFC`（见 [CPU.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/CPU.v) 的 `F_exc_adel`）
- CP0 记录 `SR/Cause/EPC`，支持 `mfc0/mtc0/eret`（见 [CP0.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/CP0.v)）
- `BD`（延迟槽标记）在异常进入时写入 `Cause[31]`，并相应调整 EPC

硬件中断输入来自：
- 顶层外部 `interrupt`（拼接到 CPU 的 `HWInt`）
- Timer0/Timer1 的 IRQ（同样拼接进 `HWInt`）

## 5. 仿真用例

根目录下提供了两个仿真 testbench：
- [non_interruption.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/non_interruption.v)
- [interruption.v](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/interruption.v)

它们会从 [code.txt](file:///c:/Xilinx/14.7/ISE_DS/ISE_EXPERIMENT/P7/code.txt) 用 `$readmemh` 加载指令，并在仿真时通过 `$display` 打印寄存器写回与数据写入行为；其中 `interruption.v` 会在宏观 PC 到达特定地址时拉起外部中断，并在观测到写 `0x7F20` 后撤销中断。

