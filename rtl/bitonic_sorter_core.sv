module bitonic_sorter_core
    import config_pkg::*;
(
    input clk_i,
    input resetn_i,
    input packet_valid_i,
    input descend_i,
    input [31:0] packet_data_i,
    output packet_ready_o,
    output logic valid_o,
    output logic [31:0] data_o,
    input logic ready_i
);

// BRAM parameters - 512 bit wide bus for 16 int access per cycle
localparam int data_width_lp = 512;
localparam int memory_size_lp = 4096;
localparam int addr_width_lp = 13;

/* State Logic Busses */
state_t state_q, state_d;
logic [31:0] data_q, data_d;
logic valid_q, valid_d;
logic ready_q, ready_d;

/* Intermiate Logic Busses */
logic [31:0] error_code_q, error_code_d;
logic [31:0] array_size_q, array_size_d;
logic size_valid_l;

//BRAM signals
//Port A
logic [addr_width_lp-1:0] w_addr_li, r_addr_li;
logic [data_width_lp-1:0] w_data_li, r_data_lo;
logic                     w_v_li, r_v_li;   //BRAM read enable and write enable
logic                     w_v_li_q, r_v_li_q;   //BRAM read enable and write enable
logic                     w_v_li_d, r_v_li_d;   //BRAM read enable and write enable
logic clear_w_addr, clear_r_addr;

logic descend_l;

//Timeout Timer signals
logic [31:0] timer_count;
logic timer_inc, timer_reset;
//max int
localparam timeout_cycle_count = 100;
//localparam timeout_cycle_count = 4294967295;

//PISO Signals
logic [31:0] piso_data_out;
logic piso_valid;
logic piso_start_d, piso_start_q;
logic piso_empty;

//SIPO Signals
logic sipo_full, sipo_empty;
logic [511:0] sipo_data_o;

//sorter signals
logic [511:0] sorter_data_o;
logic sorter_start;
logic sorter_done_d, sorter_done_q;

//signal that the sorter is done done
logic end_of_sort_d, end_of_sort_q;

always_ff @(posedge clk_i) begin : state_ff
    if(!resetn_i) begin
        state_q <= idle;
    end else begin
        state_q <= state_d;
    end
end

always_ff @(posedge clk_i) begin : interface_ff
    if(!resetn_i) begin
        data_q <= '0;
        ready_q <= '0;
        valid_q <= '0;
    end else begin
        data_q <= data_d;
        ready_q <= ready_d;
        valid_q <= valid_d;
    end
end

always_ff @(posedge clk_i) begin : error_code_ff
    if(!resetn_i) begin
        error_code_q <= '0;
    end else begin
        error_code_q <= error_code_d;
    end
end

always_ff @(posedge clk_i) begin : array_size_ff
    if(!resetn_i) begin
        array_size_q <= '0;
    end else begin
        array_size_q <= array_size_d;
    end
end

always_ff @(posedge clk_i) begin : bram_read_en
    if(!resetn_i) begin
        r_v_li_q <= '0;
    end else begin
        r_v_li_q <= r_v_li_d;
    end
end

always_ff @(posedge clk_i) begin : bram_write_en
    if(!resetn_i) begin
        w_v_li_q <= '0;
    end else begin
        w_v_li_q <= w_v_li_d;
    end
end

always_ff @(posedge clk_i) begin : descend_ff
    if(!resetn_i) begin
        descend_l <= '0;
    end else if (state_q == size) begin
        descend_l <= descend_i;
    end
end

always_ff @(posedge clk_i) begin : piso_start
    if(!resetn_i) begin
        piso_start_q <= '0;
    end else begin
        piso_start_q <= piso_start_d;
    end
end

always_ff @(posedge clk_i) begin : sorter_done
    if(!resetn_i) begin
        sorter_done_q <= '0;
    end else begin
        sorter_done_q <= sorter_done_d;
    end
end

