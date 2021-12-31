
module huff_dec(wr_clk,reset,start,rd_data,rd_ptr,w_index,w_index_rdy,done_kernel);

parameter num_centroids  = 8;
parameter bw = 8;
parameter bw_i = 3;
parameter row = 8;
parameter psum_bw = 16;

parameter bw_h= 5;

input wr_clk;
input reset ;

input start;
//input [3:0] rd_addr;

input [2*bw_h-1:0] rd_data ;

output reg [2:0]  rd_ptr; //w_add

output reg [bw_h-2:0] w_index;
output reg w_index_rdy;
output reg done_kernel;

reg [2:0] next_rd_ptr; //w_add

reg  [bw_h-2:0] next_w_index;
reg next_w_index_rdy;

wire [bw_h-1:0] check_one ; 
assign check_one = {(bw_h-1){1'b0}} + 1;

reg[2:0] i_ptr;
reg[2:0] next_i_ptr;


reg [1:0] state,next_state;

wire [bw_h-1:0] data;
assign data = rd_data >> i_ptr;




always @ (*) begin
    case (state)
    0: begin
        done_kernel = 0; 
        next_i_ptr =0;
        next_w_index = 0; 
        next_w_index_rdy = 0;
        if (start) begin
            next_rd_ptr = 0;//rd_addr;
            next_state = 1;
        end
        else begin
            next_rd_ptr = 0;
            next_state = 0;
        end

    end
    1: begin 
        if (data[0] == 0) begin
            next_w_index = 0;
            next_w_index_rdy = 1; 
            if (i_ptr == (bw_h-1)) begin
                next_i_ptr = 0;
                next_rd_ptr = rd_ptr + 1;
            end
            else begin
                next_i_ptr = i_ptr+1;
                next_rd_ptr = rd_ptr;

            end
            next_state = 1;
        end
        else if (data[(bw_h-1):0] == check_one) begin
            done_kernel = 1;
            next_w_index_rdy = 0;
            next_state = 0;
        end
        else begin
            next_w_index = data[(bw_h-1):1]; 
            next_w_index_rdy = 1;
            next_rd_ptr = rd_ptr + 1;
            next_i_ptr = i_ptr;    
            next_state = 1;
        end
    end   
    endcase

end


always @ (posedge wr_clk) begin
    if (reset) begin
        rd_ptr <= 0;
        w_index <= 0;
        w_index_rdy <= 0;
        i_ptr <= 0;
        state <= 0;
    end
    else begin 
        rd_ptr <= next_rd_ptr;
        w_index <= next_w_index;
        w_index_rdy <= next_w_index_rdy;
        i_ptr <= next_i_ptr;
        state <= next_state; 

    end
end

endmodule




