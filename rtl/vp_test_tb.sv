`timescale 1ns/1ps
module vp_test_tb();

logic clk_i;
logic [15:0] dq;





parameter realtime ClockPeriod = 20ns;

initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

W9825G6KH 
dut (
    .Dq    (dq),
    .Addr  ('b0),
    .Bs    ('b0),
    .Clk   (clk_i),
    .Cke   ('b0),
    .Cs_n  ('b0),
    .Ras_n ('b0),
    .Cas_n ('b0),
    .We_n  ('b0),
    .Dqm   ('b0)
);



initial begin 
    $display("Starting Simulation");
    $dumpfile("test.vcd");
    $dumpvars(1, "vp_test_tb");
    repeat (100) begin
        @(posedge clk_i);
    end
    

end

endmodule
