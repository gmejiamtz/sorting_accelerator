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

task automatic set_a_i(input [0:0] arg_i);
    a_i <= arg_i;
endtask

task automatic set_b_i(input [0:0] arg_i);
    b_i <= arg_i;
endtask

task automatic set_c_i(input [0:0] arg_i);
    c_i <= arg_i;
endtask

task automatic wait_n_cycles(integer n);
    repeat (n) begin
        @(posedge clk_i);
    end
endtask

endmodule
