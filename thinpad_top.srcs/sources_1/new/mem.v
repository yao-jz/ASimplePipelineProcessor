`include "defines.v"
module mem(
    input wire rst,

    // from exe
    input wire[31:0] pc_i,
    input wire[31:0] result_i,
    input wire[31:0] b_i,
    input wire[31:0] instr_i,
    input wire[`RegAddrBus] waddr_i,
    input wire wreg_i,

    // mem result
    output reg[`RegAddrBus] waddr_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
    output reg[31:0] after_pc_o,
    output reg[31:0] read_data_o
);

always @(*) begin
    if(rst == `RstEnable) begin
        waddr_o = `NOPRegAddr;
        wreg_o = `WriteDisable;
        wdata_o = `ZeroWord;
        after_pc_o = pc_i;
        read_data_o = `ZeroWord;
    end else begin
        waddr_o = waddr_i;
        wreg_o =  wreg_i;
        wdata_o = result_i;
        // after_pc_o <= 
        // read_data_o <= 
    end
end

endmodule