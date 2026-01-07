`timescale 1ns/1ps
module sdram_tb();

localparam NumTests = 1;

logic [0:0] clk_i;
logic [0:0] reset_i;
// logic [0:0] go_i;
// logic [15:0] m_data_i;
// logic [0:0] rw_en_i; //check if 0 is read or write
// logic [0:0] read_valid_i;
// logic [0:0] write_ready_i;

// logic [0:0] read_ready_o;
// logic [0:0] write_valid_o;
logic [1:0] bank_sel_o;
logic [0:0] CS_o;
logic [0:0] RAS_o;
logic [0:0] CAS_o;
logic [0:0] WE_o;
logic [0:0] CKE_o;

// logic [0:0] refresh_o;

// logic [15:0] m_data_o;
// logic [12:0] row_col_addr_i;
logic [12:0] addr_o;
wire [15:0] data_io;

logic [0:0] rx_o, tx_i;

logic [15:0] data_io_l;
assign data_io = data_io_l;



//clock period is gonna be 7.5188 for 133mhz clock
// 6.06 for 165MHz
parameter realtime ClockPeriod = 6.06ns; //i think this is allowed, but i need to double check
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
    .clk_i          (clk_i),
    .rst_i          (reset_i),
    .rx_i           (rx_o),
    .tx_o           (tx_i),
    .sdram_ba       (bank_sel_o),
    .sdram_csn      (CS_o),
    .sdram_rasn     (RAS_o),
    .sdram_casn     (CAS_o),
    .sdram_wen      (WE_o),
    .sdram_cke      (CKE_o),
    .sdram_a        (addr_o),
    .refresh_o      (refresh_o),
    .sdram_dqm      (),
    .sdram_d        (data_io)
);

W9825G6KH uut (
    .Dq    (data_io),
    .Addr  (addr_o),
    .Bs    (bank_sel_o),
    .Clk   (clk_i),
    .Cke   (CKE_o),
    .Cs_n  (CS_o),
    .Ras_n (RAS_o),
    .Cas_n (CAS_o),
    .We_n  (WE_o),
    .Dqm   ('b0) 
);

localparam width_p = 8;
localparam prescale_p = 90; // Might work for 165MHz clock? Intended 11200 baud rate
localparam burst_len_p = 8;

logic [width_p-1:0] packet_tx;
logic [0:0] tx_tvalid_i, tx_tready_o, busy_tx;

uart_tx #(.DATA_WIDTH(width_p))
 tb_tx_inst(
    .clk(clk_i),
    .rst(reset_i),
    .s_axis_tdata(packet_tx), //i
    .s_axis_tvalid(tx_tvalid_i), //i
    .s_axis_tready(tx_tready_o), //o
    .txd(rx_o), //o
    .busy(busy_tx),
    .prescale(prescale_p)
);

logic [width_p-1:0] rx_data_o;
logic [0:0] rx_tvalid_o, rx_tready_i;
uart_rx #(.DATA_WIDTH(width_p))
 tb_rx_inst(
    .clk(clk_i),
    .rst(reset_i),
    .m_axis_tdata(rx_data_o), //o
    .m_axis_tvalid(rx_tvalid_o), //o
    .m_axis_tready(rx_tready_i), //i
    .rxd(tx_i), //i
    .busy(),
    .overrun_error(),
    .frame_error(),
    .prescale(prescale_p)
);


task t_initial();
    tx_tvalid_i = 1'b0;
    rx_tready_i = 1'b0;
    packet_tx = '0;
    reset_i = 1'b0;
    data_io_l = 16'hzzzz;

    @(negedge clk_i);

    reset_i = 1'b1;

    repeat(3)@(negedge clk_i);

    reset_i = 1'b0;
endtask

task t_write();

    $display("Sending rw_en_i");
    packet_tx = 8'd01;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending row_addr");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending col_addr");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Write Entry 0");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);
    

    $display("Sending Write Entry 1");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Write Entry 2");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Write Entry 3");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Write Entry 4");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Write Entry 5");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Write Entry 6");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Write Entry 7");
    packet_tx = $urandom_range(10, 20);
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);

    @(negedge dut.refresh_o);

    $display("DUT State: %0d", dut.state_q);
    $display("Memory State: %0d", dut.memory_controller_sm.state_q);
endtask

task t_read();
    $display("Sending rw_en_i");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending row_addr");
    packet_tx = 8'd00;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending col_addr");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Read Entry 0");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);
    

    $display("Sending Read Entry 1");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Read Entry 2");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Read Entry 3");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Read Entry 4");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Read Entry 5");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Read Entry 6");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);
    @(negedge clk_i);

    $display("Sending Read Entry 7");
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    $display("Sent Packet: %0b", packet_tx[7:0]);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    $display("Read Count: %0d", dut.read_cnt_q);
    $display("Received Packet: %0b\n", dut.packet_rx);

    repeat(10)@(negedge clk_i);
    $display("DUT State: %0d", dut.state_q);
    $display("Read Count: %0d", dut.read_cnt_q);

    @(dut.state_q == 2'b11);
    $display("Entered TX_O State");
    repeat(20)@(negedge clk_i);
    $display("read_buff[0] = %0h", dut.read_buff[0]);
    $display("read_buff[1] = %0h", dut.read_buff[1]);
    $display("read_buff[2] = %0h", dut.read_buff[2]);
    $display("read_buff[3] = %0h", dut.read_buff[3]);
    $display("read_buff[4] = %0h", dut.read_buff[4]);
    $display("read_buff[5] = %0h", dut.read_buff[5]);
    $display("read_buff[6] = %0h", dut.read_buff[6]);
    $display("read_buff[7] = %0h", dut.read_buff[7]);
    // while(dut.state_q != 2'b00) begin
    //     $display("Count");
    // end

endtask

// UART Test
int i = 0;
initial begin
    $display("Running Initial\n");
    t_initial();
    @(negedge clk_i);

    repeat(NumTests) begin
        $display("Write Test %0d\n\n", i);
        t_write();
        @(negedge clk_i);

        $display("Read Test %0d\n\n", i);
        i++;
        t_read();
        @(negedge clk_i);
    end

    $finish();
end

endmodule