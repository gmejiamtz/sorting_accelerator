//Uses a total of 12 Sorter PEs
module bitonic_sorter_merger_8_elem(
    input clk_i,
    input resetn_i,
    input descend_1_i,
    input descend_2_i,
    input descend_3_i,
    input descend_4_i,
    //input values
    input valid_i,
    input [31:0] val_1_i,
    input [31:0] val_2_i,
    input [31:0] val_3_i,
    input [31:0] val_4_i,
    input [31:0] val_5_i,
    input [31:0] val_6_i,
    input [31:0] val_7_i,
    input [31:0] val_8_i,
    //output values
    output valid_o,
    output descend_1_o,
    output descend_2_o,
    output descend_3_o,
    output descend_4_o,
    output [31:0] val_1_o,
    output [31:0] val_2_o,
    output [31:0] val_3_o,
    output [31:0] val_4_o,
    output [31:0] val_5_o,
    output [31:0] val_6_o,
    output [31:0] val_7_o,
    output [31:0] val_8_o
);
    //intermiate signals PEs 1 to 8 output these
    logic [31:0] sorter_pe_1_high_l, sorter_pe_1_low_l;
    logic [31:0] sorter_pe_2_high_l, sorter_pe_2_low_l;
    logic [31:0] sorter_pe_3_high_l, sorter_pe_3_low_l;
    logic [31:0] sorter_pe_4_high_l, sorter_pe_4_low_l;
    logic [31:0] sorter_pe_5_high_l, sorter_pe_5_low_l;
    logic [31:0] sorter_pe_6_high_l, sorter_pe_6_low_l;
    logic [31:0] sorter_pe_7_high_l, sorter_pe_7_low_l;
    logic [31:0] sorter_pe_8_high_l, sorter_pe_8_low_l;
    logic sorter_pe_1_descend_l, sorter_pe_2_descend_l, sorter_pe_3_descend_l, sorter_pe_4_descend_l;
    logic sorter_pe_5_descend_l, sorter_pe_6_descend_l, sorter_pe_7_descend_l, sorter_pe_8_descend_l;
    logic sorter_pe_1_valid_l, sorter_pe_2_valid_l, sorter_pe_3_valid_l, sorter_pe_4_valid_l;
    logic sorter_pe_5_valid_l, sorter_pe_6_valid_l, sorter_pe_7_valid_l, sorter_pe_8_valid_l;
    logic sorter_pe_9_valid_l, sorter_pe_10_valid_l, sorter_pe_11_valid_l, sorter_pe_12_valid_l;

    //compares val 1 and val 8
    bitonic_sorter_pe sorter_pe_1 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_1_i),
        .valid_i(valid_i),
        .val_1_i(val_1_i),
        .val_2_i(val_8_i),
        .valid_o(sorter_pe_1_valid_l),
        .descend_o(sorter_pe_1_descend_l),
        .high_o(sorter_pe_1_high_l),
        .low_o(sorter_pe_1_low_l)
    );

    //compares  val 2 and 7
    bitonic_sorter_pe sorter_pe_2 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_2_i),
        .valid_i(valid_i),
        .val_1_i(val_2_i),
        .val_2_i(val_7_i),
        .valid_o(sorter_pe_2_valid_l),
        .descend_o(sorter_pe_2_descend_l),
        .high_o(sorter_pe_2_high_l),
        .low_o(sorter_pe_2_low_l)
    );

    //compares val 3 and 6
    bitonic_sorter_pe sorter_pe_3 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_3_i),
        .valid_i(valid_i),
        .val_1_i(val_3_i),
        .val_2_i(val_6_i),
        .valid_o(sorter_pe_3_valid_l),
        .descend_o(sorter_pe_3_descend_l),
        .high_o(sorter_pe_3_high_l),
        .low_o(sorter_pe_3_low_l)
    );
    
    //compares val 4 and 5
    bitonic_sorter_pe sorter_pe_4 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_4_i),
        .valid_i(valid_i),
        .val_1_i(val_4_i),
        .val_2_i(val_5_i),
        .valid_o(sorter_pe_4_valid_l),
        .descend_o(sorter_pe_4_descend_l),
        .high_o(sorter_pe_4_high_l),
        .low_o(sorter_pe_4_low_l)
    );

    //compares pe1h and pe3h
    bitonic_sorter_pe sorter_pe_5 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_1_descend_l & sorter_pe_3_descend_l),
        .valid_i(sorter_pe_1_valid_l & sorter_pe_3_valid_l),
        .val_1_i(sorter_pe_1_high_l),
        .val_2_i(sorter_pe_3_high_l),
        .valid_o(sorter_pe_5_valid_l),
        .descend_o(sorter_pe_5_descend_l),
        .high_o(sorter_pe_5_high_l),
        .low_o(sorter_pe_5_low_l)
    );

    //compares pe2h and pe4h
    bitonic_sorter_pe sorter_pe_6 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_2_descend_l & sorter_pe_4_descend_l),
        .valid_i(sorter_pe_2_valid_l & sorter_pe_4_valid_l),
        .val_1_i(sorter_pe_2_high_l),
        .val_2_i(sorter_pe_4_high_l),
        .valid_o(sorter_pe_6_valid_l),
        .descend_o(sorter_pe_6_descend_l),
        .high_o(sorter_pe_6_high_l),
        .low_o(sorter_pe_6_low_l)
    );

    //compares pe2l and pe4l
    bitonic_sorter_pe sorter_pe_7 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_2_descend_l & sorter_pe_4_descend_l),
        .valid_i(sorter_pe_2_valid_l & sorter_pe_4_valid_l),
        .val_1_i(sorter_pe_2_low_l),
        .val_2_i(sorter_pe_4_low_l),
        .valid_o(sorter_pe_7_valid_l),
        .descend_o(sorter_pe_7_descend_l),
        .high_o(sorter_pe_7_high_l),
        .low_o(sorter_pe_7_low_l)
    );
    
    //compares pe1l and pe3l
    bitonic_sorter_pe sorter_pe_8 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_1_descend_l & sorter_pe_3_descend_l),
        .valid_i(sorter_pe_1_valid_l & sorter_pe_3_valid_l),
        .val_1_i(sorter_pe_1_low_l),
        .val_2_i(sorter_pe_3_low_l),
        .valid_o(sorter_pe_8_valid_l),
        .descend_o(sorter_pe_8_descend_l),
        .high_o(sorter_pe_8_high_l),
        .low_o(sorter_pe_8_low_l)
    );

    //compares pe5h and pe6h
    bitonic_sorter_pe sorter_pe_9 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_5_descend_l & sorter_pe_6_descend_l),
        .valid_i(sorter_pe_5_valid_l & sorter_pe_6_valid_l),
        .val_1_i(sorter_pe_5_high_l),
        .val_2_i(sorter_pe_6_high_l),
        .valid_o(sorter_pe_9_valid_l),
        .descend_o(descend_1_o),
        .high_o(val_1_o),
        .low_o(val_2_o)
    );

    //compares pe5l and pe6l
    bitonic_sorter_pe sorter_pe_10 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_5_descend_l & sorter_pe_6_descend_l),
        .valid_i(sorter_pe_5_valid_l & sorter_pe_6_valid_l),
        .val_1_i(sorter_pe_5_low_l),
        .val_2_i(sorter_pe_6_low_l),
        .valid_o(sorter_pe_10_valid_l),
        .descend_o(descend_2_o),
        .high_o(val_3_o),
        .low_o(val_4_o)
    );

    //compares pe7h and pe8h
    bitonic_sorter_pe sorter_pe_11 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_7_descend_l & sorter_pe_8_descend_l),
        .valid_i(sorter_pe_7_valid_l & sorter_pe_8_valid_l),
        .val_1_i(sorter_pe_7_high_l),
        .val_2_i(sorter_pe_8_high_l),
        .valid_o(sorter_pe_11_valid_l),
        .descend_o(descend_3_o),
        .high_o(val_5_o),
        .low_o(val_6_o)
    );
    
    //compares pe7l and pe8l
    bitonic_sorter_pe sorter_pe_12 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_7_descend_l & sorter_pe_8_descend_l),
        .valid_i(sorter_pe_7_valid_l & sorter_pe_8_valid_l),
        .val_1_i(sorter_pe_7_low_l),
        .val_2_i(sorter_pe_8_low_l),
        .valid_o(sorter_pe_12_valid_l),
        .descend_o(descend_4_o),
        .high_o(val_7_o),
        .low_o(val_8_o)
    );

    assign valid_o = sorter_pe_9_valid_l & sorter_pe_10_valid_l & sorter_pe_11_valid_l & sorter_pe_12_valid_l;
endmodule
