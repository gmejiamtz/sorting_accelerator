`timescale 1ns/1ps
module sorter_runner;

logic [0:0] clkin, clk_i;
logic [0:0] rst_i;
logic [0:0] start_i;

parameter realtime ClockPeriod_Native = 41.667ns;
parameter realtime ClockPeriod_PLL = 20ns;

//Native Clock Generation
initial begin
    clkin = 0;
    forever begin
        #(ClockPeriod_Native/2);
        clkin = !clkin;
    end
end

//PLL Generation
initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod_PLL/2);
        clk_i = !clk_i;
    end
end

localparam int DATA_ENTRIES = 8;
localparam int DATA_WIDTH = 8;

logic [DATA_WIDTH - 1:0] dut_data_i, dut_data_o;
sorter DUT (
    .clk_i,
    .rst_i,
    .write_valid_i,
    .start_i,
    .data_i(dut_data_i),
    .read_valid_o(),
    .data_o(dut_data_o)
);

task automatic reset_to_start;
    rst_i <= 1'b1;
    start_i <= 1'b0;
    @(posedge clk_i);
    @(posedge clk_i);
    rst_i <= 1'b0;
    start_i <= 1'b1;
    @(posedge clk_i);
    @(posedge clk_i);
    start_i <= 1'b0;
endtask


task automatic delay;
    int cycles = $urandom_range(100, 200);
    for (int i = 0; i < cycles; i++) begin
        @(posedge clk_i); #1;
    end
endtask

logic [0:0] write_valid_i;
task automatic ready_and_write;
    write_valid_i <= 1'b1;
    dut_data_i <= $urandom_range(0, 255);
    @(posedge clk_i);
    @(posedge clk_i);
    dut_data_i <= {DATA_WIDTH{1'b0}};
    write_valid_i <= 1'b0;
endtask

endmodule
