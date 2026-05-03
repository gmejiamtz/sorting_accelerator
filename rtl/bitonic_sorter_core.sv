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
logic [addr_width_lp-1:0] w_addr_li, r_addr_li;
logic [data_width_lp-1:0] w_data_li, r_data_lo;
logic                     w_v_li, r_v_li;
logic clear_addr;

//Timeout Timer signals
logic [31:0] timer_count;
logic timer_inc, timer_reset;
localparam timeout_cycle_count = 4294967295;


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
    r_v_li = '0;
    clear_addr = '0;
    
    case (state_q)
        idle: begin
            ready_d = '1;
            array_size_d = '0;
            error_code_d = '0;
            if(packet_ready_o & packet_valid_i) begin
                if(packet_data_i == 32'h6c_6f_61_64) begin
                    state_d = size;
                end else begin
                    state_d = error;
                    error_code_d = 32'h4;
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
                error_code_d = 32'd8;
            end else if (packet_ready_o & packet_valid_i & ~size_valid_l) begin    //bad size
                state_d = error;
                error_code_d = 32'd16;
            end
        end

        load: begin
            ready_d = '1;
            timer_inc = '1;
            //if writing to last cache line move to sort state on next state
            if(w_v_li & ({14'b0,w_addr_li} == (array_size_q[31:4] - 1'b1))) begin
                state_d = sort;
                timer_reset = '1;
                clear_addr = '1;
            end else if (timer_count == timeout_cycle_count) begin //timeout
                state_d = error;
                error_code_d = 32'd8;
            end
        end

        sort:  state_d = transmit_left_bracket;

        transmit_left_bracket: begin //stay here for one cycle to send out the starting array sequence
            ready_d = '0;
            valid_d = '1;
            data_d = 32'h00_00_0a_5b; //string '\0\0\n\['
            state_d = transmit_raw_int;
        end

        transmit_raw_int: begin //stay here for one cycle to send out the starting array sequence
            ready_d = '0;
            valid_d = '1;
            data_d = 32'h00_00_0a_5b; //string '\0\0\n\['
            state_d = transmit_right_bracket;
        end

        transmit_right_bracket: begin //stay here for one cycle to send out the ending array sequence
            ready_d = '0;
            valid_d = '1;
            data_d = 32'h5d_0a_00_00; //string '\]\n\0\0'
            state_d = idle;
        end

        error: state_d = error;

        default: state_d = error;

    endcase
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
    .reset_i(!resetn_i | clear_addr),
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
    ,.reset_i(!resetn_i | clear_addr)

    // Control Signals
    ,.up_i(r_v_li)
    ,.down_i(1'b0)
    
    // Counter Output
    ,.count_o(r_addr_li)
);

bsg_counter_up_down #(
    .max_val_p(timeout_cycle_count),
    .init_val_p(0),
    .max_step_p(1)
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
    .resetn_i(resetn_i),
    .data_i(packet_data_i),
    .valid_i(packet_valid_i & (state_q == load)),
    .data_o(w_data_li),
    .valid_o(w_v_li)
);

/* Assignments */

assign data_o = data_q;
assign packet_ready_o = ready_q;
assign valid_o = valid_q;

endmodule
