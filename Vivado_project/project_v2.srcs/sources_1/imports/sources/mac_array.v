// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;
  
  
  //Partial sum passing
  wire [psum_bw*col*(row+1)-1:0] temp;
  assign  temp[psum_bw* col -1:0]= in_n;
  
  //Only take last row's valid
  wire [col*row-1:0] valid_conc;
  assign valid =  valid_conc[col*row-1:col*(row-1)] ;
  
  //Last row out goes to out_s
  assign out_s = temp[psum_bw*col*(row+1)-1: psum_bw*col*row] ;
  
  //Propagating inst_w
  reg [2*row-1:0] inst_w_flow;

  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
		.clk(clk),
        .reset(reset),
		.out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*i]),  
		.valid(valid_conc[col*i-1:col*(i-1)]),  
		.in_w(in_w[bw*i-1:bw*(i-1)]),
		.inst_w(inst_w_flow[2*i-1:2*(i-1)]), //
		.in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)])
      );
  end
  
  always @ (posedge clk) begin	
	if (reset)
		inst_w_flow <= 0 ;
	else begin
		inst_w_flow[2*row-1:0] <= {inst_w_flow[2*row-3:0],inst_w} ;
	end 
  end

endmodule
