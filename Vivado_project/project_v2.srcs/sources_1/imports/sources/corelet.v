
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2021 20:43:12
// Design Name: 
// Module Name: corelet
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


module corelet(clk,reset,inst,act_wr_data,wt_wr_data,sfp_in_data,ofifo_out,ofifo_o_valid,sfp_out_data,wt_sram_rd_ptr);

parameter row  = 8;
parameter col = 8;  
parameter bw = 4;
parameter bw_h = 5;

parameter psum_bw = 16;

input clk;
input reset ;
input [7:0]inst;
input [row*bw-1:0]act_wr_data ;
input [2*row*bw_h-1:0]wt_wr_data ;
input [col*psum_bw-1:0] sfp_in_data;
output [psum_bw*col-1:0] ofifo_out;
output ofifo_o_valid;
output [psum_bw*col-1:0] sfp_out_data;
output [row*3 -1:0] wt_sram_rd_ptr; //w_add

wire [row*bw-1:0]ififo_wr_data ;
wire [row*bw-1:0] wt_huff_out ;


wire [row-1:0] huff_dat_valid;
wire [row-1:0] done_kernel;

wire ififo_we;
assign ififo_we = ( inst[0] &&  (inst[7] || huff_dat_valid[0]));


assign ififo_wr_data = inst[7] ? act_wr_data : wt_huff_out;


/***
inst[0] = ififo_wr ;
inst[1] = ififo_rd ;
inst[2] = array_load;
inst[3] = array_execute;
inst[4] = ofifo_rd;
inst[5] = sfp_acc ;
inst[6] = huff_decoder start;
inst[7] = ififo_choose
***/
wire [row*bw-1:0] ififo_out_data;
wire ififo_o_full;
wire ififo_o_ready;
l0 #(.bw(bw),.row(row)) ififo_instance (
	 .clk(clk),
	 .wr(ififo_we),
	 .rd(inst[1]),
	 .reset(reset),
     .in(ififo_wr_data),
     .out(ififo_out_data),
	 .o_full(ififo_o_full),
     .o_ready(ififo_o_ready));
     
wire [psum_bw*col-1:0] array_out;   
wire [col-1:0] array_col_valid;
wire [col*psum_bw-1:0] array_psum_in;
assign array_psum_in = 0;  // Change for tiling
mac_array  #(.bw(bw),.psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance (
	 .clk(clk),
	 .out_s(array_out),
	 .in_w(ififo_out_data),
	 .reset(reset),
     .inst_w(inst[3:2]),
     .in_n(array_psum_in),
	 .valid(array_col_valid));
	 
 	
wire ofifo_o_full;
wire ofifo_o_ready; 

ofifo #(.bw(psum_bw),.col(col)) ofifo_instance (
	 .clk(clk),
	 .wr(array_col_valid),
	 .rd(inst[4]),
	 .reset(reset),
     .in(array_out),
     .out(ofifo_out),
	 .o_full(ofifo_o_full),
     .o_ready(ofifo_o_ready),
     .o_valid(ofifo_o_valid));
     
sfp #(.bw(bw),.psum_bw(psum_bw),.col(col)) sfp_instance (
	 .clk(clk),
	 .acc(inst[5]),
	 .reset(reset),
     .in(sfp_in_data),
     .out(sfp_out_data));
genvar i;   
generate
  for (i=0; i<col ; i=i+1) begin : huff_dec
    huff_dec huff_dec_instance (
        .wr_clk(clk), 
        .reset(reset),
        .start(inst[6]),
        .rd_data(wt_wr_data[(2*(i+1)*bw_h)-1:i*2*bw_h]),
        .rd_ptr(wt_sram_rd_ptr[(i+1)*3-1:i*3]),  //w_add
        .w_index(wt_huff_out[(bw*(i+1)-1):bw*i]),
        .w_index_rdy(huff_dat_valid[i]),
        .done_kernel(done_kernel[i]));
   end
endgenerate
     
initial begin
//$monitor("t=%3d x=%d \n",$time,array_out);
//$monitor("t_sfp=%3d sfp_in=%d \n",$time,sfp_in_data);
end

endmodule
