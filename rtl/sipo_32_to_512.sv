module sipo_32_to_512 (
    input clk_i,
    input resetn_i,
    input [31:0] data_i,
    input valid_i,
    output ready_o,
    output [511:0] data_o,
    output valid_o,
    input ready_i
);

typedef enum logic [1:0] { 
    empty,
    filling,
    full
} state_t;

state_t state_d, state_q;
logic valid_d, valid_q;
logic ready_d, ready_q;
logic [4:0] shift_count;
logic [511:0] data_d, data_q;
logic shift_inc, shift_reset;

always_ff @(posedge clk_i) begin : state_ff
    if(!resetn_i) begin
        state_q <= empty;
    end else begin
        state_q <= state_d;
    end
end

always_ff @(posedge clk_i) begin : data_ff
    if(!resetn_i) begin
        data_q <= '0;
    end else begin
        data_q <= data_d;
    end
end

always_ff @(posedge clk_i) begin : valid_ff
    if(!resetn_i) begin
        valid_q <= '0;
    end else begin
        valid_q <= valid_d;
    end
end

always_ff @(posedge clk_i) begin : ready_ff
    if(!resetn_i) begin
        ready_q <= '0;
    end else begin
        ready_q <= ready_d;
    end
end

always_comb begin : data_comb
    state_d = state_q;
    valid_d = 0;
    ready_d = 0;
    data_d = data_q;
    shift_inc = 0;
    shift_reset = 0;
    case(state_q)
        empty: begin
            valid_d = 0;
            ready_d = 1;
            data_d = '0;
            shift_inc = 0;
            shift_reset = 0;
            if(ready_o & valid_i) begin
                data_d = {data_q[479:0], data_i};
                state_d = filling;
                shift_inc = 1;
            end
        end

        filling: begin
            valid_d = 0;
            ready_d = 1;
            data_d = data_q;
            shift_inc = 0;
            shift_reset = 0;
            if(ready_o & valid_i) begin
                data_d = {data_q[479:0], data_i};
                shift_inc = 1;
                if(shift_count == 15'd15) begin
                    state_d = full;
                    valid_d = 1;
                    ready_d = 0;
                    shift_reset = 1;
                end else begin
                    state_d = filling;
                end
            end
        end

        full: begin
           valid_d = 0; 
            if(ready_i) begin
                // The BRAM has consumed the data on this clock edge
                ready_d = 1; 
                shift_reset = 1;
                if (valid_i) begin
                    // Bypassing directly to capture the 17th/33rd element
                    data_d = {480'b0, data_i};
                    shift_inc = 1;
                    shift_reset = 0; // Don't reset if we are actively incrementing
                    state_d = filling;
                end else begin
                    data_d = '0;
                    state_d = empty;
                end
            end else begin
                valid_d = 1;
                ready_d = 0;
            end
        end
        default: state_d = empty;
    endcase
end

bsg_counter_up_down #(
    .max_val_p(16),
    .init_val_p(0),
    .max_step_p(1)
) sipo_counter (
    .clk_i(clk_i),
    .reset_i(!resetn_i | shift_reset),
    .up_i(shift_inc),
    .down_i(1'b0),
    .count_o(shift_count)
);

assign valid_o = valid_q;
assign ready_o = ready_q;
assign data_o = data_q;

endmodule
