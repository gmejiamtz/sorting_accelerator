`timescale 1ns/1ps

module sorter_runner;

parameter realtime ClockPeriod = 20ns;

logic [0:0] clk_i;
logic [0:0] rst_i;
logic [0:0] start_i;

initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

localparam DATA_E = 8;
localparam DATA_W = 8;

logic [DATA_W - 1:0] dut_data_i, dut_data_o;
sorter #(
    .DATA_ENTRIES(DATA_E),
    .DATA_WIDTH(DATA_W)
) DUT (
    .clk_i,
    .rst_i,
    .write_valid_i,
    .start_i,
    .data_i(dut_data_i),
    .receive_ready_o(),
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
    int cycles = $urandom_range(10, 20);
    for (int i = 0; i < cycles; i++) begin
        @(posedge clk_i); #1;
    end
endtask

logic [0:0] write_valid_i;
task automatic ready_and_write;
    write_valid_i <= 1'b1;
    dut_data_i <= {DATA_W{1'b1}};
    @(posedge clk_i);
    @(posedge clk_i);
    dut_data_i <= {DATA_W{1'b0}};
    write_valid_i <= 1'b0;
endtask

endmodule
