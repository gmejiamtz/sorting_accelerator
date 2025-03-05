`timescale 1ns/1ps
module ulx3s_runner;

logic clk_i;
logic reset_i;
logic tx_o;
logic ebreak_found;
parameter realtime ClockPeriod = 20ns;

initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

top uut (
    .clk_i(clk_i),
    .reset_i(reset_i),
    .tx_o(tx_o)
);

task automatic reset;
    reset_i <= 1;
    //reset for 5 cycles
    repeat (5) begin
        @(posedge clk_i);
    end
    reset_i <= 0;
endtask

task automatic wait_n_cycles(integer n);
    repeat (n) begin
        //peek_memory_bus();
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
endmodule
