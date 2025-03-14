module axil_sorter #(
    parameter int DATA_WIDTH = 32,
    parameter int DATA_ENTRIES = 8,
    parameter     AXIL_ADDR_WIDTH = 16
) (
    input   logic   [0:0]                       clk_i,
    input   logic   [0:0]                       rst_i,

    input   logic   [0:0]                       start_i,           
    output  logic   [0:0]                       read_valid_o,
    output  logic   [DATA_WIDTH-1:0]            data_o,

    output  logic   [AXIL_ADDR_WIDTH-1:0]       axil_awaddr_o,
    output  logic   [0:0]                       axil_awvalid_o,
    input   logic   [0:0]                       axil_awready_i,

    output  logic   [DATA_WIDTH-1:0]            axil_wdata_o,
    output  logic   [0:0]                       axil_wvalid_o,
    input   logic   [0:0]                       axil_wready_i,

    input   logic   [0:0]                       axil_bvalid_i,  // IDK What to do w/ this
    output  logic   [0:0]                       axil_bready_o,

    output  logic   [AXIL_ADDR_WIDTH-1:0]       axil_araddr_o,
    output  logic   [0:0]                       axil_arvalid_o,
    input   logic   [0:0]                       axil_arready_i,

    input   logic   [DATA_WIDTH-1:0]            axil_rdata_i,
    input   logic   [0:0]                       axil_rvalid_i,
    output  logic   [0:0]                       axil_rready_o


);

always_comb begin
    axil_awaddr_o = cntl_addr * 4;
    axil_awvalid_o = read_out;

    axil_wdata_o = cntl_data_i;
    axil_wvalid_o = read_out;

    axil_bready_o = 1'b1;

    axil_araddr_o = cntl_addr * 4;
    axil_arvalid_o = cntl_request;
end

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

logic [DATA_WIDTH-1:0]  read_data_mem;
logic [0:0]             request_ready;
pipelined_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_ENTRIES(DATA_ENTRIES)
)
pipelined_mem (
    .clk_i,
    .rst_ni(!rst_i),
    .request_ready_o(request_ready),
    .request_valid_i(request_mem),
    .request_write_not_read_i(cntl_rw_en),
    .request_addr_i(cntl_addr),
    .request_id_i(),
    .request_w_data_i(cntl_data_i),
    .read_ready_i(request_mem),
    .read_valid_o(axil_rready_o),
    .read_addr_o(),
    .read_id_o(),
    .read_data_o(read_data_mem)
);

// CONTROLLER
logic [$clog2(DATA_ENTRIES):0]  cntl_addr;
logic [0:0]                     cntl_rw_en;
logic [0:0]                     cntl_request;
logic [DATA_WIDTH - 1:0]        cntl_data_i;
always_comb begin
    if (rst_i) begin
        cntl_addr = 'x;
        cntl_rw_en = 1'b0;
        cntl_request = 1'b0;
        cntl_data_i = 'x;
    end else begin
        if (sort_en) begin
            cntl_addr = sort_addr;
            cntl_rw_en = sort_rw_en;
            cntl_request = sort_request;
            cntl_data_i = sort_data_i;
        end else begin
            cntl_addr = mem_addr_q;
            cntl_rw_en = rw_en;
            cntl_request = request_mem;
            cntl_data_i = axil_rdata_i;
        end
    end
end

// ALT FOR LOOP

    // CYCLE COUNT
logic [3:0] cycle_count_d, cycle_count_q;


logic [$clog2(DATA_ENTRIES):0]  for_i_addr_d, for_i_addr_q;
logic [$clog2(DATA_ENTRIES):0]  for_j_addr_d, for_j_addr_q;
logic [DATA_WIDTH - 1:0]        data_min_d,   data_min_q;
logic [DATA_WIDTH - 1:0]        data_comp_d,   data_comp_q;
logic [0:0]                     i_en, j_en;
always_comb begin
    for_i_addr_d = for_i_addr_q;
    for_j_addr_d = for_j_addr_q;

    if (for_i_addr_d != (DATA_ENTRIES) && (i_en)) begin
        if (for_j_addr_q != (DATA_ENTRIES-1) && (j_en)) begin
            if (for_j_addr_q < for_i_addr_q) begin // New BS Line
                for_j_addr_d = for_i_addr_q + 1;
            end else begin
                for_j_addr_d = for_j_addr_q + 1;
            end
        end else begin
            if (for_i_addr_q == (DATA_ENTRIES - 1))
                for_i_addr_d = '0;
            else
                for_i_addr_d = for_i_addr_q + 1;
            if ((for_i_addr_q + 2) == (DATA_ENTRIES)) begin
                for_j_addr_d = for_i_addr_q + 1;
            end else if ((for_i_addr_q + 1) == (DATA_ENTRIES)) begin
                for_j_addr_d = '0;
            end else begin
                for_j_addr_d = for_i_addr_q + 2;
            end
        end
    end else begin
        for_i_addr_d = for_i_addr_q;
        for_j_addr_d = for_j_addr_q;
    end
end

logic [1:0] read_count_d, read_count_q;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        for_i_addr_q <=  '0;
        for_j_addr_q <=  '0;
        cycle_count_q <= 1'b0;
        data_min_q <= '0;
        data_comp_q <= '0;
        read_count_q <= 2'b00;
        read_valid_o <= 1'b0;
    end else begin
        for_i_addr_q <= for_i_addr_d;
        for_j_addr_q <= for_j_addr_d;
        cycle_count_q <= cycle_count_d;
        data_min_q <= data_min_d;
        data_comp_q <= data_comp_d;
        read_count_q <= read_count_d;
        read_valid_o <= read_out;
    end
