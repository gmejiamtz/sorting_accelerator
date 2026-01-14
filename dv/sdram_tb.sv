`timescale 1ns/1ps
module sdram_tb();

localparam NumTests = 4;

logic [0:0] clk_i;
logic [0:0] reset_i;
logic [0:0] go_i;
logic [15:0] m_data_i;
logic [0:0] rw_en_i;
logic [0:0] read_valid_i;
logic [0:0] write_ready_i;

logic [0:0] read_ready_o;
logic [0:0] write_valid_o;
logic [1:0] bank_sel_o;

logic [0:0] uart_i;

logic [0:0] CS_o;
logic [0:0] RAS_o;
logic [0:0] CAS_o;
logic [0:0] WE_o;
logic [0:0] CKE_o;

// logic [0:0] refresh_o;

// logic [15:0] m_data_o;
// logic [12:0] row_col_addr_i;
logic [12:0] addr_o;
logic [12:0] row_addr_i, col_addr_i;
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

localparam burst_len_p = 2; 

top 
#(.burst_len_p(burst_len_p))
dut(
    .go_i           (go_i),
    .m_data_i       (),
    .m_data_o       (),
    .rw_en_i        (rw_en_i),
    .read_valid_i   (read_valid_i),
    .write_ready_i  (),
    .row_addr_i     (row_addr_i),
    .col_addr_i     (col_addr_i),
    .read_ready_o   (),
    .write_valid_o  (),
    .uart_i         (uart_i),
    
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

logic [width_p-1:0] tx_data_l [0:(burst_len_p - 1)];
logic [width_p-1:0] rx_data_l [0:(burst_len_p - 1)];
task t_initial();
    tx_tvalid_i = 1'b0;
    rx_tready_i = 1'b0;
    packet_tx = '0;
    reset_i = 1'b0;
    data_io_l = 16'hzzzz;
    tx_data_l = '{burst_len_p{$urandom_range(10, 20)}};
    rx_data_l = '{burst_len_p{'0}};

    @(negedge clk_i);

    reset_i = 1'b1;

    repeat(3)@(negedge clk_i);

    reset_i = 1'b0;
    
    assert($isunknown(dut.m_data_o));
    assert($isunknown(data_io));
endtask

task t_write_UART();
    uart_i = 1'b1;
    repeat(100)@(negedge clk_i);
    packet_tx = 8'd01;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);
    
    packet_tx = 8'd0; // row addr
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    packet_tx = 8'd50; // col addr
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    foreach (tx_data_l[i]) begin
        packet_tx = tx_data_l[i];
        tx_tvalid_i = 1'b1;
        @(negedge clk_i);
        @(posedge dut.rx_valid);
        tx_tvalid_i = 1'b0;
        @(negedge clk_i);
    end
    @(negedge dut.refresh_o);
    uart_i = 1'b0;

    assert(dut.rx_buff[3:(burst_len_p + 2)] == tx_data_l) else begin
        $error("Read Buffer != Input Data!\n");
        $display("Read Buffer: %0p", dut.read_buff);
        $display("Input Data: %0p", tx_data_l);
    end
    @(negedge clk_i);
endtask

task t_write_IO();
    uart_i = 1'b0;
    packet_tx = 8'd01;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    foreach (tx_data_l[i]) begin
        packet_tx = tx_data_l[i];
        tx_tvalid_i = 1'b1;
        @(negedge clk_i);
        @(posedge dut.rx_valid);
        tx_tvalid_i = 1'b0;
        @(negedge clk_i);
    end

    @(negedge dut.refresh_o);

    assert(dut.rx_buff[3 : (burst_len_p + 2)] == tx_data_l) else begin
        $error("Read Buffer != Input Data!\n");
        $display("Read Buffer: %0p", dut.read_buff);
        $display("Input Data: %0p", tx_data_l);
    end
endtask

int j = 0;
task t_read_UART();
    uart_i = 1'b1;
    packet_tx = 8'd0;
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    packet_tx = 8'd00; // row addr
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    packet_tx = 8'd50; // col addr
    tx_tvalid_i = 1'b1;
    @(negedge clk_i);
    @(posedge dut.rx_valid);
    tx_tvalid_i = 1'b0;
    @(negedge clk_i);

    foreach (tx_data_l[i]) begin
        packet_tx = 8'd0;
        tx_tvalid_i = 1'b1;
        @(negedge clk_i);
        @(posedge dut.rx_valid);
        tx_tvalid_i = 1'b0;
        @(negedge clk_i);
    end


    while (j != burst_len_p) begin
        // $display("MEM STATE: %s", dut.memory_controller_sm.state_q.name());
        @(posedge dut.tx_ready_o);
        uart_i = 1'b0;
        tx_tvalid_i = 1'b1;
        @(posedge tx_tready_o);
        assert(rx_data_o == tx_data_l[j]) else $error("Received Data != Input Data[%0d]\n", j);
        rx_data_l[j] = rx_data_o;
        j++;
        @(negedge clk_i);
        tx_tvalid_i = 1'b0;
    end
    tx_tvalid_i = 1'b0;

    j = 0;
endtask

task t_read_IO();
    uart_i = 1'b0;
    rw_en_i = 1'b0;
    read_valid_i = 1'b0;
    go_i = 1'b1;

    row_addr_i = '0;
    col_addr_i = 8'd50;

    @(negedge clk_i);
    go_i = 1'b0;

    @(negedge clk_i);
    data_io_l = 'z;
    
    @(negedge clk_i);
    read_valid_i = 1'b1;

    @(negedge clk_i);

    while (j != burst_len_p) begin
        if (dut.read_ready_o) begin
            assert(data_io == tx_data_l[j]) else begin
                $error("Data Read from Ports != Expected Data");
                $error("Data IO: %0d", data_io);
                $error("Expected Data: %0d\n", tx_data_l[j]);
            end
            j++;
        end
        @(negedge clk_i);
    end

    j = 0;
    @(negedge dut.refresh_o);
    read_valid_i = 1'b0;
    $display("\n\n");
endtask

// UART Test
int i = 0;
initial begin
    $display("Running Initial\n");
    t_initial();
    @(negedge clk_i);

    repeat(NumTests) begin
        $display("\n\n======================");
        $display("Write Test for UART %0d", i);
        $display("======================\n\n");
        t_write_UART();
        @(negedge clk_i);

        $display("\n\n======================");
        $display("Read Test for UART %0d", i);
        $display("======================\n\n");
        t_read_UART();
        @(negedge clk_i);
    
        // // $display("Write Test for IO %0d", i);
        // // $display("======================\n\n");
        // // t_write_IO();
        // // @(negedge clk_i);

        $display("\n\n======================");
        $display("Read Test for IO %0d", i);
        $display("======================\n\n");
        t_read_IO();
        @(negedge clk_i);
        i++;
    end

    $finish();
end

endmodule