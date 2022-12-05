`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮�?关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮�?关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时�?1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信�?
    output wire uart_rdn,         //读串口信号，低有�?
    output wire uart_wrn,         //写串口信号，低有�?
    input wire uart_dataready,    //串口数据准备�?
    input wire uart_tbre,         //发�?�数据标�?
    input wire uart_tsre,         //数据发�?�完毕标�?

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共�?
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire base_ram_ce_n,       //BaseRAM片�?�，低有�?
    output wire base_ram_oe_n,       //BaseRAM读使能，低有�?
    output wire base_ram_we_n,       //BaseRAM写使能，低有�?

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire ext_ram_ce_n,       //ExtRAM片�?�，低有�?
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有�?
    output wire ext_ram_we_n,       //ExtRAM写使能，低有�?

    //直连串口信号
    output wire txd,  //直连串口发�?�端
    input  wire rxd,  //直连串口接收�?

    //Flash存储器信号，参�?? JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效�?16bit模式无意�?
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧�?
    output wire flash_ce_n,         //Flash片�?�信号，低有�?
    output wire flash_oe_n,         //Flash读使能信号，低有�?
    output wire flash_we_n,         //Flash写使能信号，低有�?
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash�?16位模式时请设�?1

    //USB 控制器信号，参�?? SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参�?? DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素�?3�?
    output wire[2:0] video_green,  //绿色像素�?3�?
    output wire[1:0] video_blue,   //蓝色像素�?2�?
    output wire video_hsync,       //行同步（水平同步）信�?
    output wire video_vsync,       //场同步（垂直同步）信�?
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐�?
);

// if_id    -------      id
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;

// id       -------      id_exe
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_waddr_o;
wire[`InstAddrBus] id_pc_o;
wire[`InstBus] id_inst_o;

// id_exe   -------      exe
wire[`AluOpBus] exe_aluop_i;
wire[`RegBus] exe_reg1_i;
wire[`RegBus] exe_reg2_i;
wire exe_wreg_i;
wire[`RegAddrBus] exe_waddr_i;
wire[`InstAddrBus] exe_pc_i;
wire[`InstBus] exe_inst_i;

// exe      -------      exe_mem
wire[`RegAddrBus] exe_waddr_o;
wire exe_wreg_o;
wire[`InstAddrBus] exe_pc_o;
wire[`InstBus] exe_instr_o;
wire[`RegBus] exe_wdata_o;
wire[`RegBus] exe_b_o;

// exe_mem  -------      mem
wire[31:0] mem_pc_i;
wire[31:0] mem_result_i;
wire[31:0] mem_b_i;
wire[31:0] mem_instr_i;
wire[`RegAddrBus] mem_waddr_i;
wire mem_wreg_i;

// mem      -------      mem_wb
wire[`RegAddrBus] mem_waddr_o;
wire mem_wreg_o;
wire[`RegBus] mem_wdata_o;
wire[31:0] mem_after_pc_o;
wire[31:0] mem_read_data_o;

// mem_wb   -------      wb
wire[`RegBus] wb_wdata_i;
wire[31:0] wb_pc_i;
wire[31:0] wb_rdata_i;
wire wb_wreg_i;
wire[4:0] wb_waddr_i;

// id       -------      regfile
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

reg[31:0] instr_data;

program_counter pc_reg0(
    .clk(clk_50M),
    .rst(reset_btn),
    .instr_addr(pc)
);

if_id if_id0(
    .clk(clk_50M),
    .rst(reset_btn),
    .if_pc(pc),
    .if_instr(instr_data),
    .id_pc(id_pc_i),
    .id_instr(id_inst_i)
);

id id0(
    .rst(reset_btn),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    // from regfile
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),

    // to regfile
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),

    // to id_exe
    .aluop_o(id_aluop_o), 
    .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .waddr_o(id_waddr_o), .wreg_o(id_wreg_o),
    .pc_o(id_pc_o), .inst_o(id_inst_o)
);

regfile regfile1(
    .clk(clk_50M), .rst(reset_btn),
    .we(wb_wreg_i), .waddr(wb_waddr_i), .wdata(wb_wdata_i), 
    .re1(reg1_read), .raddr1(reg1_addr), .rdata1(reg1_data),
    .re2(reg2_read), .raddr2(reg2_addr), .rdata2(reg2_data)
);

