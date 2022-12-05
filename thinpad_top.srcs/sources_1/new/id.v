`include "defines.v"

module id(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    // from regfile
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    // out to regfile
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    // out to exe
    output reg[`AluOpBus] aluop_o,
    output reg[`RegBus] reg1_o,     // op1
    output reg[`RegBus] reg2_o,     // op2
    output reg[`RegAddrBus] waddr_o,
    output reg wreg_o,
    output reg[31:0]        imm,
    output reg              imm_select,
    output wire[`InstAddrBus] pc_o,
    output wire[`InstBus] inst_o
);
assign pc_o = pc_i;
assign inst_o = inst_i;
wire sign;
wire[19:0] sign_ext;
assign sign = inst_i[31];
assign sign_ext = {20{sign}};
reg instvalid;

// ******************************译码*********************************
always @(*) begin
    if(rst == `RstEnable) begin
        aluop_o <= `OP_NOP;
        waddr_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;
        imm_select <= 1'b0;
    end else begin
        aluop_o <= `OP_NOP;
        waddr_o <= inst_i[11:7];
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[19:15];
        reg2_addr_o <= inst_i[24:20];
        imm <= `ZeroWord;
        case (inst_i[6:0])
            7'b0110011: begin
                case({inst_i[31:25], inst_i[14:12]})
                    10'b0000000_000: aluop_o = `OP_ADD;
                    10'b0100000_000: aluop_o = `OP_SUB;
                    10'b0000000_001: aluop_o = `OP_SLL;
                    10'b0000000_010: aluop_o = `OP_SLT;
                    10'b0000000_011: aluop_o = `OP_SLTU;
                    10'b0000000_100: aluop_o = `OP_XOR;
                    10'b0000000_101: aluop_o = `OP_SRL;
                    10'b0100000_101: aluop_o = `OP_SRA;
                    10'b0000000_110: aluop_o = `OP_OR;
                    10'b0000000_111: aluop_o = `OP_AND;
                    default: ;
                endcase
            end
            7'b0010011: begin
                imm = {sign_ext, inst_i[31:20]};
                imm_select = 1'b1;
                wreg_o <= `WriteEnable;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                waddr_o <= inst_i[11:7];
                instvalid <= `InstValid;
                case(inst_i[14:12])
                    3'b000: aluop_o = `OP_ADDI;
                    3'b010: aluop_o = `OP_SLTI;
                    3'b011: aluop_o = `OP_SLTIU;
                    3'b100: aluop_o = `OP_XORI;
                    3'b110: aluop_o = `OP_ORI;
                    3'b111: aluop_o = `OP_ANDI;
                    default: ;
                endcase
            end
            default: ;
        endcase
    end
end

// *******************************确定计算的源操作�?

always @(*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;
    end else if(reg1_read_o == 1'b0) begin
        reg1_o <= imm;
    end else begin
        reg1_o <= `ZeroWord;
    end
end

always @(*) begin
    if(rst == `RstEnable) begin
        reg2_o = `ZeroWord;
    end else if(reg2_read_o == 1'b1) begin
        reg2_o = reg1_data_i;
    end else if(reg2_read_o == 1'b0) begin
        reg2_o = imm;
    end else begin
        reg2_o = `ZeroWord;
    end
end


endmodule