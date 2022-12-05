`timescale 1ns / 1ps
`include "alu.vh"
module alu(
        input wire[3:0]        op,
        input wire[31:0]       a,
        input wire[31:0]       b,
        output wire[31:0]       result,
        output wire       f
    );

reg flag;   // 注意是第几位的flag
reg [31:0] r;
assign result = r;
assign f = flag;

always @ (*)
begin
    case(op)
        `ADD: begin
            r = a + b;
            flag = ((~a[15])&(~b[15])&r[15])|(a[15]&b[15]&(~r[15]));
        end
        `SUB: begin 
            r = a - b;
            flag = ((a[15])&(~b[15])&(~r[15]))|((~a[15])&(b[15])&(r[15]));
        end
        `AND: begin r = a & b; flag = 0; end
        `OR: begin r = a | b; flag = 0; end
        `XOR: begin r = a ^ b; flag = 0; end
        `NOT: begin r = ~a; flag = 0; end
        `SLL: begin r = a << b; flag = 0; end
        `SRL: begin r = a >> b; flag = 0; end
        `SRA: begin r = ($signed(a)) >>> b; flag = 0; end
        `ROL: begin
            r = (a << b) | (a >> (32-b)); 
            flag = 0;
        end
        default: r = 0;
    endcase
end
endmodule
