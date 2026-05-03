module sipo_32_to_512 (
    input clk_i,
    input resetn_i,
    input [31:0] data_i,
    input valid_i,
    output [511:0] data_o,
    output valid_o
);

logic [4:0] shift_count;
logic [511:0] data_d, data_q;

always_ff @(posedge clk_i) begin : data_ff
    if(!resetn_i) begin
        data_q <= '0;
    end else begin
        data_q <= data_d;
    end
end

always_comb begin : data_comb
    if(valid_i) begin
        data_d = {data_q[479:0], data_i};
    end else begin
        data_d = data_q;
    end
end

bsg_counter_up_down #(
    .max_val_p(16),
    .init_val_p(0),
    .max_step_p(1)
) sipo_counter (
    .clk_i(clk_i),
    .reset_i(!resetn_i | valid_o),
    .up_i(valid_i),
    .down_i(1'b0),
    .count_o(shift_count)
);

assign valid_o = valid_i & (shift_count == 5'd16);
assign data_o = data_q;

endmodule
