`include "defines.v"
module if_id(
    input wire clk,
    input wire rst,
    input wire stall,    

    // if input
    input wire[31:0] if_pc,
    input wire[31:0] if_instr,

    // id output
    output reg[31:0] id_pc,
    output reg[31:0] id_instr
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        id_pc <= `ZeroWord;
        id_instr <= `ZeroWord;
    end else begin
        if(stall == 1'b0) begin
            id_pc <= if_pc;
            id_instr <= if_instr;
        end else ;
    end
end
endmodule