end

// SORTER
logic [0:0]                     sort_done;
int                             min;
logic [DATA_WIDTH - 1:0]        sort_data_i;
logic [$clog2(DATA_ENTRIES):0]  sort_addr;
logic [0:0]                     sort_rw_en;
logic [0:0]                     sort_request;

logic [1:0]                     testflag;

always_comb begin
    cycle_count_d = cycle_count_q;
    data_min_d = data_min_q;
    data_comp_d = data_comp_q;
    testflag = 2'b00;

    if (sort_en && for_i_addr_q != (DATA_ENTRIES - 1)) begin
        if (for_j_addr_q == (DATA_ENTRIES - 1)) begin
            i_en = 1'b1;
            j_en = 1'b1;
        end else begin
            i_en = 1'b0;
            j_en = 1'b0;
        end

        sort_request = (axil_arready_i || axil_rvalid_i); // Go if we're ready to read or have a valid read
        sort_rw_en = 1'b0;
        min = for_i_addr_q;
        if (cycle_count_q <= 3) begin                   // Begin Reading mem[min]
            if (cycle_count_q >= 1) begin
                i_en = 1'b0;
                j_en = 1'b0;
            end else begin
                i_en = 1'b1;
                j_en = 1'b1;
            end
            sort_data_i = '0; 

            data_min_d = read_data_mem;

            if (cycle_count_q == 3) begin
                sort_addr = for_j_addr_q;
            end else begin
                sort_addr = min[7:0];
            end
            data_comp_d = '0;
            cycle_count_d = cycle_count_q + 1;
        end else begin                                  // Begin Reading mem[j]
            i_en = 1'b0;
            j_en = 1'b0;
            sort_data_i = '0;
            sort_addr = for_j_addr_q;
            data_comp_d = read_data_mem;
            data_min_d = data_min_q;
            if (cycle_count_q >= 6) begin               // Test for Swapping
                if (data_comp_q < data_min_q) begin     // Swap
                    min = for_i_addr_q;
                    if (cycle_count_q < 8) begin    
                        testflag = 2'b01;
                        sort_data_i = data_comp_q;
                        sort_rw_en = 1'b1;
                        sort_request = (axil_awready_i && axil_wready_i);
                        sort_addr = min;
                        if (axil_awready_i && axil_wready_i) cycle_count_d = cycle_count_q + 1;
                        else cycle_count_d = cycle_count_q;
                    end else if (cycle_count_q < 10) begin // This part keeps failing :/
                        testflag = 2'b10;
                        sort_data_i = data_min_q;
                        sort_rw_en = 1'b1;
                        sort_request = axil_awready_i && axil_wready_i;
                        sort_addr = for_j_addr_q;
                        if (axil_awready_i && axil_wready_i) cycle_count_d = cycle_count_q + 1;
                        else cycle_count_d = cycle_count_q;
                    end else begin
                        testflag = 2'b00;
                        sort_data_i = '0;
                        sort_rw_en = 1'b0;
                        sort_request = 1'b0;
                        sort_addr = '0;
                        cycle_count_d = 3'd0;           // Reset the Cycle
                    end
                    testflag = 2'b01;
                end else begin                          // Don't Swap
                    if (cycle_count_q < 10) begin
                        cycle_count_d = 3'd0;
                    end else begin
                        cycle_count_d = cycle_count_q + 1;
                    end
                    testflag = 2'b00;
                end
                // cycle_count_d = 3'd0;                   
            end else begin                              // Wait until Data Comp is Valid
                cycle_count_d = cycle_count_q + 1;
                testflag = 2'b00;
            end
        end
    end else begin
        i_en = 1'b0;
        j_en = 1'b0;
        min = 0;
        sort_data_i = '0;
        data_min_d = '0;
        data_comp_d = '0;
        // data_intr = 'x;
        sort_addr = '0;
        sort_rw_en = 1'b0;
        sort_request = 1'b0;
    end
end

// DATA_OUT
logic [0:0] read_out;
always_ff @(posedge clk_i) begin // Data Going Out
    if (rst_i) begin
        data_o <= 'x;
    end else begin
        if (read_out) begin
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
    read_count_d = read_count_q;
    del_rst = 1'b0;
    rw_en = 1'b0;
    request_mem = 1'b0;
    sort_en = 1'b0;
    read_out = 1'b0;
    case(state_q)
        2'b00 : begin
            if (!(axil_arready_i)) begin 
                state_d = 2'b00;
            end else if ((axil_arready_i)) begin       // Ready to Read from RAM
                state_d = 2'b01;
                mem_addr_d = {DATA_ENTRIES{1'b0}};
                rw_en = 1'b1;
            end
        end
        2'b01 : begin
            if (mem_addr_q != (DATA_ENTRIES)) begin // Mem is not yet full
                rw_en = 1'b1;
                request_mem = 1'b1;
                    if (axil_rvalid_i) mem_addr_d = mem_addr_q + 1;
                    else mem_addr_d = mem_addr_q;
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
            // if (!sort_done) begin
            //     sort_en = 1'b1;
            //     state_d = 2'b10;
            // end else begin
            //     sort_en = 1'b0;
            //     state_d = 2'b11;
            // end
            if (for_i_addr_q == (DATA_ENTRIES - 1)) begin
                request_mem = 1'b0;
                sort_en = 1'b0;
                state_d = 2'b11;
            end else begin
                request_mem = 1'b1;
                sort_en = 1'b1;
                state_d = 2'b10;
            end
        end
        2'b11 : begin
            if (read_count_q < 2) begin
                read_count_d = read_count_q + 1;
                read_out = 1'b0;
            end else begin
                read_out = 1'b1;
            end
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
