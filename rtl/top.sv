module top(
    input clk_i,
    input reset_i,
    input a_i,
    input b_i,
    input c_i,
    output logic d_o
);

always_ff @(posedge clk_i) begin : register_a_xor_b
    if(reset_i) begin
        d_o <= '0;
    end else if (c_i) begin
        d_o <= a_i ^ b_i;
    end
end

endmodule
