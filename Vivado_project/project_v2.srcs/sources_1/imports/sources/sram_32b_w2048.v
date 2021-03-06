// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_w2048 (CLK, D, Q, CEN, WEN, A);
  parameter num = 2048;
  parameter addr_bitwidth = 11;
  parameter MEM_BITWIDTH = 32;
  input  CLK;
  input  WEN;
  input  CEN;
  input  [MEM_BITWIDTH-1:0] D;
  input  [addr_bitwidth-1:0] A;
  output [MEM_BITWIDTH-1:0] Q;
  

  reg [MEM_BITWIDTH-1:0] memory [num-1:0];
  reg [10:0] add_q;
  assign Q = memory[add_q];

  always @ (posedge CLK) begin

   if (!CEN && WEN) // read 
      add_q <= A;
   if (!CEN && !WEN) // write
      memory[A] <= D; 

  end

endmodule
