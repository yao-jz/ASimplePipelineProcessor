`timescale 1ns / 1ps
`include "sram.vh"
`include "para.v"
module sram_uart_controller(
        input wire clk,
        input wire rst,
        input wire command,
        input wire base_ram_command,
        input wire ext_ram_command,
        input wire[3:0] be,
        input wire[3:0] base_ram_be,
        input wire[3:0] ext_ram_be,

        input wire [31:0] in_addr,
        input wire [31:0] in_base_ram_addr,
        input wire [31:0] in_ext_ram_addr,
        input wire type,
        input wire [1:0] op_type,
        input wire [1:0] base_ram_op_type,
        input wire [1:0] ext_ram_op_type,
        input wire[31:0] in_data,          //���������?
        input wire[31:0] in_base_ram_data,
        input wire[31:0] in_ext_ram_data,
        output reg[31:0] out_data,      //����������
        //BaseRAM�ź�
        inout wire[31:0] base_ram_data,  //BaseRAM���ݣ���8λ��CPLD���ڿ���������
        output wire[19:0] base_ram_addr, //BaseRAM��ַ
        output wire[3:0] base_ram_be_n,  //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣���?0
        output reg base_ram_ce_n,       //BaseRAMƬѡ������Ч
        output reg base_ram_oe_n,       //BaseRAM��ʹ�ܣ�����Ч
        output reg base_ram_we_n,       //BaseRAMдʹ�ܣ�����Ч

        //ExtRAM�ź�
        inout wire[31:0] ext_ram_data,  //ExtRAM����
        output wire[19:0] ext_ram_addr, //ExtRAM��ַ
        output wire[3:0] ext_ram_be_n,  //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣���?0
        output reg ext_ram_ce_n,       //ExtRAMƬѡ������Ч
        output reg ext_ram_oe_n,       //ExtRAM��ʹ�ܣ�����Ч
        output reg ext_ram_we_n,        //ExtRAMдʹ�ܣ�����Ч


        output reg uart_rdn,         //�������źţ�����Ч
        output reg uart_wrn,         //д�����źţ�����Ч
        input wire uart_dataready,    //��������׼����
        input wire uart_tbre,         //�������ݱ�־
        input wire uart_tsre,         //���ݷ�����ϱ��?
        output reg done
    );


assign base_ram_data = (in_addr[31:28] == 4'b1000 && type == `BASE && op_type == `WRITE) ? in_data : (in_addr[31:28] == 4'b0001 && op_type == `WRITE) ? {24'b0,in_data[7:0]} : 32'bz;
assign ext_ram_data = (type == `EXT && op_type == `WRITE) ? in_data : 32'bz;
reg [2:0] uart_read_state;
reg [2:0] uart_write_state;  
reg [1:0] sram_read_state;
reg [1:0] sram_write_state;
assign base_ram_be_n = be;
assign ext_ram_be_n = be;
assign base_ram_addr = in_addr[21:2];
assign ext_ram_addr = in_addr[21:2];

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        sram_read_state <= 2'b11;
        sram_write_state <= 2'b11;
        uart_read_state <= 3'b111;
        uart_write_state <= 3'b111;
        uart_wrn <= 1'b1;
        uart_rdn <= 1'b1;
        ext_ram_we_n <= 1'b1;
        ext_ram_oe_n <= 1'b1;
        ext_ram_ce_n <= 1'b1;
        base_ram_we_n <= 1'b1;
        base_ram_oe_n <= 1'b1;
        base_ram_ce_n <= 1'b1;
        done <= 1'b0;
    end
    else begin
        if(command) begin
            sram_read_state <= 2'b00;
            sram_write_state <= 2'b00;
            uart_read_state <= 3'b000;
            uart_write_state <= 3'b000;
            uart_wrn <= 1'b1;
            uart_rdn <= 1'b1;
            ext_ram_we_n <= 1'b1;
            ext_ram_oe_n <= 1'b1;
            ext_ram_ce_n <= 1'b1;
            base_ram_we_n <= 1'b1;
            base_ram_oe_n <= 1'b1;
            base_ram_ce_n <= 1'b1;
            done <= 1'b0;
        end
        else begin
            case(in_addr[31:28])
                4'b1000: begin
                    uart_wrn <= 1'b1;
                    uart_rdn <= 1'b1;
                    case(type)
                        `BASE: begin
                            case(op_type)
                                `READ: begin
                                    case(sram_read_state)
                                        2'b00: begin
                                            done <= 1'b0;
                                            base_ram_ce_n <= 1'b0;
                                            base_ram_we_n <= 1'b1;
                                            base_ram_oe_n <= 1'b0;
                                            sram_read_state <= 2'b01;
                                        end
                                        2'b01: begin
                                            case (be)
                                                `ONE: out_data <= {24'b0, base_ram_data[7:0]}; 
                                                `TWO: out_data <= {24'b0, base_ram_data[15:8]};
                                                `THREE: out_data <= {24'b0, base_ram_data[23:16]};
                                                `FOUR: out_data <= {24'b0, base_ram_data[31:24]};
                                                `ALL: out_data <= base_ram_data;
                                                `HALF: out_data <= {16'b0, base_ram_data[15:0]};
                                                `NONE: out_data <= 32'b0;
                                                default: ;
                                            endcase
                                            sram_read_state <= 2'b10;
                                            done <= 1'b1;
                                        end
                                        default: begin
                                            base_ram_ce_n <= 1'b1;
                                            base_ram_oe_n <= 1'b1;
                                            done <= 1'b0;
                                        end
                                    endcase
                                end
                                `WRITE: begin
                                    out_data <= 32'b0;
                                    case(sram_write_state)
                                        2'b00: begin
                                            done <= 1'b0;
                                            base_ram_ce_n <= 1'b0;
                                            base_ram_oe_n <= 1'b1;
                                            base_ram_we_n <= 1'b1;
                                            sram_write_state <= 2'b01;
                                        end
                                        2'b01: begin
                                            base_ram_we_n <= 1'b0;
                                            sram_write_state <= 2'b10;
                                        end
                                        2'b10: begin
                                            base_ram_we_n <= 1'b1;
                                            sram_write_state <= 2'b11;
                                            done <= 1'b1;
                                        end
                                        default: begin
                                            done <= 1'b0;
                                            base_ram_we_n <= 1'b1;
                                            base_ram_ce_n <= 1'b1;
                                        end
                                    endcase
                                end
                                `HOLD: begin
                                    done <= 1'b0;
                                    base_ram_we_n <= 1'b1;
                                    base_ram_oe_n <= 1'b1;
                                    base_ram_ce_n <= 1'b1;
                                    sram_read_state <= 2'b11;
                                    sram_write_state <= 2'b11;
                                end
                                default: ;
                                endcase
                        end
                        `EXT: begin
                        case(op_type)
                                `READ: begin
                                    case(sram_read_state)
                                        2'b00: begin
                                            done <= 1'b0;
                                            ext_ram_ce_n <= 1'b0;
                                            ext_ram_we_n <= 1'b1;
                                            ext_ram_oe_n <= 1'b0;
                                            sram_read_state <= 2'b01;
                                        end
                                        2'b01: begin
                                            case (be)
                                                `ONE: out_data <= {24'b0, base_ram_data[7:0]}; 
                                                `TWO: out_data <= {24'b0, base_ram_data[15:8]};
                                                `THREE: out_data <= {24'b0, base_ram_data[23:16]};
                                                `FOUR: out_data <= {24'b0, base_ram_data[31:24]};
                                                `ALL: out_data <= base_ram_data;
                                                `HALF: out_data <= {16'b0, base_ram_data[15:0]};
                                                `NONE: out_data <= 32'b0;
                                                default: ;
                                            endcase
                                            sram_read_state <= 2'b10;
                                            done <= 1'b1;
                                        end
                                        default: begin 
                                            ext_ram_oe_n <= 1'b1;
                                            ext_ram_ce_n <= 1'b1;
                                            done <= 1'b0;
                                        end
                                    endcase
                                end
                                `WRITE: begin
                                    out_data <= 32'b0;
                                    case(sram_write_state)
                                        2'b00: begin
                                            done <= 1'b0;
                                            ext_ram_ce_n <= 1'b0;
                                            ext_ram_oe_n <= 1'b1;
                                            ext_ram_we_n <= 1'b1;
                                            sram_write_state <= 2'b01;
                                        end
                                        2'b01: begin
                                            ext_ram_we_n <= 1'b0;
                                            sram_write_state <= 2'b10;
                                        end
                                        2'b10: begin
                                            ext_ram_we_n <= 1'b1;
                                            sram_write_state <= 2'b11;
                                            done <= 1'b1;
                                        end
                                        default: begin
                                            ext_ram_we_n <= 1'b1;
                                            ext_ram_ce_n <= 1'b1;
                                            done <= 1'b0;
                                        end
                                    endcase
                                end
                                `HOLD: begin
                                    out_data <= 32'b0;
                                    ext_ram_we_n <= 1'b1;
                                    ext_ram_oe_n <= 1'b1;
                                    ext_ram_ce_n <= 1'b1;
                                    sram_read_state <= 2'b11;
                                    sram_write_state <= 2'b11;
                                    done <= 1'b0;
                                end
                                default: ;
                                endcase
                        end
                        default: begin
                            ext_ram_we_n <= 1'b1;
                            ext_ram_oe_n <= 1'b1;
                            ext_ram_ce_n <= 1'b1;
                            base_ram_we_n <= 1'b1;
                            base_ram_oe_n <= 1'b1;
                            base_ram_ce_n <= 1'b1;
                            done <= 1'b0;
                        end
                        endcase
                end
                4'b0001: begin
                    case(in_addr) 
                        32'h10000000: begin
                            ext_ram_we_n <= 1'b1;
                            ext_ram_oe_n <= 1'b1;
                            ext_ram_ce_n <= 1'b1;
                            base_ram_we_n <= 1'b1;
                            base_ram_oe_n <= 1'b1;
                            base_ram_ce_n <= 1'b1;
                            case(op_type) 
                                `READ: begin    //������
                                    case(uart_read_state)
                                        3'b000: begin
                                            uart_rdn <= 1'b1;
                                            
                                            uart_read_state <= 3'b001;
                                        end
                                        3'b001: begin
                                            if(uart_dataready == 1) begin
                                                uart_read_state <= 3'b010;
                                                uart_rdn <= 1'b0;
                                            end
                                            else 
                                                done <= 1'b0;
                                        end
                                        3'b010: begin
                                            out_data <= base_ram_data;
                                            done <= 1'b1;
                                            uart_rdn <= 1'b1;       // here
                                            uart_read_state <= 3'b011;
                                        end
                                        3'b011: begin
                                            uart_read_state <= 3'b100;
                                        end
                                        3'b100: begin
                                            done <= 1'b0;
                                            uart_read_state <= 3'b101;
                                        end
                                        default: begin
                                        end
                                    endcase
                                end
                                `WRITE: begin
                                    case(uart_write_state)
                                        3'b000: begin
                                            done <= 1'b0;
                                            uart_wrn <= 1'b0;
                                            uart_write_state <= 3'b001;
                                        end
                                        3'b001: begin
                                            uart_wrn <= 1'b1;
                                            uart_write_state <= 3'b010;
                                        end
                                        3'b010: begin
                                            if(uart_tbre == 1'b1)
                                                uart_write_state <= 3'b011;
                                            else ;
                                        end
                                        3'b011: begin
                                            if(uart_tsre == 1'b1) begin
                                                uart_write_state <= 3'b100;
                                                done <= 1'b1;
                                            end
                                            else ;
                                        end
                                        3'b100: begin
                                            uart_write_state <= 3'b101;
                                        end
                                        3'b101: begin
                                            uart_write_state <= 3'b110;
                                            done <= 1'b0;
                                        end
                                        default: ;
                                    endcase
                                end
                                `HOLD: begin
                                    uart_rdn <= 1'b1;
                                    done <= 1'b0;
                                    uart_wrn <= 1'b1;
                                end
                                default: ;
                            endcase
                        end
                        32'h10000005: begin
                            out_data <= {26'b0,uart_tsre,4'b0,uart_dataready};
                        end
                        default: done <= 1'b0;
                    endcase
                end
                default: begin
                    base_ram_we_n <= 1'b1;
                    base_ram_ce_n <= 1'b1;
                    base_ram_oe_n <= 1'b1;
                    ext_ram_we_n <= 1'b1;
                    ext_ram_oe_n <= 1'b1;
                    ext_ram_ce_n <= 1'b1;
                    uart_wrn <= 1'b1;
                    uart_rdn <= 1'b1;
                    done <= 1'b0;
                end
            endcase
        end
    end
end



endmodule
