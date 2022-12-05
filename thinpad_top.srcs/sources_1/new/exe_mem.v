`include "defines.v"
module exe_mem(
    input wire clk,
    input wire rst,
    input wire stall,   

    // exe input 
    input wire[31:0] exe_pc,
    input wire[31:0] exe_result,
    input wire[31:0] exe_b,
    input wire[31:0] exe_instr,
    input wire[`RegAddrBus] exe_waddr,
    input wire exe_wreg,

    // mem input
    output reg[31:0] mem_pc,
    output reg[31:0] mem_result,
    output reg[31:0] mem_b,
    output reg[31:0] mem_instr,
    output reg[`RegAddrBus] mem_waddr,
    output reg mem_wreg
);
always @(posedge clk) begin
    if(rst) begin
        mem_pc <= 32'b0;
        mem_result <= 32'b0;
        mem_b <= 32'b0;
        mem_instr <= 32'b0;
        mem_waddr <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
    end else begin
        if(stall == 1'b0) begin
            mem_pc <= exe_pc;
            mem_result <= exe_result;
            mem_b <= exe_b;
            mem_instr <= exe_instr;
            mem_waddr <= exe_waddr;
            mem_wreg <= exe_wreg;
        end else ;
    end
end
endmodule