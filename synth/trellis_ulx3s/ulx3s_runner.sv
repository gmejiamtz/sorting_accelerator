`timescale 1ns/1ps
module ulx3s_runner;

logic clkin,clk;
logic reset_ni;
logic [3:1] btn,led;

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
    clk = 0;
    forever begin
        #(ClockPeriod_PLL/2);
        clk = !clk;
    end
end

ulx3s ulx3s (
    .clkin(clkin),
    .reset_ni(reset_ni),
    .btn(btn),
    .led(led)
);

assign ulx3s.pll.CLKOP = clk;

always @(posedge led[0]) $info("Register on");
always @(negedge led[0]) $info("Register off");

task automatic reset;
    reset_ni <= 0;
    btn <= '0;
    @(posedge clk);
    reset_ni <= 0;
endtask

task automatic set_a_i(input [0:0] arg_i);
    btn[1] <= arg_i;
endtask

task automatic set_b_i(input [0:0] arg_i);
    btn[2] <= arg_i;
endtask

task automatic set_c_i(input [0:0] arg_i);
    btn[3] <= arg_i;
endtask

task automatic wait_n_cycles(integer n);
    repeat (n) begin
        @(posedge clk);
    end
endtask

endmodule
