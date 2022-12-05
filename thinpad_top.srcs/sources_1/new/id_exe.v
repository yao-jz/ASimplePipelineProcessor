`include "defines.v"
module id_exe(
    input wire clk,
    input wire rst,
    input wire stall,   

    // id input
    input wire[6:0] id_aluop,
    input wire[31:0] id_reg1,
    input wire[31:0] id_reg2,
    input wire[31:0] id_instr,
    input wire[31:0] id_pc,
    input wire[`RegAddrBus] id_waddr,
    input wire id_wreg,

    // exe output
    output reg[6:0] exe_aluop,
    output reg[31:0] exe_reg1,
    output reg[31:0] exe_reg2,
    output reg[31:0] exe_instr,
    output reg[31:0] exe_pc,
    output reg[`RegAddrBus] exe_waddr,
    output reg exe_wreg
);

always @ (posedge clk) begin
    if(rst) begin
        exe_aluop <= 7'b0;
        exe_reg1 <= 32'b0;
        exe_reg2 <= 32'b0;
        exe_instr <= 32'b0;
        exe_pc <= 32'b0;
        exe_waddr <= `NOPRegAddr;
        exe_wreg <= `WriteDisable;
    end else begin
        if(stall == 1'b0) begin
            exe_aluop <= id_aluop;
            exe_reg1 <= id_reg1;
            exe_reg2 <= id_reg2;
            exe_instr <= id_instr;
            exe_pc <= id_pc;
            exe_waddr <= id_waddr;
            exe_wreg <= id_wreg;
        end else ;
    end
end
endmodule