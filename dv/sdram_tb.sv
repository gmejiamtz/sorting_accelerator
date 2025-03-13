`timescale 1ns/1ps
module sdram_tb();

logic [0:0] clk_i;
logic [0:0] reset_i;
logic [0:0] go_i;
logic [12:0] addr_i;
logic [15:0] m_data_i;
logic [0:0] rw_en_i; //check if 0 is read or write
logic [0:0] read_valid_i;
logic [0:0] write_ready_i;

logic [0:0] read_ready_o;
logic [0:0] write_valid_o;
logic [1:0] bank_sel_o;
logic [0:0] CS_o;
logic [0:0] RAS_o;
logic [0:0] CAS_o;
logic [0:0] WE_o;
logic [0:0] CKE_o;
logic [15:0] m_data_o;
logic [12:0] addr_o;

wire [15:0] data_io;


//clock period is gonna be 7.5188 for 166mhz clock
parameter realtime ClockPeriod = 7.5188ns; //i think this is allowed, but i need to double check
initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

   
top 
#()
dut(
    .clk_i       (clk_i),
    .rst_i       (reset_i),
    .addr_i      (addr_i),
    .m_data_i    (m_data_i),
    .go_i        (go_i),
    .rw_en_i     (rw_en_i),
    .read_valid_i(read_valid_i),
    .write_ready_i(write_ready_i),
    .read_ready_o(read_ready_o),
    .write_valid_o(write_valid_o ),
    .bank_sel_o  (bank_sel_o),
    .CS_o        (CS_o),
    .RAS_o       (RAS_o),
    .CAS_o       (CAS_o),
    .WE_o        (WE_o),
    .CKE_o       (CKE_o),
    .m_data_o    (m_data_o),
    .addr_o      (addr_o),
    .data_io     (data_io)
);

// W9825G6KH 
// dut (
//     .Dq    (data_io),
//     .Addr  (addr_o),
//     .Bs    (bank_sel_o),
//     .Clk   (clk_i),
//     .Cke   (CKE_o),
//     .Cs_n  (CS_o),
//     .Ras_n (RAS_o),
//     .Cas_n (CAS_o),
//     .We_n  (WE_o),
//     .Dqm   ('b0) 
// );

initial begin
$dumpfile("sdram.vcd");
$dumpvars();
#100
reset_i = 1'b1;
@(posedge clk_i);
reset_i = 1'b0;

//handle ready valid signals 
//bank select already handled
addr_i = 13'b0;
//design assumes constant rw_en_i
// rw_en_i = 1'b1;
#1
go_i = 1'b1;
//for read
rw_en_i = 1'b0;
read_valid_i = 1'b1;
#10000
$display("test");
$finish();
end

endmodule
