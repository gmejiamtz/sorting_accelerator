module bitonic_sorter_merger_4_elem(
    input clk_i,
    input resetn_i,
    input descend_1_i,    //for pe 1, val 1 and 4
    input descend_2_i,    //for pe 2, val 2 and 3
    //input values
    input valid_i,
    input [31:0] val_1_i,
    input [31:0] val_2_i,
    input [31:0] val_3_i,
    input [31:0] val_4_i,
    //output values
    output valid_o,
    output descend_1_o,
    output descend_2_o,
    output [31:0] val_1_o,
    output [31:0] val_2_o,
    output [31:0] val_3_o,
    output [31:0] val_4_o
);

    //outputs of pe 1 and pe 2 / inputs of pe 3 and pe 4
    logic [31:0] sorter_pe_1_high_l, sorter_pe_1_low_l;
    logic [31:0] sorter_pe_2_high_l, sorter_pe_2_low_l;
    logic sorter_pe_1_descend_l, sorter_pe_2_descend_l;
    logic sorter_pe_1_valid_l, sorter_pe_2_valid_l, sorter_pe_3_valid_l, sorter_pe_4_valid_l;

    //compares val 1 and val 4
    bitonic_sorter_pe sorter_pe_1 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_1_i),
        .valid_i(valid_i),
        .val_1_i(val_1_i),
        .val_2_i(val_4_i),
        .valid_o(sorter_pe_1_valid_l),
        .descend_o(sorter_pe_1_descend_l),
        .high_o(sorter_pe_1_high_l),
        .low_o(sorter_pe_1_low_l)
    );

    //compares  val 2 and 3
    bitonic_sorter_pe sorter_pe_2 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_2_i),
        .valid_i(valid_i),
        .val_1_i(val_2_i),
        .val_2_i(val_3_i),
        .valid_o(sorter_pe_2_valid_l),
        .descend_o(sorter_pe_2_descend_l),
        .high_o(sorter_pe_2_high_l),
        .low_o(sorter_pe_2_low_l)
    );

    //produces val_1_o and val_2_o - takes the highs form pe 1 and 2
    bitonic_sorter_pe sorter_pe_3 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_1_descend_l),
        .valid_i(sorter_pe_1_valid_l),
        .val_1_i(sorter_pe_1_high_l),
        .val_2_i(sorter_pe_2_high_l),
        .valid_o(sorter_pe_3_valid_l),
        .descend_o(descend_1_o),
        .high_o(val_1_o),
        .low_o(val_2_o)
    );
    
    //produces val_3_o and val_4_o - takes the lows from pe 1 and 2
    bitonic_sorter_pe sorter_pe_4 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_2_descend_l),
        .valid_i(sorter_pe_2_valid_l),
        .val_1_i(sorter_pe_1_low_l),
        .val_2_i(sorter_pe_2_low_l),
        .valid_o(sorter_pe_4_valid_l),
        .descend_o(descend_2_o),
        .high_o(val_3_o),
        .low_o(val_4_o)
    );

    assign valid_o = sorter_pe_3_valid_l & sorter_pe_4_valid_l;
endmodule
