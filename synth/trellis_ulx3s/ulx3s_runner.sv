`timescale 1ns/1ps
module ulx3s_runner;

logic clkin,clk;
logic reset_ni;
logic tx_o, rx_i;
logic [7:0] rx_data, tx_data;
logic rx_valid, tx_valid;

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

uart_rx #(.DATA_WIDTH(8)) uart_rx_inst (
    .clk(clk),
    .rst(!reset_ni),
    .m_axis_tdata(rx_data),
    .m_axis_tvalid(rx_valid),
    .m_axis_tready(),
    .rxd(tx_o),
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale(16'd35)
);

uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk),
    .rst(!reset_ni),
    .s_axis_tdata(tx_data), // input
    .s_axis_tvalid(tx_valid), // input
    .s_axis_tready(), // output
    .txd(rx_i),
    .busy(),
    .prescale(16'd35)
);


ulx3s ulx3s (
    .clk_25mhz(clkin),
    .reset_ni(reset_ni),
    .ftdi_rxd(tx_o),
    .ftdi_txd(rx_i),
    .sw(0)
);

assign ulx3s.pll.CLKOP = clk;

task automatic reset;
    reset_ni = 0;
    tx_data = '0;
    tx_valid = '0;
    @(posedge clk);
    reset_ni = 1;
endtask

task automatic send_byte(input [7:0] byte_i);
    begin
        @(negedge clk);
        tx_data = byte_i;
        tx_valid = 1;
    end
endtask

task automatic wait_n_cycles(integer n);
    repeat (n) begin
        @(posedge clk);
    end
endtask

endmodule
