`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.11.2021 10:45:54
// Design Name: 
// Module Name: core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module core(clk, reset,inst, D_xmem, ofifo_valid,sfp_out,ofifo_rd_data);

parameter  bw = 4;
parameter bw_h = 5;
parameter row = 8;
parameter col = 8;
parameter psum_bw = 16;

input clk ;
input reset;
input [35:0] inst;
input [bw_h*row-1:0] D_xmem;
output ofifo_valid;
output [col*psum_bw-1:0] sfp_out ;
output [psum_bw*col-1:0] ofifo_rd_data ;

wire [7:0] corelet_inst;
assign corelet_inst[0] = inst[5] ;
assign corelet_inst[1] = inst[4] ;
assign corelet_inst[2] = inst[0];
assign corelet_inst[3] = inst[1];
assign corelet_inst[4] = inst[6];
assign corelet_inst[5] = inst[33];
assign corelet_inst[6] = inst[34]; //Start
assign corelet_inst[7] = inst[35] ; // Choose

//wire [psum_bw*col-1:0] ofifo_rd_data;
wire [row*bw-1:0] act_wr_data; 
wire [((row*2*bw_h)-1):0] huff_data;
wire [row*3 -1:0] w_sram_addr; //w_add
wire [row*3 -1:0] huff_addr; //w_add



wire [psum_bw*col-1:0] output_mem_rd_data ;
corelet  #(.bw(bw),.psum_bw(psum_bw), .col(col), .row(row)) corelet_instance(
    .clk(clk),
    .reset(reset),
    .inst(corelet_inst),
    .act_wr_data(act_wr_data),
    .wt_wr_data(huff_data),
    .sfp_in_data(output_mem_rd_data),
    .ofifo_out(ofifo_rd_data),
    .ofifo_o_valid(ofifo_valid),
    .sfp_out_data(sfp_out),
    .wt_sram_rd_ptr(huff_addr));


wire [9:0] input_mem_address;
assign input_mem_address = inst[16:7] ;
wire write_act;
assign write_act =  ~(~inst[18] & inst[35]); // Note choose=active wr=active

sram_w2048 #(.MEM_BITWIDTH(32),.num(1024),.addr_bitwidth(10))input_sram_instance (
	.CLK(clk), 
	.CEN(inst[19]), 
	.WEN(write_act),
    .A(input_mem_address), 
    .D(D_xmem[31:0]), 
    .Q(act_wr_data));

wire [10:0] output_mem_address;
assign output_mem_address = inst[30:20] ;    
sram_w2048 #(.MEM_BITWIDTH(128),.num(2048))output_sram_instance (
	.CLK(clk), 
	.CEN(inst[32]), 
	.WEN(inst[31]),
    .A(output_mem_address), 
    .D(ofifo_rd_data), 
    .Q(output_mem_rd_data));

  genvar i;

   
wire write_wt;
assign write_wt =  ~(~inst[18] & ~inst[35]);
 
generate 
  for (i=0; i<row ; i=i+1) begin : weight_sram_banked_address
  assign w_sram_addr[(i+1)*3-1:i*3] = write_wt ? huff_addr[(i+1)*3-1:i*3] : input_mem_address [2:0]; //w_add
  end
endgenerate


generate
  
  for (i=0; i<row ; i=i+1) begin : weight_sram_banked
    sram_5b_banked #(.MEM_BITWIDTH(5),.num(5)) sram_5b_banked_instance ( //w_add
        .CLK(clk), 
        .CEN(inst[19]), 
        .WEN(write_wt), 
        .A(w_sram_addr[(i+1)*3-1:i*3]), //w_add
        .D(D_xmem[((i+1)*bw_h)-1:i*bw_h]), 
        .Q(huff_data[(2*(i+1)*bw_h)-1:i*2*bw_h]));
   end
endgenerate
initial begin
$monitor("t_addr=%8h \n",$time,w_sram_addr);
end
endmodule
