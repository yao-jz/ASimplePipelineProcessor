// *****************************************全局****************************************

`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 6:0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

// *************************************具体指令***************************************

// AluOp
// next index : 7'h21
// 已经做的用 // 标记出
`define OP_NOP 7'h0
// R
`define OP_ADD 7'h1     
`define OP_SUB 7'h2     
`define OP_SLL 7'h3     
`define OP_SLT 7'h4
`define OP_SLTU 7'h5
`define OP_XOR 7'h6     
`define OP_SRL 7'h7     
`define OP_SRA 7'h8     
`define OP_OR 7'h9     
`define OP_AND 7'h9     
// I
`define OP_ADDI 7'ha     
`define OP_SLTI 7'hb
`define OP_SLTIU 7'hc
`define OP_XORI 7'hd     
`define OP_ORI 7'he    
`define OP_ANDI 7'hf     
`define OP_SLLI 7'h10     
`define OP_SRLI 7'h11    
`define OP_SRAI 7'h12     
`define OP_LW 7'h13     
`define OP_JALR 7'h14
// S
`define OP_SW 7'h15     
`define OP_SB 7'h20     
// B
`define OP_BEQ 7'h16     
`define OP_BNE 7'h17
`define OP_BLT 7'h18
`define OP_BGE 7'h19
`define OP_BLTU 7'h1a
`define OP_BGEU 7'h1b
// J
`define OP_JAL 7'h1c
// U
`define OP_LUI 7'h1d
`define OP_AUIPC 7'h1e


// ******************************************指令储存器ROM有关的宏定义********************************************

`define InstAddrBus 31:0
`define InstBus 31:0

// ************************通用储存器Regfile有关宏定义******************************************

`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000