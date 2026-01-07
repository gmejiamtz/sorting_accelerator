`timescale 1ns/1ps
module top(
    // input   logic   [15:0]  m_data_i, // Instructions given to memory controller
    // input   logic   [0:0]   go_i,
    // input   logic   [0:0]   rw_en_i, // Assuming constant signal
    // input   logic   [0:0]   read_valid_i,
    // input   logic   [0:0]   write_ready_i,
    // input   logic   [12:0]  row_col_addr_i,
    // output  logic   [0:0]   read_ready_o,
    // output  logic   [0:0]   write_valid_o,

    input   logic   [0:0]   clk_i,
    input   logic   [0:0]   rst_i,

    input   logic   [0:0]   rx_i,
    output  logic   [0:0]   tx_o,

    output  logic   [1:0]   sdram_ba,
    output  logic   [0:0]   sdram_csn,
    output  logic   [0:0]   sdram_rasn,
    output  logic   [0:0]   sdram_casn,
    output  logic   [0:0]   sdram_wen,
    output  logic   [0:0]   sdram_cke,
    // output  logic   [15:0]  m_data_o, // Data going out of memory controller
    output  logic   [12:0]  sdram_a,
    output  logic   [1:0]   sdram_dqm,

    output logic    [0:0]   refresh_o,
    
    inout           [15:0]  sdram_d
);

assign sdram_dqm = 2'b00;

localparam width_p = 8;
localparam prescale_p = 90; // Might work for 165MHz clock? Intended 11200 baud rate
localparam burst_len_p = 8;

logic [0:0] rw_en_i, read_ready_o, read_valid_i, write_ready_i;
logic [0:0] write_valid_o;
// logic [0:0] refresh_o;
logic [12:0] row_addr_i, col_addr_i;
logic [15:0] m_data_i, m_data_o;

logic [0:0] tx_busy_d, tx_busy_q, rx_busy_d, rx_busy_q;
logic [width_p-1:0] tx_data_i;
logic [1:0] state_d, state_q;
uart_tx #(.DATA_WIDTH(width_p))
 tx_inst(
    .clk(clk_i),
    .rst(rst_i),
    .s_axis_tdata(tx_data_i), //i
    .s_axis_tvalid(state_d == 2'b11), //i
    .s_axis_tready(), //o
    .txd(tx_o), //o
    .busy(tx_busy_d),
    .prescale(prescale_p)
);

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        tx_busy_q <= 1'b0;
        rx_busy_q <= 1'b0;
    end else begin
        tx_busy_q <= tx_busy_d;
        rx_busy_q <= rx_busy_d;
    end
end


logic [width_p-1:0] packet_rx;
logic [0:0] rx_valid, rx_valid_q, busy_rx;

uart_rx #(.DATA_WIDTH(width_p))
 rx_inst(
    .clk(clk_i),
    .rst(rst_i),
    .m_axis_tdata(packet_rx), //o
    .m_axis_tvalid(rx_valid), //o
    .m_axis_tready(!busy_rx), //i
    .rxd(rx_i), //i
    .busy(busy_rx),
    .overrun_error(),
    .frame_error(),
    .prescale(prescale_p)
);

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        rx_valid_q <= 1'b0;
    end else begin
        rx_valid_q <= rx_valid;
    end
end

localparam BS0 = 1'b1;
localparam BS1 = 1'b0;

assign sdram_ba = {BS1, BS0};

logic [0:0] rw_o;
assign sdram_d = (state_d == 2'b10) ? m_data_i : 16'hzzzz;

always_ff @(posedge clk_i) begin : blockB
    if (rst_i) begin
        state_q <= 2'b00;
    end else begin
        state_q <= state_d;
    end
end

logic [$clog2(burst_len_p)+1:0] read_cnt_d, read_cnt_q;
logic [$clog2(burst_len_p)+1:0] write_cnt_d, write_cnt_q;

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        read_cnt_q <= '0;
        write_cnt_q <= '0;
    end else begin
        read_cnt_q <= read_cnt_d;
        write_cnt_q <= write_cnt_d;
    end
end

logic [width_p-1:0] rx_buff [0:12];
always_ff @(posedge clk_i) begin
    if (rst_i || refresh_o) begin
        rw_en_i <= 1'b0;
        row_addr_i <= '0;
        col_addr_i <= '0;
    end else if (rx_valid) begin
        rw_en_i <= rx_buff[0];
        row_addr_i <= rx_buff[1];
        col_addr_i <= rx_buff[2];
    end
end

logic [width_p-1:0] read_buff [0:8];
logic [15:0] sdram_d_q;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        ;
    end
    else if ((state_q == 2'b01)) begin
        sdram_d_q <= sdram_d;
        read_buff[read_cnt_q] <= sdram_d_q;
    end
end

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        ;
    end else if ((state_q == 0) && rx_valid && (read_cnt_q != (burst_len_p + 3))) begin
        rx_buff[read_cnt_q] <= packet_rx;
    end
end

always_comb begin : blockA
    m_data_o = (state_d == 2'b01) ? sdram_d : 16'hzzzz;
    m_data_i = 16'hzzzz;
    tx_data_i = {width_p{1'b0}};
    
    state_d = state_q;
    read_valid_i = 1'b0;
    write_ready_i = 1'b0;

    read_cnt_d = read_cnt_q;
    write_cnt_d = write_cnt_q;

    case (state_q)
        2'b00 : begin
            state_d = 2'b00;
            if (read_cnt_q != (burst_len_p + 3)) begin
                if (rx_valid && !rx_valid_q) begin
                    read_cnt_d = read_cnt_q + 1;
                end
            end
            else begin
                read_cnt_d = '0;
                if (!rw_en_i) begin
                    state_d = 2'b01;
                    read_cnt_d = 0;
                    
                end else if (rw_en_i) begin
                    state_d = 2'b10;
                    read_cnt_d = 3;
                    write_ready_i = 1'b1;
                end
            end
        end

        2'b01 : begin //READ
            state_d = 2'b01;
            read_valid_i = 1'b1;
            if (read_ready_o && (read_cnt_q != (burst_len_p[3:0]))) begin
                read_cnt_d = read_cnt_q + 1;
            end
            else if (read_cnt_q == (burst_len_p[3:0])) begin
                read_cnt_d = '0;
                state_d = 2'b11;
                read_valid_i = 1'b0;
            end
        end

        2'b10 : begin //WRITE
            state_d = 2'b10;
            write_ready_i = 1'b1;
            m_data_i = rx_buff[read_cnt_q];
            if (read_cnt_q == (burst_len_p[3:0] + 3)) begin
                m_data_i = 16'hzzzz;
                write_ready_i = 1'b0;
                if (refresh_o) begin
                    read_cnt_d = '0;
                    state_d = 2'b00;
                end
            end
            if (write_valid_o) begin
                m_data_i = rx_buff[read_cnt_q];
                if (read_cnt_q != (burst_len_p[3:0] + 3)) begin
                    read_cnt_d = read_cnt_q + 1;
                end
            end
        end

        2'b11 : begin //TX_O
            state_d = 2'b11;
            if (write_cnt_q == burst_len_p) begin 
                state_d = 2'b00;
                read_cnt_d = '0;
            end else begin
                if (!tx_busy_d && tx_busy_q) begin
                    //TRANSMIT DATA FROM 2D BUFF
                    tx_data_i = read_buff[write_cnt_q];
                    write_cnt_d = write_cnt_q + 1;
                end
            end
        end
    endcase

end

sm memory_controller_sm (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .go_i(read_cnt_q == (burst_len_p[3:0] + 3)),
    .rw_en_i(rw_en_i),
    .read_valid_i(read_valid_i),
    .write_ready_i(write_ready_i),
    .row_addr_i(row_addr_i),
    .col_addr_i(col_addr_i),
    .ic_CS_o(sdram_csn),
    .ic_CAS_o(sdram_casn),
    .ic_RAS_o(sdram_rasn),
    .ic_WE_o(sdram_wen),
    .ic_CKE_o(sdram_cke),
    .read_ready_o(read_ready_o),
    .write_valid_o(write_valid_o),
    .addr_o(sdram_a),
    .refresh_o(refresh_o),
    .rw_o(rw_o)
);

endmodule