always_ff @(posedge clk_i) begin : end_of_sort
    if(!resetn_i) begin
        end_of_sort_q <= '0;
    end else begin
        end_of_sort_q <= end_of_sort_d;
    end
end

always_comb begin : next_state_logic
    //default to current state and 0 out data, valid, ready
    state_d = state_q;
    data_d = '0;
    valid_d = '0;
    ready_d = '0;
    timer_inc = '0;
    timer_reset = 0;
    //defaults of intermiate logic busses
    error_code_d = error_code_q;
    array_size_d = array_size_q;
    r_v_li_d = 0;
    w_v_li_d = 0;
    clear_w_addr = '0;
    clear_r_addr = '0;
    sorter_start = 0;
    piso_start_d = 0;
    end_of_sort_d = end_of_sort_q;
    case (state_q)
        idle: begin
            ready_d = '1;
            array_size_d = '0;
            error_code_d = '0;
            clear_w_addr = 1;
            clear_r_addr = 1;
            timer_reset = 1;
            end_of_sort_d = 0;
            if(packet_ready_o & packet_valid_i) begin
                if(packet_data_i == header_string) begin
                    state_d = size;
                    timer_reset = 1;
                end else begin
                    state_d = error;
                    error_code_d = error_code_bad_header;
                end
            end
        end

        size: begin
            ready_d = '1;
            timer_inc = '1;
            //if size valid
            if(packet_ready_o & packet_valid_i & size_valid_l) begin
                array_size_d = packet_data_i;
                state_d = load;
                timer_reset = '1;
            end else if (timer_count == timeout_cycle_count) begin  //timeout
                state_d = error;
                error_code_d = error_code_timeout;
            end else if (packet_ready_o & packet_valid_i & ~size_valid_l) begin    //bad size
                state_d = error;
                error_code_d = error_code_bad_size;
            end
        end

        load: begin
            w_v_li_d = sipo_full;
            //if wrote to last cache line move to read_bram
            if({15'b0,w_addr_li} == array_size_q[31:4]) begin
                state_d = bram_read;
                timer_reset = '1;
                clear_w_addr = '1;
                clear_r_addr = 1;
            end else if (timer_count == timeout_cycle_count) begin //timeout
                state_d = error;
                error_code_d = error_code_timeout;
            end else if (sipo_full) begin
                timer_inc = '1;
                ready_d = 0;
            end else begin
                timer_inc = '1;
                ready_d = 1;
            end
        end

        //TBA soon - need to understand how to reuse sorter 16 core for all other 2^n lengths
        sort: begin
            //if the array size is good but not 16 just echo out the array
            w_v_li_d = 0;
            sorter_start = 0;
            if(array_size_q != 32'd16) begin
                state_d = transmit_left_bracket;
            end else if(sorter_done_q & {15'b0,r_addr_li} == array_size_q[31:4]) begin
                state_d = write_back;
                w_v_li_d = 1;
                end_of_sort_d = 1;
            end else if (sorter_done_q & {15'b0,r_addr_li} != array_size_q[31:4]) begin
                state_d = write_back;
                w_v_li_d = 1;
            end
        end

        write_back: begin
            w_v_li_d = 0;
            //if done then restart reads
            if(end_of_sort_q) begin
                clear_r_addr = 1;
                clear_w_addr = 1;
                state_d = transmit_left_bracket;
            end else begin
                state_d = bram_read;
            end
        end

        bram_read: begin
            ready_d = '0;
            valid_d = '0;
            data_d = '0;
            timer_inc = 1;
            r_v_li_d = 1;
            if(timer_count == timeout_cycle_count) begin
                state_d = error;
                error_code_d = error_code_timeout;
                timer_reset = 1;
            end else begin
                state_d = bram_data_valid;  //data will be valid for a cycle
                timer_reset = 1;
            end
        end

        bram_data_valid: begin
            ready_d = '0;
            valid_d = '0;
            data_d = '0;
            timer_inc = 1;
            r_v_li_d = 0;
            if(timer_count == timeout_cycle_count) begin
                state_d = error;
                error_code_d = error_code_timeout;
                timer_reset = 1;
            //if we just read the first line we go to sort
            end else if ({15'b0, r_addr_li} == 32'd0 & !end_of_sort_q) begin
                state_d = sort;
                sorter_start = 1; 
            end else begin
                state_d = transmit_raw_int;  //data is to be sent by the PISO
                piso_start_d = 1;             //piso should start
                timer_reset = 1;
            end
        end

        transmit_left_bracket: begin //stay here for one cycle to send out the starting array sequence
            ready_d = '0;
            valid_d = '1;
            data_d = left_bracket_string; 
            if(timer_count == timeout_cycle_count) begin
                state_d = error;
                error_code_d = error_code_timeout;
                timer_reset = 1;
                valid_d = 0;
            end else if (ready_i & valid_o) begin
                //read the bram
                timer_inc = '1;
                //r_v_li_d = '1;
                valid_d = 0;
                state_d = bram_read;
                timer_reset = 1;
            end
        end

        transmit_raw_int: begin
            ready_d = '0;
            valid_d = piso_valid;
            data_d = piso_data_out;
            timer_inc = '1;
            r_v_li_d = '0;
            if(timer_count == timeout_cycle_count) begin
                state_d = error;
                error_code_d = error_code_timeout;
            end else if (ready_i & piso_valid) begin
                //always do to comma
                state_d = transmit_comma;
                timer_reset = 1;
            end
        end

        transmit_comma: begin
            ready_d = 0;
            valid_d = 1;
            timer_inc = '1;
            if(timer_count == timeout_cycle_count) begin
                state_d = error;
                error_code_d = error_code_timeout;
            end else if(piso_empty & ready_i & valid_o) begin //if PISO is empty refill the cache line by reading from BRAMn
                //if you cant read anymore just do the ending string and go to idle
                if({15'b0,r_addr_li} == (array_size_q[31:4])) begin
                    r_v_li_d = 0;
                    clear_r_addr = 1;
                    data_d = right_bracket_string;
                    state_d = idle;
                end else begin  //go back to read bram
                    data_d = comma_string;
                    r_v_li_d = 1;
                    state_d = bram_read;
                end
            end else if (!piso_empty & ready_i & valid_o) begin //if no timeout and not empty then just send comma and go back to sending ints
                    r_v_li_d = '0;
                    data_d = comma_string;
                    state_d = transmit_raw_int;
            end
        end

        error: begin
            ready_d = 0;
            valid_d = 1;
            data_d = error_code_q;
            //if can send an error code then reset state to idle and reset error code register
            if(ready_i & valid_o) begin
                state_d = idle;
                data_d = '0;
                valid_d = '0;
                error_code_d = '0;
            end
        end

        //if here set error code to all ones and go to error and back to idle
        default: begin
            state_d = error;
            error_code_d = '1;
        end

    endcase
    if(sipo_full) begin
        w_data_li = sipo_data_o;
    end else begin
        w_data_li = sorter_data_o;
    end
end

/* Hardware */

bitonic_sorter_size_validator size_validator_inst (
    .val_i(packet_data_i),
    .is_valid_o(size_valid_l)
);

bsg_counter_up_down #(
    .max_val_p(4096),
    .init_val_p(0),
    .max_step_p(1)
) write_addr_counter (
    .clk_i(clk_i),
    .reset_i(!resetn_i | clear_w_addr),
    .up_i(w_v_li),
    .down_i(1'b0),
    .count_o(w_addr_li)
);

bsg_counter_up_down #(
    .max_val_p(4096),
    .init_val_p(0),
    .max_step_p(1)
) read_addr_counter (
    .clk_i(clk_i)
    ,.reset_i(!resetn_i | clear_r_addr)

    // Control Signals
    ,.up_i(r_v_li)
    ,.down_i(1'b0)
    
    // Counter Output
    ,.count_o(r_addr_li)
);

bsg_counter_up_down #(
    .max_val_p(32'h7fff_ffff),
    .init_val_p(32'd0),
    .max_step_p(32'd1)
) timeout_counter (
    .clk_i(clk_i),
    .reset_i(!resetn_i | timer_reset),
    .up_i(timer_inc),
    .down_i(1'b0),
    .count_o(timer_count)
);

bsg_mem_1r1w_sync #(
    .width_p(data_width_lp),
    .els_p (memory_size_lp)
) sorter_bram (
    .clk_i  (clk_i),
    .reset_i(!resetn_i),

    .w_v_i   (w_v_li),       // Pulse when a 512-bit vector is ready
    .w_addr_i(w_addr_li),     // 0 to 4095
    .w_data_i(w_data_li),     // Concatenated 16 integers

    .r_v_i   (r_v_li),       // Read enable
    .r_addr_i(r_addr_li),     // 0 to 4095
    .r_data_o(r_data_lo)     // Valid 1 cycle AFTER r_v_li is high
);


//Creates the w_data for the bram
sipo_32_to_512 sipo_inst (
    .clk_i(clk_i),
    .resetn_i(resetn_i & !clear_w_addr),
    .data_i(packet_data_i),
    .valid_i(packet_valid_i & (state_q == load)),
    .ready_o(sipo_empty),
    .data_o(sipo_data_o),
    .valid_o(sipo_full),
    .ready_i(1'b1)  //bram always ready
);

//Creates the raw ints from BRAM cache lines to send out to UART
piso_512_to_32 piso_inst (
    .clk_i(clk_i),
    .resetn_i(resetn_i & !clear_r_addr),
    .data_i(r_data_lo),
    .valid_i(piso_start_q),
    .ready_o(piso_empty),
    .data_o(piso_data_out),
    .valid_o(piso_valid),
    .ready_i(ready_i & (state_q == transmit_raw_int))
);

//main sorting core
bitonic_sorter_16 sorting_core (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(descend_i),
    .valid_i(sorter_start),
    .val_1_i(r_data_lo[31:0]),
    .val_2_i(r_data_lo[63:32]),
    .val_3_i(r_data_lo[95:64]),
    .val_4_i(r_data_lo[127:96]),
    .val_5_i(r_data_lo[159:128]),
    .val_6_i(r_data_lo[191:160]),
    .val_7_i(r_data_lo[223:192]),
    .val_8_i(r_data_lo[255:224]),
    .val_9_i(r_data_lo[287:256]),
    .val_10_i(r_data_lo[319:288]),
    .val_11_i(r_data_lo[351:320]),
    .val_12_i(r_data_lo[383:352]),
    .val_13_i(r_data_lo[415:384]),
    .val_14_i(r_data_lo[447:416]),
    .val_15_i(r_data_lo[479:448]),
    .val_16_i(r_data_lo[511:480]),
    //Outputs
    .valid_o(sorter_done_d),
    .descend_o(),   //unused
    .val_1_o(sorter_data_o[31:0]),
    .val_2_o(sorter_data_o[63:32]),
    .val_3_o(sorter_data_o[95:64]),
    .val_4_o(sorter_data_o[127:96]),
    .val_5_o(sorter_data_o[159:128]),
    .val_6_o(sorter_data_o[191:160]),
    .val_7_o(sorter_data_o[223:192]),
    .val_8_o(sorter_data_o[255:224]),
    .val_9_o(sorter_data_o[287:256]),
    .val_10_o(sorter_data_o[319:288]),
    .val_11_o(sorter_data_o[351:320]),
    .val_12_o(sorter_data_o[383:352]),
    .val_13_o(sorter_data_o[415:384]),
    .val_14_o(sorter_data_o[447:416]),
    .val_15_o(sorter_data_o[479:448]),
    .val_16_o(sorter_data_o[511:480])
);

/* Assignments */

assign data_o = data_q;
assign packet_ready_o = ready_q;
assign valid_o = valid_q;
assign w_v_li = w_v_li_d;
assign r_v_li = r_v_li_q;

endmodule
