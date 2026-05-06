module bitonic_sorter_2n (
    input clk_i,
    input resetn_i,
    //input values
    input descend_i,    //if high sort G to L
    input [31:0] length_i,
    input valid_i,
    output ready_o,
    input [511:0] bus_a_i,
    input [511:0] bus_b_i,
    //output values
    output valid_o,
    input ready_i,
    output [511:0] bus_a_o,
    output [511:0] bus_b_o,
    //bram access signals
    output [12:0] addr_a_o,
    output [12:0] addr_b_o,
    output wr_back_a_o,
    output wr_back_b_o,
    output rd_en_a_o,
    output rd_en_b_o
);

/*
    instances of 16 sorting PE
*/

//main sorting core
bitonic_sorter_16 sorting_core (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(descend_i),
    .valid_i(valid_i),
    .val_1_i(val_1_i),
    .val_2_i(val_2_i),
    .val_3_i(val_3_i),
    .val_4_i(val_4_i),
    .val_5_i(val_5_i),
    .val_6_i(val_6_i),
    .val_7_i(val_7_i),
    .val_8_i(val_8_i),
    .val_9_i(val_9_i),
    .val_10_i(val_10_i),
    .val_11_i(val_11_i),
    .val_12_i(val_12_i),
    .val_13_i(val_13_i),
    .val_14_i(val_14_i),
    .val_15_i(val_15_i),
    .val_16_i(val_16_i),
    //Outputs
    .valid_o(valid_o),
    .descend_o(descend_o),
    .val_1_o(val_1_o),
    .val_2_o(val_2_o),
    .val_3_o(val_3_o),
    .val_4_o(val_4_o),
    .val_5_o(val_5_o),
    .val_6_o(val_6_o),
    .val_7_o(val_7_o),
    .val_8_o(val_8_o),
    .val_9_o(val_9_o),
    .val_10_o(val_10_o),
    .val_11_o(val_11_o),
    .val_12_o(val_12_o),
    .val_13_o(val_13_o),
    .val_14_o(val_14_o),
    .val_15_o(val_15_o),
    .val_16_o(val_16_o)
);

endmodule
