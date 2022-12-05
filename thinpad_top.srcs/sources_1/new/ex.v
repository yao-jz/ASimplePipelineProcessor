`include "defines.v"
module ex(
    input wire rst,

    // id_exe send
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] waddr_i,
    input wire wreg_i,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] instr_i,

    // exe result
    output reg[`RegAddrBus] waddr_o,
    output reg wreg_o,
    output wire[`InstAddrBus] pc_o,
    output wire[`InstBus] instr_o,
    output reg[`RegBus] wdata_o,
    output reg[`RegBus] b_o
    // output reg flag,

);
assign pc_o = pc_i;
assign instr_o = instr_i;
reg [`RegBus] result;

// *****************************运算***********************************
always @(*) begin
    if(rst == `RstEnable) begin
        result = `ZeroWord;
    end else begin
        case (aluop_i)
            `OP_LW, `OP_SW, `OP_SB, `OP_ADD, `OP_ADDI, `OP_BEQ, `OP_BNE, `OP_LUI: begin
                result = reg1_i + reg2_i;
                // flag <= ((~a[15])&(~b[15])&r[15])|(a[15]&b[15]&(~r[15]));
            end
            `OP_SUB: begin
                result = reg1_i - reg2_i;
            end
            `OP_AND, `OP_ANDI: begin
                result = reg1_i & reg2_i;
            end
            `OP_OR, `OP_ORI: begin
                result = reg1_i | reg2_i;
            end
            `OP_XOR, `OP_XORI: begin
                result = reg1_i ^ reg2_i;
            end
            `OP_SLL, `OP_SLLI: begin
                result = reg1_i << reg2_i;
            end
            `OP_SRL, `OP_SRLI: begin
                result = reg1_i >> reg2_i;
            end
            `OP_SRA, `OP_SRAI: begin
                result = ($signed(reg1_i)) >>> reg2_i;
            end
            default: begin
                result = `ZeroWord;
            end
        endcase
    end
end

//**********************运算结果的处�?********************
always @(*) begin
    waddr_o = waddr_i;
    wreg_o = wreg_i;
    wdata_o = result;
    b_o = reg2_i;
end

endmodule