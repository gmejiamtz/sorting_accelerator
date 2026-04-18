module ram_1r1w_sync
  #(parameter [31:0] width_p = 8
    ,parameter [31:0] depth_p = 128
    ,parameter  filename_p = "memory_init_file.hex")
   (input [0:0] clk_i
    ,input [0:0] reset_i

    ,input [0:0] wr_valid_i
    ,input [width_p-1:0] wr_data_i
    ,input [$clog2(depth_p) - 1 : 0] wr_addr_i

    ,input [$clog2(depth_p) - 1 : 0] rd_addr_i
    ,output [width_p-1:0] rd_data_o
    );
	logic [width_p-1:0] memory [depth_p-1:0]; //memory array
   	logic [width_p-1:0] read_l;
	initial begin
      	// Display depth and width (You will need to match these in your init file
      	$display("%m: depth_p is %d, width_p is %d", depth_p, width_p);
	  	$readmemh(filename_p,memory);
  	 end

	
	always_ff @(posedge clk_i) begin
		if(wr_valid_i) begin
			memory[wr_addr_i] <= wr_data_i;
		end
		read_l <= memory[rd_addr_i];
	end
	assign rd_data_o = read_l;

endmodule
