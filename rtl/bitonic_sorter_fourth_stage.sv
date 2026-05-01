module bitonic_sorter_fourth_stage (
    input clk_i,
    input resetn_i,
    input descend_i,    //if high sort G to L
    input valid_i,
    //input values
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
    output descend_o,
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

    logic [31:0] input_sequence_l [16];
    logic [31:0] output_sequence_l [16];
    logic [0:0] valid_l;    //clog2(pe_count)
    logic [0:0] descend_1_l;
    logic [0:0] descend_2_l;
    logic [0:0] descend_3_l;
    logic [0:0] descend_4_l;
    logic [0:0] descend_5_l;
    logic [0:0] descend_6_l;
    logic [0:0] descend_7_l;
    logic [0:0] descend_8_l;

    for(genvar i = 0; i < 16; i=16+i) begin : bitonic_sorter_merger_16_elem_genloop
        bitonic_sorter_merger_16_elem fourth_stage_sorter (
            .clk_i(clk_i),
            .resetn_i(resetn_i),
            .descend_1_i(descend_i),
            .descend_2_i(descend_i),
            .descend_3_i(descend_i),
            .descend_4_i(descend_i),
            .descend_5_i(descend_i),
            .descend_6_i(descend_i),
            .descend_7_i(descend_i),
            .descend_8_i(descend_i),
            .val_1_i(input_sequence_l[i]),
            .val_2_i(input_sequence_l[i+1]),
            .val_3_i(input_sequence_l[i+2]),
            .val_4_i(input_sequence_l[i+3]),
            .val_5_i(input_sequence_l[i+4]),
            .val_6_i(input_sequence_l[i+5]),
            .val_7_i(input_sequence_l[i+6]),
            .val_8_i(input_sequence_l[i+7]),
            .val_9_i(input_sequence_l[i+8]),
            .val_10_i(input_sequence_l[i+9]),
            .val_11_i(input_sequence_l[i+10]),
            .val_12_i(input_sequence_l[i+11]),
            .val_13_i(input_sequence_l[i+12]),
            .val_14_i(input_sequence_l[i+13]),
            .val_15_i(input_sequence_l[i+14]),
            .val_16_i(input_sequence_l[i+15]),
            .descend_1_o(descend_1_l[i>>3]),
            .descend_2_o(descend_2_l[i>>3]),
            .descend_3_o(descend_3_l[i>>3]),
            .descend_4_o(descend_4_l[i>>3]),
            .descend_5_o(descend_5_l[i>>3]),
            .descend_6_o(descend_6_l[i>>3]),
            .descend_7_o(descend_7_l[i>>3]),
            .descend_8_o(descend_8_l[i>>3]),
            .valid_i(valid_i),
            .valid_o(valid_l[i>>3]),
            .val_1_o(output_sequence_l[i]),
            .val_2_o(output_sequence_l[i+1]),
            .val_3_o(output_sequence_l[i+2]),
            .val_4_o(output_sequence_l[i+3]),
            .val_5_o(output_sequence_l[i+4]),
            .val_6_o(output_sequence_l[i+5]),
            .val_7_o(output_sequence_l[i+6]),
            .val_8_o(output_sequence_l[i+7]),
            .val_9_o(output_sequence_l[i+8]),
            .val_10_o(output_sequence_l[i+9]),
            .val_11_o(output_sequence_l[i+10]),
            .val_12_o(output_sequence_l[i+11]),
            .val_13_o(output_sequence_l[i+12]),
            .val_14_o(output_sequence_l[i+13]),
            .val_15_o(output_sequence_l[i+14]),
            .val_16_o(output_sequence_l[i+15])
        );
    end

    always_comb begin : comb_logic
        input_sequence_l[0] = val_1_i;
        input_sequence_l[1] = val_2_i;
        input_sequence_l[2] = val_3_i;
        input_sequence_l[3] = val_4_i;
        input_sequence_l[4] = val_5_i;
        input_sequence_l[5] = val_6_i;
        input_sequence_l[6] = val_7_i;
        input_sequence_l[7] = val_8_i;
        input_sequence_l[8] = val_9_i;
        input_sequence_l[9] = val_10_i;
        input_sequence_l[10] = val_11_i;
        input_sequence_l[11] = val_12_i;
        input_sequence_l[12] = val_13_i;
        input_sequence_l[13] = val_14_i;
        input_sequence_l[14] = val_15_i;
        input_sequence_l[15] = val_16_i;
    end
    assign val_1_o  = output_sequence_l[0];
    assign val_2_o  = output_sequence_l[1];
    assign val_3_o  = output_sequence_l[2];
    assign val_4_o  = output_sequence_l[3];
    assign val_5_o  = output_sequence_l[4];
    assign val_6_o  = output_sequence_l[5];
    assign val_7_o  = output_sequence_l[6];
    assign val_8_o  = output_sequence_l[7];
    assign val_9_o  = output_sequence_l[8];
    assign val_10_o = output_sequence_l[9];
    assign val_11_o = output_sequence_l[10];
    assign val_12_o = output_sequence_l[11];
    assign val_13_o = output_sequence_l[12];
    assign val_14_o = output_sequence_l[13];
    assign val_15_o = output_sequence_l[14];
    assign val_16_o = output_sequence_l[15];
    assign valid_o = &valid_l;
    assign descend_o = &descend_1_l & &descend_2_l & &descend_3_l & &descend_4_l;

endmodule
