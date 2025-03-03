module sorter #(
    parameter int DATA_WIDTH = 8,
    parameter int DATA_ENTRIES = 8
) (
    input   logic   [0:0]              clk_i,
    input   logic   [0:0]              rst_i,

    input   logic   [0:0]              write_valid_i,
    input   logic   [0:0]              start_i,
    input   logic   [DATA_WIDTH-1:0]   data_i,
    output  logic   [0:0]              receive_ready_o,
    output  logic   [0:0]              read_valid_o,
    output  logic   [DATA_WIDTH-1:0]   data_o
);

reg [DATA_WIDTH-1:0] mem [DATA_ENTRIES-1:0];
logic [$clog2(DATA_ENTRIES)-1:0] mem_addr_d, mem_addr_q;

logic [1:0] state_d, state_q;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= 2'b00;
        mem_addr_q <= '0;
    end else begin
        state_q <= state_d;
        mem_addr_q <= mem_addr_d;
        mem <= mem;
    end
end


// SORTER
logic [DATA_WIDTH-1:0]           temp_l;
logic [$clog2(DATA_ENTRIES)-1:0] min_l;
logic [0:0]                      sort_f, sort_done_f;
always_ff @(posedge clk_i) begin
    min_l <= '0;
    temp_l <= {DATA_WIDTH{1'b0}};
    if (rst_i) begin
        sort_done_f <= 1'b0;
        for (int i = 0; i < DATA_ENTRIES; i++) begin
            mem[i] <= 'x; 
        end
    end else begin
        sort_done_f <= 1'b0;
        if (mem_i_f) begin
            mem[mem_addr_q] <= data_i;
        end else if (sort_f) begin
            foreach (mem[i]) begin
                min_l <= i;
                for (int j = 1; j < DATA_ENTRIES; j++) begin
                    if (mem[j] < mem[min_l]) begin
                        min_l <= j;
                    end
                end
                temp_l <= mem[i];
                mem[i] <= mem[min_l];
                mem[min_l] <= temp_l;
            end
            sort_done_f <= 1'b1;
        end else begin
            mem <= mem;
        end
    end
end

always_ff @(posedge clk_i) begin // Data Going Out
    if (rst_i) begin
        data_o <= 'x;
    end else begin
        if (data_o_f) begin
            data_o <= mem[mem_addr_q];
        end else begin
            data_o <= 'x;
        end
    end
end



logic [0:0] mem_i_f, data_o_f;
always_comb begin
    state_d = state_q;
    mem_addr_d = mem_addr_q;
    receive_ready_o = 1'b1;
    read_valid_o = 1'b0;
    sort_f = 1'b0;
    data_o_f = 1'b0;
    mem_i_f = 1'b0;

    case(state_q)
        2'b00 : begin
            if (!start_i) begin 
                state_d = 2'b00;
            end else if (start_i) begin
                state_d = 2'b01;
                mem_addr_d = {DATA_ENTRIES{1'b0}};
            end
        end
        2'b01 : begin
            if (mem_addr_q != $clog2(DATA_ENTRIES) && write_valid_i) begin // Mem is not yet full
                mem_i_f = 1'b1;
                mem_addr_d = mem_addr_q + 1;
                state_d = 2'b01;
            end else if (mem_addr_q == $clog2(DATA_ENTRIES)) begin // Mem is full, move on
                mem_i_f = 1'b0;
                receive_ready_o = 1'b0;
                state_d = 2'b10;
            end else begin
                state_d = 2'b01;
            end
        end
        2'b10 : begin
            receive_ready_o = 1'b0;
            sort_f = 1'b1;
            if (sort_done_f) begin
                read_valid_o = 1'b1;
                state_d = 2'b11;
            end else begin
                state_d = 2'b10;
            end
        end
        2'b11 : begin
            receive_ready_o = 1'b0;
            read_valid_o = 1'b1;
            data_o_f = 1'b1;
            if (mem_addr_q != '0) begin
                mem_addr_d = mem_addr_q - 1;
                state_d = 2'b11;
            end else begin
                mem_addr_d = '0;
                state_d = 2'b00;
            end
        end
    endcase
end

endmodule
