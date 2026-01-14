`timescale 1ns/1ps
module top
#(
    parameter burst_len_p = 8
)(
    input   logic   [0:0]   go_i,
    input   logic   [15:0]  m_data_i, // Instructions given to memory controller
    output  logic   [15:0]  m_data_o, // Data going out of memory controller
    input   logic   [0:0]   rw_en_i, // Assuming constant signal
    input   logic   [0:0]   read_valid_i,
    input   logic   [0:0]   write_ready_i,
    input   logic   [12:0]  row_addr_i,
    input   logic   [12:0]  col_addr_i,
    output  logic   [0:0]   read_ready_o,
    output  logic   [0:0]   write_valid_o,

    input   logic   [0:0]   uart_i,

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
    output  logic   [12:0]  sdram_a,
    output  logic   [1:0]   sdram_dqm,

    output logic    [0:0]   refresh_o,
    
    inout           [15:0]  sdram_d
);

assign sdram_dqm = 2'b00;

localparam width_p = 8;
localparam prescale_p = 90; // Might work for 165MHz clock? Intended 11200 baud rate
// localparam burst_len_p = 8;

logic [0:0] rw_en_u, read_valid_u, write_ready_u;
logic [0:0] rw_en_mux, read_valid_mux, write_ready_mux;

logic [12:0] row_addr_u, col_addr_u;
logic [12:0] row_addr_mux, col_addr_mux;
logic [15:0] m_data_u;

logic [0:0] tx_busy_d, tx_busy_q, rx_busy_d, rx_busy_q, tx_ready_o, tx_valid_i;
logic [width_p-1:0] tx_data_i;
logic [1:0] state_d, state_q;
uart_tx #(.DATA_WIDTH(width_p))
 tx_inst(
    .clk(clk_i),
    .rst(rst_i),
    .s_axis_tdata(tx_data_i), //i
    .s_axis_tvalid(tx_valid_i), //i
    .s_axis_tready(tx_ready_o), //o
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
assign sdram_d = (state_d == 2'b10) ? (uart_i ? m_data_u : m_data_i) : 16'hzzzz;

always_ff @(posedge clk_i) begin : blockB
    if (rst_i) begin
        state_q <= 2'b00;
    end else begin
        state_q <= state_d;
    end
end

logic [$clog2(burst_len_p)+2:0] read_cnt_d, read_cnt_q;
logic [$clog2(burst_len_p)+2:0] write_cnt_d, write_cnt_q;

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        read_cnt_q <= '0;
        write_cnt_q <= '0;
    end else begin
        read_cnt_q <= read_cnt_d;
        write_cnt_q <= write_cnt_d;
    end
end

logic [width_p-1:0] rx_buff [0:(burst_len_p + 2)];
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        rw_en_u <= 1'b0;
        row_addr_u <= '0;
        col_addr_u <= '0;
    end else if (rx_valid) begin
        rw_en_u <= rx_buff[0];
        row_addr_u <= rx_buff[1];
        col_addr_u <= rx_buff[2];
    end
end

logic [width_p-1:0] read_buff [0:(burst_len_p-1)];
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
    end else if ((state_q == 0) && rx_valid && !rx_valid_q && (read_cnt_q != (burst_len_p + 3))) begin
        rx_buff[read_cnt_q] <= packet_rx;
    end
end

always_comb begin : blockA
    m_data_o = (state_d == 2'b01) ? sdram_d : 16'hzzzz;
    m_data_u = 16'hzzzz;
    tx_data_i = {width_p{1'b0}};
    tx_valid_i = 1'b0;
    
    state_d = state_q;
    read_valid_u = 1'b0;
    write_ready_u = 1'b0;
    

    read_cnt_d = read_cnt_q;
    write_cnt_d = write_cnt_q;

    case (state_q)
        2'b00 : begin
            state_d = 2'b00;
            if (!uart_i && go_i) begin
                if (!rw_en_i) state_d = 2'b01;
                else state_d = 2'b10;
            end

            if (read_cnt_q != (burst_len_p + 3) && uart_i) begin
                if (rx_valid && !rx_valid_q) begin
                    read_cnt_d = read_cnt_q + 1;
                end
            end
            else begin
                if ((read_cnt_q == (burst_len_p + 3)) && !rw_en_u) begin
                    state_d = 2'b01;
                    read_cnt_d = 0;
                    
                end else if ((read_cnt_q == (burst_len_p + 3)) && rw_en_u) begin
                    state_d = 2'b10;
                    read_cnt_d = 3;
                end
            end
        end

        2'b01 : begin //READ
            state_d = 2'b01;
            read_valid_u = 1'b1;
            if (read_valid_mux && read_ready_o && (read_cnt_q != (burst_len_p[3:0]))) begin
                read_cnt_d = read_cnt_q + 1;
            end
            else if (read_cnt_q == (burst_len_p[3:0]) && !uart_i) begin
                read_cnt_d = '0;
                state_d = 2'b00;
            end else if (read_cnt_q == (burst_len_p[3:0]) && uart_i) begin 
                read_cnt_d = '0;
                write_cnt_d = '0;
                state_d = 2'b11;
                read_valid_u = 1'b0;
            end
        end

        2'b10 : begin //WRITE
            state_d = 2'b10;
            if (write_valid_o) write_ready_u = 1'b1;
            if (read_cnt_q == (burst_len_p[3:0] + 3)) begin
                m_data_u = 16'hzzzz;
                write_ready_u = 1'b0;
                if (refresh_o) begin
                    read_cnt_d = '0;
                    state_d = 2'b00;
                end
            end else if (write_valid_o) begin
                m_data_u = rx_buff[read_cnt_q];
                if (read_cnt_q != (burst_len_p[3:0] + 3)) begin
                    read_cnt_d = read_cnt_q + 1;
                end
            end
        end

        2'b11 : begin //TX_O
            state_d = 2'b11;
            tx_valid_i = 1'b1;
            tx_data_i = read_buff[write_cnt_q - 1];
            if (tx_ready_o) begin
                write_cnt_d = write_cnt_q + 1;
            end
            if (write_cnt_q == burst_len_p + 1) begin
                state_d = 2'b00;
                read_cnt_d = '0;
                write_cnt_d = '0;
            end
        end
    endcase

end

always_comb begin
    row_addr_mux = uart_i ? row_addr_u : row_addr_i;
    col_addr_mux = uart_i ? col_addr_u : col_addr_i;

    read_valid_mux = uart_i ? read_valid_u : read_valid_i;
    write_ready_mux = uart_i ? write_ready_u : write_ready_i;

    rw_en_mux = uart_i ? rw_en_u : rw_en_i;

end

sm #(.burst_len_p(burst_len_p)) memory_controller_sm (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .go_i((read_cnt_q == (burst_len_p[3:0] + 3)) ||  go_i),
    .rw_en_i(rw_en_mux),
    .read_valid_i(read_valid_mux),
    .write_ready_i(write_ready_mux),
    .row_addr_i(row_addr_mux),
    .col_addr_i(col_addr_mux),
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
