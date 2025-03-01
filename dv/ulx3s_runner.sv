`timescale 1ns/1ps
module ulx3s_runner;

logic clk_i;
logic reset_i;
logic tx_o;

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
    $display("At PC: (%h) | Memory Bus: (%h)",uut.picorv32_core.mem_addr,uut.picorv32_core.mem_rdata);
endtask

endmodule
