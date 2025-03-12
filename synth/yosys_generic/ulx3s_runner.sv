`timescale 1ns/1ps
module ulx3s_runner;

logic clk_i;
logic reset_i;
logic a_i;
logic b_i;
logic c_i;
logic d_o;

parameter realtime ClockPeriod = 20ns;

initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

ulx3s_sim ulx3s_sim (.*);

always @(posedge d_o) $info("Register on");
always @(negedge d_o) $info("Register off");

task automatic reset;
    reset_i <= 1;
    a_i <= '0;
    b_i <= '0;
    c_i <= '0;
    @(posedge clk_i);
    reset_i <= 0;
endtask

task automatic wait_n_cycles(integer n);
    repeat (n) begin
        @(posedge clk_i);
    end
endtask

task automatic peek_memory_bus;
    $display("Memory Read Addr(%h) | Memory Read Data: (%h)",uut.picorv32_axi_core.mem_axi_araddr,uut.picorv32_axi_core.mem_axi_rdata);
endtask

task run_until_ebreak;
    ebreak_found = uut.picorv32_axi_core.mem_axi_rdata == 32'h00100073;
    while (~uut.picorv32_axi_core.trap & ~ebreak_found) begin
        @(posedge clk_i);
    end
    if (~uut.picorv32_axi_core.trap) begin
        $info("Trap is illegally");
        peek_memory_bus();
    end else begin
        $info("Ebreak found, main is returning/terminating properly");
        @(posedge clk_i); //simulate one more cycle to see the proper trap behavior
    end
endtask

task dump_stdout_buffer;
    while(~uut.stdout_buffer_fifo_inst.empty) begin
        @(posedge clk_i);
    end
endtask


endmodule
