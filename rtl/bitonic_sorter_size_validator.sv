module bitonic_sorter_size_validator (
    input  logic [31:0] val_i,     // Range 0 to 2^16
    output logic       is_valid_o
);

    logic is_pwr2;
    logic is_gte_16;

    assign is_pwr2 = (val_i != 32'd0) & ((val_i & (val_i - 32'd1)) == 32'd0);

    assign is_gte_16 = (val_i >= 32'd16);

    assign is_valid_o = is_pwr2 & is_gte_16;

endmodule
