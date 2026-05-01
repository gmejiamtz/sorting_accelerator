module bitonic_sorter_third_stage_tb
    import config_pkg::*;
    import dv_pkg::*;
;
logic clk_i;
logic resetn_i;
//uut signals
logic uut_descend_i;
logic uut_valid_i;
logic [31:0] uut_val_i[16];
logic [31:0] uut_val_o[16];
logic uut_valid_o;
logic uut_descend_o;
//first stage signals
logic [31:0] first_val_i[16];
logic [31:0] first_val_o[16];
logic first_valid_i;
logic first_valid_o;
logic first_descend_i;
logic first_descend_o;
//second stage signals
logic [31:0] second_val_i[16];
logic [31:0] second_val_o[16];
logic second_valid_i;
logic second_valid_o;
logic second_descend_i;
logic second_descend_o;

//period
parameter realtime ClockPeriod = clock_period_p;
integer errors;
localparam sample_size_lp = sample_size_p;

bitonic_sorter_first_stage stage_1 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(first_descend_i),
    .valid_i(first_valid_i),
    .val_1_i(first_val_i[0]),
    .val_2_i(first_val_i[1]),
    .val_3_i(first_val_i[2]),
    .val_4_i(first_val_i[3]),
    .val_5_i(first_val_i[4]),
    .val_6_i(first_val_i[5]),
    .val_7_i(first_val_i[6]),
    .val_8_i(first_val_i[7]),
    .val_9_i(first_val_i[8]),
    .val_10_i(first_val_i[9]),
    .val_11_i(first_val_i[10]),
    .val_12_i(first_val_i[11]),
    .val_13_i(first_val_i[12]),
    .val_14_i(first_val_i[13]),
    .val_15_i(first_val_i[14]),
    .val_16_i(first_val_i[15]),
    //Outputs
    .valid_o(first_valid_o),
    .descend_o(first_descend_o),
    .val_1_o(first_val_o[0]),
    .val_2_o(first_val_o[1]),
    .val_3_o(first_val_o[2]),
    .val_4_o(first_val_o[3]),
    .val_5_o(first_val_o[4]),
    .val_6_o(first_val_o[5]),
    .val_7_o(first_val_o[6]),
    .val_8_o(first_val_o[7]),
    .val_9_o(first_val_o[8]),
    .val_10_o(first_val_o[9]),
    .val_11_o(first_val_o[10]),
    .val_12_o(first_val_o[11]),
    .val_13_o(first_val_o[12]),
    .val_14_o(first_val_o[13]),
    .val_15_o(first_val_o[14]),
    .val_16_o(first_val_o[15])
);

//assign inputs of stage 2 from stage 1 outputs
assign second_descend_i = first_descend_o;
assign second_valid_i = first_valid_o;
assign second_val_i = first_val_o;

bitonic_sorter_second_stage stage_2 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(second_descend_i),
    .valid_i(second_valid_i),
    .val_1_i(second_val_i[0]),
    .val_2_i(second_val_i[1]),
    .val_3_i(second_val_i[2]),
    .val_4_i(second_val_i[3]),
    .val_5_i(second_val_i[4]),
    .val_6_i(second_val_i[5]),
    .val_7_i(second_val_i[6]),
    .val_8_i(second_val_i[7]),
    .val_9_i(second_val_i[8]),
    .val_10_i(second_val_i[9]),
    .val_11_i(second_val_i[10]),
    .val_12_i(second_val_i[11]),
    .val_13_i(second_val_i[12]),
    .val_14_i(second_val_i[13]),
    .val_15_i(second_val_i[14]),
    .val_16_i(second_val_i[15]),
    //Outputs
    .valid_o(second_valid_o),
    .descend_o(second_descend_o),
    .val_1_o(second_val_o[0]),
    .val_2_o(second_val_o[1]),
    .val_3_o(second_val_o[2]),
    .val_4_o(second_val_o[3]),
    .val_5_o(second_val_o[4]),
    .val_6_o(second_val_o[5]),
    .val_7_o(second_val_o[6]),
    .val_8_o(second_val_o[7]),
    .val_9_o(second_val_o[8]),
    .val_10_o(second_val_o[9]),
    .val_11_o(second_val_o[10]),
    .val_12_o(second_val_o[11]),
    .val_13_o(second_val_o[12]),
    .val_14_o(second_val_o[13]),
    .val_15_o(second_val_o[14]),
    .val_16_o(second_val_o[15])
);

//assign inputs of stage 2 from stage 1 outputs
assign uut_descend_i = second_descend_o;
assign uut_valid_i = second_valid_o;
assign uut_val_i = second_val_o;

