`default_nettype none
`timescale 1ns / 1ps
`include "ops.v"

module decoder(
    input wire[31:0]        inst,
    output wire[4:0]        rs1,
    output wire[4:0]        rs2,
    output wire[4:0]        rd,
    output reg[6:0]         op,
    output reg[31:0]        imm,
    output reg              imm_select
    );
    
    wire sign;
    wire[19:0] sign_ext;
    assign sign = inst[31];
    assign sign_ext = {20{sign}};
    assign rd = inst[11:7];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];

    always @(*) begin
        op = `OP_INVALID;
        imm = 32'h0;
        imm_select = 1'b0;

        case(inst[6:0])
            7'b0110011: begin  // R
                case({inst[31:25], inst[14:12]})
                    10'b0000000_000: op = `OP_ADD;
                    10'b0100000_000: op = `OP_SUB;
                    10'b0000000_001: op = `OP_SLL;
                    10'b0000000_010: op = `OP_SLT;
                    10'b0000000_011: op = `OP_SLTU;
                    10'b0000000_100: op = `OP_XOR;
                    10'b0000000_101: op = `OP_SRL;
                    10'b0100000_101: op = `OP_SRA;
                    10'b0000000_110: op = `OP_OR;
                    10'b0000000_111: op = `OP_AND;
                    default: ;
                endcase
            end
            7'b0010011: begin   // I operate imme
                imm = {sign_ext, inst[31:20]};
                imm_select = 1'b1;
                case(inst[14:12])
                    3'b000: op = `OP_ADDI;
                    3'b010: op = `OP_SLTI;
                    3'b011: op = `OP_SLTIU;
                    3'b100: op = `OP_XORI;
                    3'b110: op = `OP_ORI;
                    3'b111: op = `OP_ANDI;
                    default: ;
                endcase
            end
            7'b0000011: begin // I LW
                imm = {sign_ext, inst[31:20]};
                imm_select = 1'b1;
                case(inst[14:12])
                    3'b010: op = `OP_LW;
                    default: ;
                endcase
            end
            7'b1100111: begin   // JALR
                imm = {sign_ext, inst[31:20]};
                imm_select = 1'b1;
                case(inst[14:12])
                    3'b000: op = `OP_JALR;
                    default: ;
                endcase
            end
            7'b0100011: begin // S
                imm = {sign_ext, inst[31:25], inst[11:7]};
                imm_select = 1'b1;
                case(inst[14:12])
                    3'b010: op = `OP_SW;
                    3'b000: op = `OP_SB;
                    default: ;
                endcase
            end
            7'b1100011: begin // B
                imm = {
                    sign_ext,
                    inst[7],inst[30:25],inst[11:8],1'b0
                };
                imm_select = 1'b1;
                case(inst[14:12])
                    3'b000: op = `OP_BEQ;
                    3'b001: op = `OP_BNE;
                    3'b100: op = `OP_BLT;
                    3'b101: op = `OP_BGE;
                    3'b110: op = `OP_BLTU;
                    3'b111: op = `OP_BGEU;
                    default: ;
                endcase
            end
            7'b0110111: begin   
                imm = {inst[31:12],12'b0};
                imm_select = 1'b1;
                op = `OP_LUI;
            end
            7'b0010111: begin
                imm = {inst[31:12],12'b0};
                imm_select = 1'b1;
                op = `OP_AUIPC;
            end
            default: ;
        endcase
    end 

endmodule