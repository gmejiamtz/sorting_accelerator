/*

Copyright (c) 2020 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * AXI4 lite 2x1 interconnect (wrapper)
 */
module pico_and_sorter_to_mem #
(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter M_REGIONS = 1,
    parameter M00_BASE_ADDR = 0,
    parameter M00_ADDR_WIDTH = {M_REGIONS{32'd24}},
    parameter M00_CONNECT_READ = 2'b11,
    parameter M00_CONNECT_WRITE = 2'b11,
    parameter M00_SECURE = 1'b0
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI lite slave interfaces
     */
    input  wire [ADDR_WIDTH-1:0]    s00_axil_awaddr,
    input  wire [2:0]               s00_axil_awprot,
    input  wire                     s00_axil_awvalid,
    output wire                     s00_axil_awready,
    input  wire [DATA_WIDTH-1:0]    s00_axil_wdata,
    input  wire [STRB_WIDTH-1:0]    s00_axil_wstrb,
    input  wire                     s00_axil_wvalid,
    output wire                     s00_axil_wready,
    output wire [1:0]               s00_axil_bresp,
    output wire                     s00_axil_bvalid,
    input  wire                     s00_axil_bready,
    input  wire [ADDR_WIDTH-1:0]    s00_axil_araddr,
    input  wire [2:0]               s00_axil_arprot,
    input  wire                     s00_axil_arvalid,
    output wire                     s00_axil_arready,
    output wire [DATA_WIDTH-1:0]    s00_axil_rdata,
    output wire [1:0]               s00_axil_rresp,
    output wire                     s00_axil_rvalid,
    input  wire                     s00_axil_rready,

    input  wire [ADDR_WIDTH-1:0]    s01_axil_awaddr,
    input  wire [2:0]               s01_axil_awprot,
    input  wire                     s01_axil_awvalid,
    output wire                     s01_axil_awready,
    input  wire [DATA_WIDTH-1:0]    s01_axil_wdata,
    input  wire [STRB_WIDTH-1:0]    s01_axil_wstrb,
    input  wire                     s01_axil_wvalid,
    output wire                     s01_axil_wready,
    output wire [1:0]               s01_axil_bresp,
    output wire                     s01_axil_bvalid,
    input  wire                     s01_axil_bready,
    input  wire [ADDR_WIDTH-1:0]    s01_axil_araddr,
    input  wire [2:0]               s01_axil_arprot,
    input  wire                     s01_axil_arvalid,
    output wire                     s01_axil_arready,
    output wire [DATA_WIDTH-1:0]    s01_axil_rdata,
    output wire [1:0]               s01_axil_rresp,
    output wire                     s01_axil_rvalid,
    input  wire                     s01_axil_rready,

    /*
     * AXI lite master interfaces
     */
    output wire [ADDR_WIDTH-1:0]    m00_axil_awaddr,
    output wire [2:0]               m00_axil_awprot,
    output wire                     m00_axil_awvalid,
    input  wire                     m00_axil_awready,
    output wire [DATA_WIDTH-1:0]    m00_axil_wdata,
    output wire [STRB_WIDTH-1:0]    m00_axil_wstrb,
    output wire                     m00_axil_wvalid,
    input  wire                     m00_axil_wready,
    input  wire [1:0]               m00_axil_bresp,
    input  wire                     m00_axil_bvalid,
    output wire                     m00_axil_bready,
    output wire [ADDR_WIDTH-1:0]    m00_axil_araddr,
    output wire [2:0]               m00_axil_arprot,
    output wire                     m00_axil_arvalid,
    input  wire                     m00_axil_arready,
    input  wire [DATA_WIDTH-1:0]    m00_axil_rdata,
    input  wire [1:0]               m00_axil_rresp,
    input  wire                     m00_axil_rvalid,
    output wire                     m00_axil_rready
);

localparam S_COUNT = 2;
localparam M_COUNT = 1;

// parameter sizing helpers
function [ADDR_WIDTH*M_REGIONS-1:0] w_a_r(input [ADDR_WIDTH*M_REGIONS-1:0] val);
    w_a_r = val;
endfunction

function [32*M_REGIONS-1:0] w_32_r(input [32*M_REGIONS-1:0] val);
    w_32_r = val;
endfunction

function [S_COUNT-1:0] w_s(input [S_COUNT-1:0] val);
    w_s = val;
endfunction

function w_1(input val);
    w_1 = val;
endfunction

axil_interconnect #(
    .S_COUNT(S_COUNT),
    .M_COUNT(M_COUNT),
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .STRB_WIDTH(STRB_WIDTH),
    .M_REGIONS(M_REGIONS),
    .M_BASE_ADDR({ w_a_r(M00_BASE_ADDR) }),
    .M_ADDR_WIDTH({ w_32_r(M00_ADDR_WIDTH) }),
    .M_CONNECT_READ({ w_s(M00_CONNECT_READ) }),
    .M_CONNECT_WRITE({ w_s(M00_CONNECT_WRITE) }),
    .M_SECURE({ w_1(M00_SECURE) })
)
axil_interconnect_inst (
    .clk(clk),
    .rst(rst),
    .s_axil_awaddr({ s01_axil_awaddr, s00_axil_awaddr }),
    .s_axil_awprot({ s01_axil_awprot, s00_axil_awprot }),
    .s_axil_awvalid({ s01_axil_awvalid, s00_axil_awvalid }),
    .s_axil_awready({ s01_axil_awready, s00_axil_awready }),
    .s_axil_wdata({ s01_axil_wdata, s00_axil_wdata }),
    .s_axil_wstrb({ s01_axil_wstrb, s00_axil_wstrb }),
    .s_axil_wvalid({ s01_axil_wvalid, s00_axil_wvalid }),
    .s_axil_wready({ s01_axil_wready, s00_axil_wready }),
    .s_axil_bresp({ s01_axil_bresp, s00_axil_bresp }),
    .s_axil_bvalid({ s01_axil_bvalid, s00_axil_bvalid }),
    .s_axil_bready({ s01_axil_bready, s00_axil_bready }),
    .s_axil_araddr({ s01_axil_araddr, s00_axil_araddr }),
    .s_axil_arprot({ s01_axil_arprot, s00_axil_arprot }),
    .s_axil_arvalid({ s01_axil_arvalid, s00_axil_arvalid }),
    .s_axil_arready({ s01_axil_arready, s00_axil_arready }),
    .s_axil_rdata({ s01_axil_rdata, s00_axil_rdata }),
    .s_axil_rresp({ s01_axil_rresp, s00_axil_rresp }),
    .s_axil_rvalid({ s01_axil_rvalid, s00_axil_rvalid }),
    .s_axil_rready({ s01_axil_rready, s00_axil_rready }),
    .m_axil_awaddr({ m00_axil_awaddr }),
    .m_axil_awprot({ m00_axil_awprot }),
    .m_axil_awvalid({ m00_axil_awvalid }),
    .m_axil_awready({ m00_axil_awready }),
    .m_axil_wdata({ m00_axil_wdata }),
    .m_axil_wstrb({ m00_axil_wstrb }),
    .m_axil_wvalid({ m00_axil_wvalid }),
    .m_axil_wready({ m00_axil_wready }),
    .m_axil_bresp({ m00_axil_bresp }),
    .m_axil_bvalid({ m00_axil_bvalid }),
    .m_axil_bready({ m00_axil_bready }),
    .m_axil_araddr({ m00_axil_araddr }),
    .m_axil_arprot({ m00_axil_arprot }),
    .m_axil_arvalid({ m00_axil_arvalid }),
    .m_axil_arready({ m00_axil_arready }),
    .m_axil_rdata({ m00_axil_rdata }),
    .m_axil_rresp({ m00_axil_rresp }),
    .m_axil_rvalid({ m00_axil_rvalid }),
    .m_axil_rready({ m00_axil_rready })
);

endmodule

`resetall
