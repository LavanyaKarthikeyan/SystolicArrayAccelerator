module tb_huff_dec();

parameter bw_h= 4;


reg          clk, reset_n, start;
reg   [15:0] message_addr, output_addr;
reg          mem_clk, mem_we;
reg   [31:0] mem_write_data;
reg   [31:0] mem_read_data;

reg [bw_h-1:0] dpsram [0:10]; // each row has 32 bits

wire [2*bw_h-1:0] decoder_data ;
wire   [15:0] mem_addr;
wire done;

reg   [7:0] message_seed = 8'h66; // modify message_seed to test your design

integer m;

wire [bw_h-2:0] w_index;
wire w_index_rdy;

huff_dec inst1  (clk, reset_n, start, message_addr, decoder_data, mem_addr, w_index,w_index_rdy,done);

// clock generator
always begin
    #10;
    clk = 1'b1;
    #10
    clk = 1'b0;
end

// main testbench
initial
begin
// PRELIMINARIES
	start =0;
    message_addr = 32'd0;
    // RESET HASH CO-PROCESSOR
	#10
    reset_n = 1;
    #20
	reset_n = 0;
    // SET MESSAGE LOCATION
	 for (m = 0; m < 10; m=m+1) begin // data generation
        if (m == 0) begin
            dpsram[message_addr+m] = message_seed;
		end
        else begin
            dpsram[message_addr+m] = (dpsram[message_addr+m-1]<<1)|(dpsram[message_addr+m-1]>>7);
		end
	end
	#40
	//Compute SIZE 

    // CREATE AND DISPLAY MESSAGE

    $display("--------");
    $display("MESSAGE:");
    $display("--------");

    // START PROCESSOR

    start = 1'b1;
    message_addr = 32'd0;
	#40
    start = 1'b0;
	
		
	#1000
    $display("***************************\n");

    $stop;
end

assign decoder_data = {dpsram[mem_addr+1],dpsram[mem_addr]};





endmodule
