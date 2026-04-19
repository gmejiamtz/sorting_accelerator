module bitonic_sorter_first_stage (
    input clk_i,
    input resetn_i,
    input descend_i,    //if high sort G to L
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
    output [31:0] val_16_o,
);

    logic [31:0] input_sequence_l [16];
    logic [31:0] output_sequence_l [16];

    for(genvar i = 0; i < 8; i=2+i) begin : bitonic_sorter_pe_genloop
        bitonic_sorter_pe first_stage_sorter (
            .clk_i(clk_i),
            .resetn_i(resetn_i),
            .descend_i(descend_i),
            .val_1_i(input_sequence_l[i]),
            .val_2_i(input_sequence_l[i+1]),
            .high_o(output_sequence_l[i]),
            .low_o(output_sequence_l[i+1])
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

endmodule
