module top(
    input clk,
    input rst,
    input rx_i,
    output tx_o,
);

logic [7:0] rx_data_out;
logic rx_valid_out;
logic tx_ready;

uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
    .clk(clk),
    .rst(rst),
    .m_axis_tdata(rx_data_out), // output
    .m_axis_tvalid(rx_valid_out), // output
    .m_axis_tready(tx_ready), // input
    .rxd(rx_i),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale(16'd35)
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(rx_data_out), // input
    .s_axis_tvalid(rx_valid_out), // input
    .s_axis_tready(tx_ready), // output
    .txd(tx_o),
    .busy(),
    .prescale(16'd35)
);

endmodule
