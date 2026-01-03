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
    output logic    [0:0]   refresh_o,
    output  logic   [15:0]  m_data_o, // Data going out of memory controller

    output  logic   [1:0]   sdram_ba,
    output  logic   [0:0]   sdram_csn,
    output  logic   [0:0]   sdram_rasn,
    output  logic   [0:0]   sdram_casn,
    output  logic   [0:0]   sdram_wen,
    output  logic   [0:0]   sdram_cke,
    output  logic   [12:0]  sdram_a,
    
    inout   logic   [15:0]  sdram_d    
);

    localparam BS0 = 1'b1;
    localparam BS1 = 1'b0;

    logic [15:0] sdram_d_out;
    logic [15:0] sdram_d_in;

    assign sdram_d   = rw_en_i ? sdram_d_out : 16'bz;
    assign sdram_d_in = sdram_d;

    always_comb begin
        if (rw_en_i) begin
            sdram_d_out = m_data_i;
        end else begin
            sdram_d_out = '0;
        end
    end

    logic [15:0] read_data_r;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            read_data_r <= 16'b0;
        end else if (read_valid_i) begin
            read_data_r <= sdram_d_in;
        end
    end

    assign m_data_o = read_data_r;

    logic [0:0] sm_write_valid_o, sm_read_ready_o;  
    sm memory_controller_sm (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .go_i(go_i),
        .rw_en_i(rw_en_i),
        .read_valid_i(read_valid_i),
        .write_ready_i(write_ready_i),
        .row_col_addr_i(row_col_addr_i),
        .ic_CS_o(sdram_csn),
        .ic_CAS_o(sdram_casn),
        .ic_RAS_o(sdram_rasn),
        .ic_WE_o(sdram_wen),
        .ic_CKE_o(sdram_cke),
        .read_ready_o(read_ready_o),
        .write_valid_o(write_valid_o),
        .addr_o(sdram_a),
        .refresh_o(refresh_o)
    );





endmodule
