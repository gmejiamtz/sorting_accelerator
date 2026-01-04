`timescale 1ns/1ps
module top(
    input   logic   [0:0]   clk_i,
    input   logic   [0:0]   rst_i,
    input   logic   [12:0]  addr_i,
    input   logic   [15:0]  m_data_i, // Instructions given to memory controller
    input   logic   [0:0]   go_i,
    input   logic   [0:0]   rw_en_i, // Assuming constant signal
    input   logic   [0:0]   read_valid_i,
    input   logic   [0:0]   write_ready_i,
    input   logic   [12:0]  row_col_addr_i,
    output  logic   [0:0]   read_ready_o,
    output  logic   [0:0]   write_valid_o,
    output  logic   [1:0]   bank_sel_o,
    output  logic   [0:0]   CS_o,
    output  logic   [0:0]   RAS_o,
    output  logic   [0:0]   CAS_o,
    output  logic   [0:0]   WE_o,
    output  logic   [0:0]   CKE_o,
    output  logic   [15:0]  m_data_o, // Data going out of memory controller
    output  logic   [12:0]  addr_o,

    output logic    [0:0]   refresh_o,
    
    inout           [15:0]  data_io       
    // inout           [7:0]   data_io
);

localparam BS0 = 1'b1;
localparam BS1 = 1'b0;

assign bank_sel_o = {BS1, BS0};

logic [0:0] rw_o;
assign data_io = rw_o ? m_data_i : 16'hzzzz;


always_comb begin
    m_data_o = read_ready_o ? data_io : 16'hzzzz;
end

sm memory_controller_sm (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .go_i(go_i),
    .rw_en_i(rw_en_i),
    .read_valid_i(read_valid_i),
    .write_ready_i(write_ready_i),
    .row_col_addr_i(row_col_addr_i),
    .ic_CS_o(CS_o),
    .ic_CAS_o(CAS_o),
    .ic_RAS_o(RAS_o),
    .ic_WE_o(WE_o),
    .ic_CKE_o(CKE_o),
    .read_ready_o(read_ready_o),
    .write_valid_o(write_valid_o),
    .addr_o(addr_o),
    .refresh_o(refresh_o),
    .rw_o(rw_o)
);

endmodule