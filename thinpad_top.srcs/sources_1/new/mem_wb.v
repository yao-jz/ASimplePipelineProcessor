module mem_wb(
    input wire clk,
    input wire rst,
    input wire stall,   

    // mem input
    input wire[`RegBus] mem_wdata,
    input wire[31:0] mem_pc,
    input wire[31:0] mem_rdata,
    input wire mem_wreg,
    input wire[4:0] mem_waddr,

    // wb output
    output reg[`RegBus] wb_wdata,
    output reg[31:0] wb_pc,
    output reg[31:0] wb_rdata,
    output reg wb_wreg,
    output reg[4:0] wb_waddr
);
always @(posedge clk) begin
    if(rst) begin
        wb_wdata <= 32'b0;
        wb_pc <= 32'b0;
        wb_rdata <= 32'b0;
        wb_waddr <= 5'b0;
        wb_wreg <= 1'b0;
    end else begin
        if(stall == 1'b0) begin
            wb_wdata <= mem_wdata;
            wb_pc <= mem_pc;
            wb_rdata <= mem_rdata;
            wb_waddr <= mem_waddr;
            wb_wreg <= mem_wreg;
        end else ;
    end
end
endmodule