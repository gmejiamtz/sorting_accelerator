module top(
    input clk_i,
    input reset_i,
    input rx_i,
    input sw,
    output tx_o
);

//RX to FIFO signals
logic [7:0] rx_to_fifo_data;
logic rx_to_fifo_valid, fifo_to_rx_ready;

//FIFO to SIPO
logic [7:0] fifo_to_sipo_data;
logic fifo_to_sipo_valid, sipo_to_fifo_ready;

//SIPO to FIFO
logic [31:0] sipo_to_fifo_data;
logic sipo_to_fifo_valid, fifo_to_sipo_ready;

//FIFO to CORE
logic [31:0] fifo_to_core_data;
logic fifo_to_core_valid, core_to_fifo_ready;

//CORE to FIFO
logic [31:0] core_to_fifo_data;
logic core_to_fifo_valid, fifo_to_core_ready;

//FIFO to PISO
logic [31:0] fifo_to_piso_data;
logic fifo_to_piso_valid, piso_to_fifo_ready;

//PISO to FIFO
logic [7:0] piso_to_fifo_data;
logic piso_to_fifo_valid, fifo_to_piso_ready;


//FIFO to TX
logic [7:0] fifo_to_tx_data;
logic fifo_to_tx_valid, tx_to_fifo_ready;

uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
    .clk(clk_i),
    .rst(reset_i),
    .m_axis_tdata(rx_to_fifo_data),
    .m_axis_tvalid(rx_to_fifo_valid),
    .m_axis_tready(fifo_to_rx_ready),
    .rxd(rx_i),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale(16'd35)
);

axis_pipeline_fifo #(
    .LENGTH(4),
    .DATA_WIDTH(8),
    .KEEP_ENABLE(0),
    .LAST_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0)
) rx_to_sipo_fifo_inst (
    .clk(clk_i),
    .rst(reset_i),

    // The signals you care about
    .s_axis_tdata(rx_to_fifo_data),
    .s_axis_tvalid(rx_to_fifo_valid),
    .s_axis_tready(fifo_to_rx_ready),

    .m_axis_tdata(fifo_to_sipo_data),
    .m_axis_tvalid(fifo_to_sipo_valid),
    .m_axis_tready(sipo_to_fifo_ready),

    .s_axis_tkeep(0),
    .s_axis_tlast(0),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(0)
);

sipo_8_to_32 sipo_inst (
    .clk_i(clk_i),
    .resetn_i(!reset_i),
    .data_i(fifo_to_sipo_data),
    .valid_i(fifo_to_sipo_valid),
    .ready_o(sipo_to_fifo_ready),
    .data_o(sipo_to_fifo_data),
    .valid_o(sipo_to_fifo_valid),
    .ready_i(fifo_to_sipo_ready)
);

axis_pipeline_fifo #(
    .LENGTH(4),
    .DATA_WIDTH(32),
    .KEEP_ENABLE(0),
    .LAST_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0)
) sipo_to_core_fifo_inst (
    .clk(clk_i),
    .rst(reset_i),

    // The signals you care about
    .s_axis_tdata(sipo_to_fifo_data),
    .s_axis_tvalid(sipo_to_fifo_valid),
    .s_axis_tready(fifo_to_sipo_ready),

    .m_axis_tdata(fifo_to_core_data),
    .m_axis_tvalid(fifo_to_core_valid),
    .m_axis_tready(core_to_fifo_ready),

    .s_axis_tkeep(0),
    .s_axis_tlast(0),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(0)
);

bitonic_sorter_core core_inst (
    .clk_i(clk_i),
    .resetn_i(!reset_i),
    //Inputs
    .descend_i(sw),
    .packet_valid_i(fifo_to_core_valid),
    .packet_data_i(fifo_to_core_data),
    .packet_ready_o(core_to_fifo_ready),
    //Outputs
    .valid_o(core_to_fifo_valid),
    .ready_i(fifo_to_core_ready),
    .data_o(core_to_fifo_data)
);

axis_pipeline_fifo #(
    .LENGTH(4),
    .DATA_WIDTH(32),
    .KEEP_ENABLE(0),
    .LAST_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0)
) core_to_piso_fifo_inst (
    .clk(clk_i),
    .rst(reset_i),

    // The signals you care about
    .s_axis_tdata(core_to_fifo_data),
    .s_axis_tvalid(core_to_fifo_valid),
    .s_axis_tready(fifo_to_core_ready),

    .m_axis_tdata(fifo_to_piso_data),
    .m_axis_tvalid(fifo_to_piso_valid),
    .m_axis_tready(piso_to_fifo_ready),

    .s_axis_tkeep(0),
    .s_axis_tlast(0),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(0)
);

piso_32_to_8 piso_inst (
    .clk_i(clk_i),
    .resetn_i(!reset_i),
    .data_i(fifo_to_piso_data),
    .valid_i(fifo_to_piso_valid),
    .ready_o(piso_to_fifo_ready),
    .data_o(piso_to_fifo_data),
    .valid_o(piso_to_fifo_valid),
    .ready_i(fifo_to_piso_ready)
);

axis_pipeline_fifo #(
    .LENGTH(4),
    .DATA_WIDTH(8),
    .KEEP_ENABLE(0),
    .LAST_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(0)
) piso_to_tx_fifo_inst (
    .clk(clk_i),
    .rst(reset_i),

    // The signals you care about
    .s_axis_tdata(piso_to_fifo_data),
    .s_axis_tvalid(piso_to_fifo_valid),
    .s_axis_tready(fifo_to_piso_ready),

    .m_axis_tdata(fifo_to_tx_data),
    .m_axis_tvalid(fifo_to_tx_valid),
    .m_axis_tready(tx_to_fifo_ready),

    .s_axis_tkeep(0),
    .s_axis_tlast(0),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(0)
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk_i),
    .rst(reset_i),
    .s_axis_tdata(fifo_to_tx_data), // input
    .s_axis_tvalid(fifo_to_tx_valid), // input
    .s_axis_tready(tx_to_fifo_ready), // output
    .txd(tx_o),
    .busy(),
    .prescale(16'd35)
);

endmodule