id_exe id_ex0(
    .clk(clk_50M), .rst(reset_btn),

    // from id
    .id_aluop(id_aluop_o),
    .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
    .id_waddr(id_waddr_o), .id_wreg(id_wreg_o),
    .id_instr(id_inst_o), .id_pc(id_pc_o),

    // to exe
    .exe_aluop(exe_aluop_i),
    .exe_reg1(exe_reg1_i), .exe_reg2(exe_reg2_i),
    .exe_waddr(exe_waddr_i), .exe_wreg(exe_wreg_i),
    .exe_pc(exe_pc_i), .exe_instr(exe_inst_i)
);

ex exe0(
    .rst(reset_btn),

    // from id_exe
    .aluop_i(exe_aluop_i),
    .reg1_i(exe_reg1_i), .reg2_i(exe_reg2_i),
    .waddr_i(exe_waddr_i), .wreg_i(exe_wreg_i),
    .pc_i(exe_pc_i), .instr_i(exe_inst_i),

    // to exe_mem
    .waddr_o(exe_waddr_o), .wreg_o(exe_wreg_o), .b_o(exe_b_o), 
    .wdata_o(exe_wdata_o), .pc_o(exe_pc_o), .instr_o(exe_instr_o)
);

exe_mem exe_mem0(
    .clk(clk_50M), .rst(reset_btn),
    
    // from exe
    .exe_waddr(exe_waddr_o), .exe_wreg(exe_wreg_o), .exe_result(exe_wdata_o),
    .exe_pc(exe_pc_o), .exe_b(exe_b_o), .exe_instr(exe_instr_o),

    // to mem
    .mem_pc(mem_pc_i), .mem_result(mem_result_i), .mem_b(mem_b_i), .mem_instr(mem_instr_i),
    .mem_waddr(mem_waddr_i), .mem_wreg(mem_wreg_i)
);

mem mem0(
    .rst(reset_btn),

    // from exe_mem
    .pc_i(mem_pc_i), .result_i(mem_result_i), .b_i(mem_b_i), .instr_i(mem_instr_i),
    .waddr_i(mem_waddr_i), .wreg_i(mem_wreg_i),

    // to mem_wb
    .waddr_o(mem_waddr_o), .wreg_o(mem_wreg_o), .wdata_o(mem_wdata_o),
    .after_pc_o(mem_after_pc_o), .read_data_o(mem_read_data_o)
);

mem_wb mem_wb0(
    .clk(clk_50M), .rst(reset_btn),

    // from mem
    .mem_wdata(mem_wdata_o), .mem_pc(mem_after_pc_o), .mem_rdata(mem_read_data_o),
    .mem_wreg(mem_wreg_o), .mem_waddr(mem_waddr_o),

    // to wb
    .wb_wdata(wb_wdata_i), .wb_pc(wb_pc_i), .wb_rdata(wb_rdata_i), 
    .wb_wreg(wb_wreg_i), .wb_waddr(wb_waddr_i)
);











/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设�?
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设�?
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出�?"1"表示时钟稳定�?
                     // 后级电路复位信号应当由它生成（见下）
 );

reg reset_of_clk10M;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end


// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number�?16进制显示在数码管上面
wire[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

assign leds = 16'b0;

//直连串口接收发�?�演示，从直连串口收到的数据再发送出�?
// wire [7:0] ext_uart_rx;
// reg  [7:0] ext_uart_buffer, ext_uart_tx;
// wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
// reg ext_uart_start, ext_uart_avai;
    
// assign number = ext_uart_buffer;

// async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块�?9600无检验位
//     ext_uart_r(
//         .clk(clk_50M),                       //外部时钟信号
//         .RxD(rxd),                           //外部串行信号输入
//         .RxD_data_ready(ext_uart_ready),  //数据接收到标�?
//         .RxD_clear(ext_uart_clear),       //清除接收标志
//         .RxD_data(ext_uart_rx)             //接收到的�?字节数据
//     );

// assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer�?
// always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
//     if(ext_uart_ready)begin
//         ext_uart_buffer <= ext_uart_rx;
//         ext_uart_avai <= 1;
//     end else if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_avai <= 0;
//     end
// end
// always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发�?�出�?
//     if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_tx <= ext_uart_buffer;
//         ext_uart_start <= 1;
//     end else begin 
//         ext_uart_start <= 0;
//     end
// end

// async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发�?�模块，9600无检验位
//     ext_uart_t(
//         .clk(clk_50M),                  //外部时钟信号
//         .TxD(txd),                      //串行信号输出
//         .TxD_busy(ext_uart_busy),       //发�?�器忙状态指�?
//         .TxD_start(ext_uart_start),    //�?始发送信�?
//         .TxD_data(ext_uart_tx)        //待发送的数据
//     );

//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
wire [11:0] hdata;
assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐�?
    .vdata(),      //纵坐�?
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);
/* =========== Demo code end =========== */

endmodule
