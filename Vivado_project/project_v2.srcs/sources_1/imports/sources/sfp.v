// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp (out, in, acc, clk, reset);

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;

input clk;
input acc;
//input relu;
input reset;
input   signed [col*psum_bw-1:0] in;
output  signed [col*psum_bw-1:0] out;

reg     signed [col*psum_bw-1:0] psum_q;
wire    signed [col*psum_bw-1:0] psum_relu;

//assign psum_relu = (psum_q>0)?psum_q:0 ;
assign psum_relu = psum_q;
assign out = psum_relu;
always @(posedge clk) begin
    if(reset)
        psum_q <= 0;
    else if(acc) begin
        psum_q[15:0] <= psum_q[15:0] + in[15:0] ;
        psum_q[31:16] <= psum_q[31:16] + in[31:16] ;
        psum_q[47:32] <= psum_q[47:32] + in[47:32] ;
        psum_q[63:48] <= psum_q[63:48] + in[63:48] ;
        psum_q[79:64] <= psum_q[79:64] + in[79:64] ;
        psum_q[95:80] <= psum_q[95:80] + in[95:80] ;
        psum_q[111:96] <= psum_q[111:96] + in[111:96] ;
        psum_q[127:112] <= psum_q[127:112] + in[127:112] ;
    end
end
endmodule