bitonic_sorter_third_stage uut (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(uut_descend_i),
    .valid_i(uut_valid_i),
    .val_1_i(uut_val_i[0]),
    .val_2_i(uut_val_i[1]),
    .val_3_i(uut_val_i[2]),
    .val_4_i(uut_val_i[3]),
    .val_5_i(uut_val_i[4]),
    .val_6_i(uut_val_i[5]),
    .val_7_i(uut_val_i[6]),
    .val_8_i(uut_val_i[7]),
    .val_9_i(uut_val_i[8]),
    .val_10_i(uut_val_i[9]),
    .val_11_i(uut_val_i[10]),
    .val_12_i(uut_val_i[11]),
    .val_13_i(uut_val_i[12]),
    .val_14_i(uut_val_i[13]),
    .val_15_i(uut_val_i[14]),
    .val_16_i(uut_val_i[15]),
    //Outputs
    .valid_o(uut_valid_o),
    .descend_o(uut_descend_o),
    .val_1_o(uut_val_o[0]),
    .val_2_o(uut_val_o[1]),
    .val_3_o(uut_val_o[2]),
    .val_4_o(uut_val_o[3]),
    .val_5_o(uut_val_o[4]),
    .val_6_o(uut_val_o[5]),
    .val_7_o(uut_val_o[6]),
    .val_8_o(uut_val_o[7]),
    .val_9_o(uut_val_o[8]),
    .val_10_o(uut_val_o[9]),
    .val_11_o(uut_val_o[10]),
    .val_12_o(uut_val_o[11]),
    .val_13_o(uut_val_o[12]),
    .val_14_o(uut_val_o[13]),
    .val_15_o(uut_val_o[14]),
    .val_16_o(uut_val_o[15])
);

//clock gen
initial begin
    clk_i = 0;
    forever begin
        #(ClockPeriod/2);
        clk_i = !clk_i;
    end
end

task automatic reset;
    resetn_i = 0;
    errors = 0;
        for (int i = 0; i < 16; i++) begin
        first_val_i[i] = '0;
    end
    first_descend_i = '0;
    first_valid_i = '0;
    //reset for 5 cycles
    repeat (5) begin
        @(posedge clk_i);
    end
    resetn_i = 1;
    //flush hardware for 5 cycles
    repeat (5) begin
        @(posedge clk_i);
    end
endtask

task automatic input_values(input [0:0] descend);
    begin
        logic error_found_this_call;
        @(negedge clk_i);
        error_found_this_call = 0;
        for(int i = 0; i < 16; i++) begin
            first_val_i[i] = $urandom();
        end
        first_descend_i = descend;
        first_valid_i = '1;
        wait(uut_valid_o == 1);
        @(posedge clk_i);
        //logic 
        for (int group = 0; group < 8; group++) begin
            int base = group * 8;
            if (descend) begin // G to L
                for (int i = 0; i < 7; i++) begin
                    if (uut_val_o[base + i] < uut_val_o[base + i + 1]) begin
                        error_found_this_call = 1'b1;
                        $display("Error: Group %0d, Index %0d (%0d) < Index %0d (%0d) in G to L sort", 
                                  group, base+i, uut_val_o[base+i], base+i+1, uut_val_o[base+i+1]);
                    end
                end
            end else begin // L to G
                for (int i = 0; i < 7; i++) begin
                    if (uut_val_o[base + i] > uut_val_o[base + i + 1]) begin
                        error_found_this_call = 1'b1;
                        $display("Error: Group %0d, Index %0d (%0d) > Index %0d (%0d) in L to G sort", 
                                  group, base+i, uut_val_o[base+i], base+i+1, uut_val_o[base+i+1]);
                    end
                end
            end
        end
        // Only increment the global error counter once if any violation occurred
        if (error_found_this_call) begin
            errors++;
        end
        for(int i = 0; i < 16; i++) begin
            first_val_i[i] = '0;
        end
        first_valid_i = 0;
        wait(uut_valid_o == 0);
        @(negedge clk_i);
    end
endtask

initial begin
    $dumpfile( "bitonic_sorter_third_stage.fst" );
    $dumpvars;
    $display("Beginning Bitonc Sorter Third Stage Simulation");
    reset();
    $display("Testing L to G sorting");
    for(int i = 0; i < sample_size_lp; i++) begin
        input_values('0);
    end
    $display("Testing G to L sorting");
    for(int i = 0; i < sample_size_lp; i++) begin
        input_values('1);
    end
    $finish;
end

final begin
    $display("Summarizing Bitonc Sorter Third Stage Simulation");
    if(errors) begin
        $error("Failed %d/%d tests", errors, 2 * sample_size_lp);
    end else begin
        $display("Passed all %d tests!", 2 * sample_size_lp);
    end
end

endmodule
