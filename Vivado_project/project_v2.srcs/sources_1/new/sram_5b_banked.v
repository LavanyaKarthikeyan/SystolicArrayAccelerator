// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_5b_banked (CLK, D, Q, CEN, WEN, A);
  parameter num = 10;
  parameter MEM_BITWIDTH = 5;
  input  CLK;
  input  WEN;
  input  CEN;
  input  [MEM_BITWIDTH-1:0] D;
  input  [2:0] A; //w_add
  output [2*MEM_BITWIDTH-1:0] Q;
  

  reg [MEM_BITWIDTH-1:0] memory [num-1:0];
 // reg [10:0] add_q;
  assign Q = ( CEN ) ? 0: {memory[A+1],memory[A]};

  always @ (posedge CLK) begin

   if (!CEN && !WEN) // write
      memory[A] <= D; 

  end

endmodule
