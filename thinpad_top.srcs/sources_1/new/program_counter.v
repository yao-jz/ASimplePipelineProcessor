`include "defines.v"
module program_counter(
    input wire clk,
    input wire rst,
    input wire stall,   
    output reg[31:0] instr_addr 
);
localparam START_ADDR = 32'h80000000;
reg [31:0] next_addr;
always @(posedge clk) begin
    if(rst) begin
        next_addr <= START_ADDR;
        instr_addr <= START_ADDR;
    end else begin
        if(stall == 1'b0) begin 
            next_addr <= next_addr + 4;
            instr_addr <= next_addr;
        end else ;
    end
end
endmodule