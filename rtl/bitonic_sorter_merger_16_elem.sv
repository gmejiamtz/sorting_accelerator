//Uses a total of 32 Sorter PEs
module bitonic_sorter_merger_16_elem(
    input clk_i,
    input resetn_i,
    input descend_1_i,
    input descend_2_i,
    input descend_3_i,
    input descend_4_i,
    input descend_5_i,
    input descend_6_i,
    input descend_7_i,
    input descend_8_i,
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
    input [31:0] val_9_i,
    input [31:0] val_10_i,
    input [31:0] val_11_i,
    input [31:0] val_12_i,
    input [31:0] val_13_i,
    input [31:0] val_14_i,
    input [31:0] val_15_i,
    input [31:0] val_16_i,
    //output values
    output valid_o,
    output descend_1_o,
    output descend_2_o,
    output descend_3_o,
    output descend_4_o,
    output descend_5_o,
    output descend_6_o,
    output descend_7_o,
    output descend_8_o,
    output [31:0] val_1_o,
    output [31:0] val_2_o,
    output [31:0] val_3_o,
    output [31:0] val_4_o,
    output [31:0] val_5_o,
    output [31:0] val_6_o,
    output [31:0] val_7_o,
    output [31:0] val_8_o,
    output [31:0] val_9_o,
    output [31:0] val_10_o,
    output [31:0] val_11_o,
    output [31:0] val_12_o,
    output [31:0] val_13_o,
    output [31:0] val_14_o,
    output [31:0] val_15_o,
    output [31:0] val_16_o
);
    //intermiate signals PEs 1 to 24 output these
    logic [31:0] sorter_pe_1_high_l, sorter_pe_1_low_l;
    logic [31:0] sorter_pe_2_high_l, sorter_pe_2_low_l;
    logic [31:0] sorter_pe_3_high_l, sorter_pe_3_low_l;
    logic [31:0] sorter_pe_4_high_l, sorter_pe_4_low_l;
    logic [31:0] sorter_pe_5_high_l, sorter_pe_5_low_l;
    logic [31:0] sorter_pe_6_high_l, sorter_pe_6_low_l;
    logic [31:0] sorter_pe_7_high_l, sorter_pe_7_low_l;
    logic [31:0] sorter_pe_8_high_l, sorter_pe_8_low_l;
    logic [31:0] sorter_pe_9_high_l, sorter_pe_9_low_l;
    logic [31:0] sorter_pe_10_high_l, sorter_pe_10_low_l;
    logic [31:0] sorter_pe_11_high_l, sorter_pe_11_low_l;
    logic [31:0] sorter_pe_12_high_l, sorter_pe_12_low_l;
    logic [31:0] sorter_pe_13_high_l, sorter_pe_13_low_l;
    logic [31:0] sorter_pe_14_high_l, sorter_pe_14_low_l;
    logic [31:0] sorter_pe_15_high_l, sorter_pe_15_low_l;
    logic [31:0] sorter_pe_16_high_l, sorter_pe_16_low_l;
    logic [31:0] sorter_pe_17_high_l, sorter_pe_17_low_l;
    logic [31:0] sorter_pe_18_high_l, sorter_pe_18_low_l;
    logic [31:0] sorter_pe_19_high_l, sorter_pe_19_low_l;
    logic [31:0] sorter_pe_20_high_l, sorter_pe_20_low_l;
    logic [31:0] sorter_pe_21_high_l, sorter_pe_21_low_l;
    logic [31:0] sorter_pe_22_high_l, sorter_pe_22_low_l;
    logic [31:0] sorter_pe_23_high_l, sorter_pe_23_low_l;
    logic [31:0] sorter_pe_24_high_l, sorter_pe_24_low_l;
    logic sorter_pe_1_descend_l, sorter_pe_2_descend_l, sorter_pe_3_descend_l, sorter_pe_4_descend_l;
    logic sorter_pe_5_descend_l, sorter_pe_6_descend_l, sorter_pe_7_descend_l, sorter_pe_8_descend_l;
    logic sorter_pe_9_descend_l,  sorter_pe_10_descend_l, sorter_pe_11_descend_l, sorter_pe_12_descend_l;
    logic sorter_pe_13_descend_l, sorter_pe_14_descend_l, sorter_pe_15_descend_l, sorter_pe_16_descend_l;
    logic sorter_pe_17_descend_l, sorter_pe_18_descend_l, sorter_pe_19_descend_l, sorter_pe_20_descend_l;
    logic sorter_pe_21_descend_l, sorter_pe_22_descend_l, sorter_pe_23_descend_l, sorter_pe_24_descend_l;
    logic sorter_pe_1_valid_l, sorter_pe_2_valid_l, sorter_pe_3_valid_l, sorter_pe_4_valid_l;
    logic sorter_pe_5_valid_l, sorter_pe_6_valid_l, sorter_pe_7_valid_l, sorter_pe_8_valid_l;
    logic sorter_pe_9_valid_l, sorter_pe_10_valid_l, sorter_pe_11_valid_l, sorter_pe_12_valid_l;
    logic sorter_pe_13_valid_l, sorter_pe_14_valid_l, sorter_pe_15_valid_l, sorter_pe_16_valid_l;
    logic sorter_pe_17_valid_l, sorter_pe_18_valid_l, sorter_pe_19_valid_l, sorter_pe_20_valid_l;
    logic sorter_pe_21_valid_l, sorter_pe_22_valid_l, sorter_pe_23_valid_l, sorter_pe_24_valid_l;
    logic sorter_pe_25_valid_l, sorter_pe_26_valid_l, sorter_pe_27_valid_l, sorter_pe_28_valid_l;
    logic sorter_pe_29_valid_l, sorter_pe_30_valid_l, sorter_pe_31_valid_l, sorter_pe_32_valid_l;

    //compares val 1 and val 16
    bitonic_sorter_pe sorter_pe_1 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_1_i),
        .valid_i(valid_i),
        .val_1_i(val_1_i),
        .val_2_i(val_16_i),
        .valid_o(sorter_pe_1_valid_l),
        .descend_o(sorter_pe_1_descend_l),
        .high_o(sorter_pe_1_high_l),
        .low_o(sorter_pe_1_low_l)
    );

    //compares  val 2 and 15
    bitonic_sorter_pe sorter_pe_2 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_2_i),
        .valid_i(valid_i),
        .val_1_i(val_2_i),
        .val_2_i(val_15_i),
        .valid_o(sorter_pe_2_valid_l),
        .descend_o(sorter_pe_2_descend_l),
        .high_o(sorter_pe_2_high_l),
        .low_o(sorter_pe_2_low_l)
    );

    //compares val 3 and 14
    bitonic_sorter_pe sorter_pe_3 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_3_i),
        .valid_i(valid_i),
        .val_1_i(val_3_i),
        .val_2_i(val_14_i),
        .valid_o(sorter_pe_3_valid_l),
        .descend_o(sorter_pe_3_descend_l),
        .high_o(sorter_pe_3_high_l),
        .low_o(sorter_pe_3_low_l)
    );
    
    //compares val 4 and 13
    bitonic_sorter_pe sorter_pe_4 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_4_i),
        .valid_i(valid_i),
        .val_1_i(val_4_i),
        .val_2_i(val_13_i),
        .valid_o(sorter_pe_4_valid_l),
        .descend_o(sorter_pe_4_descend_l),
        .high_o(sorter_pe_4_high_l),
        .low_o(sorter_pe_4_low_l)
    );

    //compares val 5 and 12
    bitonic_sorter_pe sorter_pe_5 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_5_i),
        .valid_i(valid_i),
        .val_1_i(val_5_i),
        .val_2_i(val_12_i),
        .valid_o(sorter_pe_5_valid_l),
        .descend_o(sorter_pe_5_descend_l),
        .high_o(sorter_pe_5_high_l),
        .low_o(sorter_pe_5_low_l)
    );

    //compares val 6 and 11
    bitonic_sorter_pe sorter_pe_6 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_6_i),
        .valid_i(valid_i),
        .val_1_i(val_6_i),
        .val_2_i(val_11_i),
        .valid_o(sorter_pe_6_valid_l),
        .descend_o(sorter_pe_6_descend_l),
        .high_o(sorter_pe_6_high_l),
        .low_o(sorter_pe_6_low_l)
    );

    //compares val 7 and 10
    bitonic_sorter_pe sorter_pe_7 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_7_i),
        .valid_i(valid_i),
        .val_1_i(val_7_i),
        .val_2_i(val_10_i),
        .valid_o(sorter_pe_7_valid_l),
        .descend_o(sorter_pe_7_descend_l),
        .high_o(sorter_pe_7_high_l),
        .low_o(sorter_pe_7_low_l)
    );

    //compares val 8 and 9
    bitonic_sorter_pe sorter_pe_8 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(descend_8_i),
        .valid_i(valid_i),
        .val_1_i(val_8_i),
        .val_2_i(val_9_i),
        .valid_o(sorter_pe_8_valid_l),
        .descend_o(sorter_pe_8_descend_l),
        .high_o(sorter_pe_8_high_l),
        .low_o(sorter_pe_8_low_l)
    );

    //compares pe1h and pe5h
    bitonic_sorter_pe sorter_pe_9 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_1_descend_l & sorter_pe_5_descend_l),
        .valid_i(sorter_pe_1_valid_l & sorter_pe_5_valid_l),
        .val_1_i(sorter_pe_1_high_l),
        .val_2_i(sorter_pe_5_high_l),
        .valid_o(sorter_pe_9_valid_l),
        .descend_o(sorter_pe_9_descend_l),
        .high_o(sorter_pe_9_high_l),
        .low_o(sorter_pe_9_low_l)
    );

    //compares pe2h and pe6h
    bitonic_sorter_pe sorter_pe_10 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_2_descend_l & sorter_pe_6_descend_l),
        .valid_i(sorter_pe_2_valid_l & sorter_pe_6_valid_l),
        .val_1_i(sorter_pe_2_high_l),
        .val_2_i(sorter_pe_6_high_l),
        .valid_o(sorter_pe_10_valid_l),
        .descend_o(sorter_pe_10_descend_l),
        .high_o(sorter_pe_10_high_l),
        .low_o(sorter_pe_10_low_l)
    );

    //compares pe3h and pe7h
    bitonic_sorter_pe sorter_pe_11 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_3_descend_l & sorter_pe_7_descend_l),
        .valid_i(sorter_pe_3_valid_l & sorter_pe_7_valid_l),
        .val_1_i(sorter_pe_3_high_l),
        .val_2_i(sorter_pe_7_high_l),
        .valid_o(sorter_pe_11_valid_l),
        .descend_o(sorter_pe_11_descend_l),
        .high_o(sorter_pe_11_high_l),
        .low_o(sorter_pe_11_low_l)
    );

    //compares pe4h and pe8h
    bitonic_sorter_pe sorter_pe_12 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_4_descend_l & sorter_pe_8_descend_l),
        .valid_i(sorter_pe_4_valid_l & sorter_pe_8_valid_l),
        .val_1_i(sorter_pe_4_high_l),
        .val_2_i(sorter_pe_8_high_l),
        .valid_o(sorter_pe_12_valid_l),
        .descend_o(sorter_pe_12_descend_l),
        .high_o(sorter_pe_12_high_l),
        .low_o(sorter_pe_12_low_l)
    );

    //compares pe4l and pe8l
    bitonic_sorter_pe sorter_pe_13 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_4_descend_l & sorter_pe_8_descend_l),
        .valid_i(sorter_pe_4_valid_l & sorter_pe_8_valid_l),
        .val_1_i(sorter_pe_4_low_l),
        .val_2_i(sorter_pe_8_low_l),
        .valid_o(sorter_pe_13_valid_l),
        .descend_o(sorter_pe_13_descend_l),
        .high_o(sorter_pe_13_high_l),
        .low_o(sorter_pe_13_low_l)
    );

    //compares pe3l and pe7l
    bitonic_sorter_pe sorter_pe_14 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_3_descend_l & sorter_pe_7_descend_l),
        .valid_i(sorter_pe_3_valid_l & sorter_pe_7_valid_l),
        .val_1_i(sorter_pe_3_low_l),
        .val_2_i(sorter_pe_7_low_l),
        .valid_o(sorter_pe_14_valid_l),
        .descend_o(sorter_pe_14_descend_l),
        .high_o(sorter_pe_14_high_l),
        .low_o(sorter_pe_14_low_l)
    );

    //compares pe2l and pe6l
    bitonic_sorter_pe sorter_pe_15 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_2_descend_l & sorter_pe_6_descend_l),
        .valid_i(sorter_pe_2_valid_l & sorter_pe_6_valid_l),
        .val_1_i(sorter_pe_2_low_l),
        .val_2_i(sorter_pe_6_low_l),
        .valid_o(sorter_pe_15_valid_l),
        .descend_o(sorter_pe_15_descend_l),
        .high_o(sorter_pe_15_high_l),
        .low_o(sorter_pe_15_low_l)
    );

    //compares pe1l and pe5l
    bitonic_sorter_pe sorter_pe_16 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_1_descend_l & sorter_pe_5_descend_l),
        .valid_i(sorter_pe_1_valid_l & sorter_pe_5_valid_l),
        .val_1_i(sorter_pe_1_low_l),
        .val_2_i(sorter_pe_5_low_l),
        .valid_o(sorter_pe_16_valid_l),
        .descend_o(sorter_pe_16_descend_l),
        .high_o(sorter_pe_16_high_l),
        .low_o(sorter_pe_16_low_l)
    );

    //compares pe9h and pe11h
    bitonic_sorter_pe sorter_pe_17 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_9_descend_l & sorter_pe_11_descend_l),
        .valid_i(sorter_pe_9_valid_l & sorter_pe_11_valid_l),
        .val_1_i(sorter_pe_9_high_l),
        .val_2_i(sorter_pe_11_high_l),
        .valid_o(sorter_pe_17_valid_l),
        .descend_o(sorter_pe_17_descend_l),
        .high_o(sorter_pe_17_high_l),
        .low_o(sorter_pe_17_low_l)
    );

    //compares pe10h and pe12h
    bitonic_sorter_pe sorter_pe_18 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_10_descend_l & sorter_pe_12_descend_l),
        .valid_i(sorter_pe_10_valid_l & sorter_pe_12_valid_l),
        .val_1_i(sorter_pe_10_high_l),
        .val_2_i(sorter_pe_12_high_l),
        .valid_o(sorter_pe_18_valid_l),
        .descend_o(sorter_pe_18_descend_l),
        .high_o(sorter_pe_18_high_l),
        .low_o(sorter_pe_18_low_l)
    );

    //compares pe9l and pe11l
    bitonic_sorter_pe sorter_pe_19 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_9_descend_l & sorter_pe_11_descend_l),
        .valid_i(sorter_pe_9_valid_l & sorter_pe_11_valid_l),
        .val_1_i(sorter_pe_9_low_l),
        .val_2_i(sorter_pe_11_low_l),
        .valid_o(sorter_pe_19_valid_l),
        .descend_o(sorter_pe_19_descend_l),
        .high_o(sorter_pe_19_high_l),
        .low_o(sorter_pe_19_low_l)
    );

    //compares pe10l and pe12l
    bitonic_sorter_pe sorter_pe_20 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_10_descend_l & sorter_pe_12_descend_l),
        .valid_i(sorter_pe_10_valid_l & sorter_pe_12_valid_l),
        .val_1_i(sorter_pe_10_low_l),
        .val_2_i(sorter_pe_12_low_l),
        .valid_o(sorter_pe_20_valid_l),
        .descend_o(sorter_pe_20_descend_l),
        .high_o(sorter_pe_20_high_l),
        .low_o(sorter_pe_20_low_l)
    );

    //compares pe13h and pe15h
    bitonic_sorter_pe sorter_pe_21 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_13_descend_l & sorter_pe_15_descend_l),
        .valid_i(sorter_pe_13_valid_l & sorter_pe_15_valid_l),
        .val_1_i(sorter_pe_13_high_l),
        .val_2_i(sorter_pe_15_high_l),
        .valid_o(sorter_pe_21_valid_l),
        .descend_o(sorter_pe_21_descend_l),
        .high_o(sorter_pe_21_high_l),
        .low_o(sorter_pe_21_low_l)
    );

    //compares pe14h and pe16h
    bitonic_sorter_pe sorter_pe_22 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_14_descend_l & sorter_pe_16_descend_l),
        .valid_i(sorter_pe_14_valid_l & sorter_pe_16_valid_l),
        .val_1_i(sorter_pe_14_high_l),
        .val_2_i(sorter_pe_16_high_l),
        .valid_o(sorter_pe_22_valid_l),
        .descend_o(sorter_pe_22_descend_l),
        .high_o(sorter_pe_22_high_l),
        .low_o(sorter_pe_22_low_l)
    );

    //compares pe13l and pe15l
    bitonic_sorter_pe sorter_pe_23 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_13_descend_l & sorter_pe_15_descend_l),
        .valid_i(sorter_pe_13_valid_l & sorter_pe_15_valid_l),
        .val_1_i(sorter_pe_13_low_l),
        .val_2_i(sorter_pe_15_low_l),
        .valid_o(sorter_pe_23_valid_l),
        .descend_o(sorter_pe_23_descend_l),
        .high_o(sorter_pe_23_high_l),
        .low_o(sorter_pe_23_low_l)
    );

    //compares pe14l and pe16l
    bitonic_sorter_pe sorter_pe_24 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_14_descend_l & sorter_pe_16_descend_l),
        .valid_i(sorter_pe_14_valid_l & sorter_pe_16_valid_l),
        .val_1_i(sorter_pe_14_low_l),
        .val_2_i(sorter_pe_16_low_l),
        .valid_o(sorter_pe_24_valid_l),
        .descend_o(sorter_pe_24_descend_l),
        .high_o(sorter_pe_24_high_l),
        .low_o(sorter_pe_24_low_l)
    );

    /* Directly Output Values */

    //compares pe17h and pe18h
    bitonic_sorter_pe sorter_pe_25 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_17_descend_l & sorter_pe_18_descend_l),
        .valid_i(sorter_pe_17_valid_l & sorter_pe_18_valid_l),
        .val_1_i(sorter_pe_17_high_l),
        .val_2_i(sorter_pe_18_high_l),
        .valid_o(sorter_pe_25_valid_l),
        .descend_o(descend_1_o),
        .high_o(val_1_o),
        .low_o(val_2_o)
    );

    //compares pe17l and pe18l
    bitonic_sorter_pe sorter_pe_26 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_17_descend_l & sorter_pe_18_descend_l),
        .valid_i(sorter_pe_17_valid_l & sorter_pe_18_valid_l),
        .val_1_i(sorter_pe_17_low_l),
        .val_2_i(sorter_pe_18_low_l),
        .valid_o(sorter_pe_26_valid_l),
        .descend_o(descend_2_o),
        .high_o(val_3_o),
        .low_o(val_4_o)
    );

    //compares pe19h and pe20h
    bitonic_sorter_pe sorter_pe_27 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_19_descend_l & sorter_pe_20_descend_l),
        .valid_i(sorter_pe_19_valid_l & sorter_pe_20_valid_l),
        .val_1_i(sorter_pe_19_high_l),
        .val_2_i(sorter_pe_20_high_l),
        .valid_o(sorter_pe_27_valid_l),
        .descend_o(descend_3_o),
        .high_o(val_5_o),
        .low_o(val_6_o)
    );

    //compares pe19l and pe20l
    bitonic_sorter_pe sorter_pe_28 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_19_descend_l & sorter_pe_20_descend_l),
        .valid_i(sorter_pe_19_valid_l & sorter_pe_20_valid_l),
        .val_1_i(sorter_pe_19_low_l),
        .val_2_i(sorter_pe_20_low_l),
        .valid_o(sorter_pe_28_valid_l),
        .descend_o(descend_4_o),
        .high_o(val_7_o),
        .low_o(val_8_o)
    );

    //compares pe21h and pe22h
    bitonic_sorter_pe sorter_pe_29 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_21_descend_l & sorter_pe_22_descend_l),
        .valid_i(sorter_pe_21_valid_l & sorter_pe_22_valid_l),
        .val_1_i(sorter_pe_21_high_l),
        .val_2_i(sorter_pe_22_high_l),
        .valid_o(sorter_pe_29_valid_l),
        .descend_o(descend_5_o),
        .high_o(val_9_o),
        .low_o(val_10_o)
    );

    //compares pe21l and pe22l
    bitonic_sorter_pe sorter_pe_30 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_21_descend_l & sorter_pe_22_descend_l),
        .valid_i(sorter_pe_21_valid_l & sorter_pe_22_valid_l),
        .val_1_i(sorter_pe_21_low_l),
        .val_2_i(sorter_pe_22_low_l),
        .valid_o(sorter_pe_30_valid_l),
        .descend_o(descend_6_o),
        .high_o(val_11_o),
        .low_o(val_12_o)
    );

    //compares pe23h and pe24h
    bitonic_sorter_pe sorter_pe_31 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_23_descend_l & sorter_pe_24_descend_l),
        .valid_i(sorter_pe_23_valid_l & sorter_pe_24_valid_l),
        .val_1_i(sorter_pe_23_high_l),
        .val_2_i(sorter_pe_24_high_l),
        .valid_o(sorter_pe_31_valid_l),
        .descend_o(descend_7_o),
        .high_o(val_13_o),
        .low_o(val_14_o)
    );

    //compares pe23l and pe24l
    bitonic_sorter_pe sorter_pe_32 (
        .clk_i(clk_i),
        .resetn_i(resetn_i),
        .descend_i(sorter_pe_23_descend_l & sorter_pe_24_descend_l),
        .valid_i(sorter_pe_23_valid_l & sorter_pe_24_valid_l),
        .val_1_i(sorter_pe_23_low_l),
        .val_2_i(sorter_pe_24_low_l),
        .valid_o(sorter_pe_32_valid_l),
        .descend_o(descend_8_o),
        .high_o(val_15_o),
        .low_o(val_16_o)
    );

    assign valid_o = sorter_pe_25_valid_l & sorter_pe_26_valid_l & sorter_pe_27_valid_l & sorter_pe_28_valid_l & sorter_pe_29_valid_l & sorter_pe_30_valid_l & sorter_pe_31_valid_l & sorter_pe_32_valid_l;

endmodule
