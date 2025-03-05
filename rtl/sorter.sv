module sorter #(
    parameter int DATA_WIDTH = 8,
    parameter int DATA_ENTRIES = 8
) (
    input   logic   [0:0]              clk_i,
    input   logic   [0:0]              rst_i,

    input   logic   [0:0]              write_valid_i,
    input   logic   [0:0]              start_i,
    input   logic   [DATA_WIDTH-1:0]   data_i,
    output  logic   [0:0]              read_valid_o,
    output  logic   [DATA_WIDTH-1:0]   data_o
);


logic [DATA_WIDTH-1:0]  read_data_mem;
pipelined_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_ENTRIES(DATA_ENTRIES)
)
pipelined_mem (.clk_i,
    .rst_ni(!rst_i),
    .request_ready_o(),
    .request_valid_i(request_mem | write_valid_i),
    .request_write_not_read_i(rw_en),
    .request_addr_i(mem_addr_q),
    .request_id_i(),
    .request_w_data_i(data_i),
    .read_ready_i(request_mem),
    .read_valid_o(read_valid_o),
    .read_addr_o(),
    .read_id_o(),
    .read_data_o(read_data_mem)
);

logic [$clog2(DATA_ENTRIES):0] mem_addr_d, mem_addr_q;

logic [1:0] state_d, state_q;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= 2'b00;
        mem_addr_q <= '0;
    end else begin
        state_q <= state_d;
        mem_addr_q <= mem_addr_d;
    end
end

logic [0:0] del_rst;
logic [1:0] cnt_d, cnt_q;
always_ff @(posedge clk_i) begin
    if (rst_i | del_rst) begin
        cnt_q <= 2'b00;
    end else begin
        cnt_q <= cnt_d;
    end
end

// SORTER
always_ff @(posedge clk_i) begin // Data Going Out
    if (rst_i) begin
        data_o <= 'x;
    end else begin
        if (read_valid_o) begin
            data_o <= read_data_mem;
        end else begin
            data_o <= 'x;
        end
    end
end

logic [0:0] request_mem, rw_en, sort_en;
always_comb begin
    state_d = state_q;
    mem_addr_d = mem_addr_q;
    cnt_d = cnt_q;
    del_rst = 1'b0;
    rw_en = 1'b0;
    request_mem = 1'b0;
    sort_en = 1'b0;
    case(state_q)
        2'b00 : begin
            if (!start_i) begin 
                state_d = 2'b00;
            end else if (start_i) begin
                state_d = 2'b01;
                mem_addr_d = {DATA_ENTRIES{1'b0}};
                rw_en = 1'b1;
            end
        end
        2'b01 : begin
            if (mem_addr_q != (DATA_ENTRIES) && write_valid_i) begin // Mem is not yet full
                rw_en = 1'b1;
                request_mem = 1'b1;
                mem_addr_d = mem_addr_q + 1;
                state_d = 2'b01;
            end else if (mem_addr_q == (DATA_ENTRIES)) begin // Mem is full, move on
                rw_en = 1'b1;
                request_mem = 1'b0;
                mem_addr_d = mem_addr_q - 1;
                state_d = 2'b10;
            end else begin
                state_d = 2'b01;
            end
        end
        2'b10 : begin
            state_d = 2'b11; // Immediate Transition for now
        end
        2'b11 : begin
            if ((mem_addr_q != 0)) begin
                rw_en = 1'b0;
                request_mem = 1'b1;
                mem_addr_d = mem_addr_q - 1;
                state_d = 2'b11;
            end else if (mem_addr_q == 0 && (cnt_q == 0)) begin
                cnt_d = cnt_q + 1;
                rw_en = 1'b0;
                request_mem = 1'b1;
                state_d = 2'b11;
            end else if (mem_addr_q == 0 && (cnt_q != 0)) begin
                rw_en = 1'b0;
                request_mem = 1'b1;
                mem_addr_d = '0;
                state_d = 2'b11;
                del_rst = 1'b1;
            end
        end
        default: begin
            state_d = 2'b00;
            mem_addr_d = '0;
            request_mem = 1'b0;
        end
    endcase
end

endmodule
