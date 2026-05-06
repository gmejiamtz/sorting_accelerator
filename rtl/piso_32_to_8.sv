module piso_32_to_8 (
    input clk_i,
    input resetn_i,
    
    input [31:0] data_i,
    input         valid_i,     // Pulse to capture BRAM output
    output        ready_o,    // High when 16 words have been sent
    
    output [7:0] data_o,
    output        valid_o,
    input         ready_i
);

typedef enum logic [0:0] { 
    idle,
    loaded
} state_t;

state_t state_d, state_q;
logic ready_d, ready_q;
logic valid_d, valid_q;
logic [7:0] data_d, data_q;
logic [31:0] cache_line_d, cache_line_q;
logic [1:0] shift_count;
logic reset_counter;
logic inc_counter;

always_ff @(posedge clk_i) begin : state_ff
    if(!resetn_i) begin
        state_q <= idle;
    end else begin
        state_q <= state_d;
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

always_ff @(posedge clk_i) begin : data_ff
    if(!resetn_i) begin
        data_q <= '0;
    end else begin
        data_q <= data_d;
    end
end

always_ff @(posedge clk_i) begin : cache_line_ff
    if(!resetn_i) begin
        cache_line_q <= '0;
    end else begin
        cache_line_q <= cache_line_d;
    end
end

always_comb begin
    state_d = state_q;
    ready_d = ready_q;
    valid_d = valid_q;
    data_d = data_q;
    cache_line_d = cache_line_q;
    reset_counter = 0;
    inc_counter = 0;
    case (state_q)
        idle: begin
            reset_counter = 1;
            data_d = '0;
            cache_line_d = '0;
            ready_d = '1;
            valid_d = '0;
            //store the cache line
            if(valid_i & ready_o) begin
                cache_line_d = data_i;
                reset_counter = 0;
                ready_d = 0;
                state_d = loaded;
            end
        end

        loaded: begin
            reset_counter = 0;
            ready_d = 0;
            valid_d = 1;
            data_d = cache_line_q[31:24];
            if(ready_i & valid_o) begin
                inc_counter = 1;
                cache_line_d = {cache_line_q[23:0], 8'h0};
                if(shift_count == 2'd3) begin
                    state_d = idle;
                    valid_d = 0;
                    ready_d = 1;
                    reset_counter = 1;
                end
            end
        end
    endcase
end

bsg_counter_up_down #(
    .max_val_p(4),
    .init_val_p(0),
    .max_step_p(1)
) piso_counter (
    .clk_i(clk_i),
    .reset_i(!resetn_i | reset_counter),
    .up_i(inc_counter),
    .down_i(1'b0),
    .count_o(shift_count)
);

assign ready_o = ready_q;
assign valid_o = valid_q;
assign data_o = data_q;

endmodule
