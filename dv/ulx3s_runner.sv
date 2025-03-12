`timescale 1ns/1ps
module ulx3s_runner;

logic clk_i;
logic reset_i;
logic tx_o;
logic [7:0] led;
logic ebreak_found;

parameter realtime ClockPeriod = 10ns;

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
    .tx_o(tx_o),
    .led(led)
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
    while (~|led[7:6]) begin
        @(posedge clk_i);
    end
    if (led[7]) begin
        $info("Trap is illegally found!");
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
