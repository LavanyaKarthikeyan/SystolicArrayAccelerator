// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;
  
  //`define READ_TYPE_0  // 0: read all together 1: propogate south every cycle
 // `define READ_TYPE_1

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;

  assign o_ready = (full != 0)?0:1  ;
  assign o_full  = (full != 0)?1:0  ;


  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en[i]),
	 .wr(wr),
     .o_empty(empty[i]),
     .o_full(full[i]),
	 .in(in[bw*(i+1)-1:bw*i]),
	 .out(out[bw*(i+1)-1:bw*i]),
     .reset(reset));
  end

  
  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else begin
      /////////////// version1: read all row at a time ////////////////
      `ifdef READ_TYPE_0 begin
		if (rd)
			rd_en <= 8'hFF ;
		else
			rd_en <= 8'h00 ;
	   end
	  
      ///////////////////////////////////////////////////////
      //////////////// version2: read 1 row at a time /////////////////
	  `else
		rd_en[row-1:0] <= {rd_en[row-2:0],rd} ;  
  
	  `endif
			

      ///////////////////////////////////////////////////////
    end
  end

endmodule
