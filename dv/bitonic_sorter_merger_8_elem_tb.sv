module bitonic_sorter_merger_8_elem_tb
    import config_pkg::*;
    import dv_pkg::*;
;

logic clk_i;
logic resetn_i;
//signals for stage one
logic stage_1_descend_i[4];
logic stage_1_descend_o[4];
logic stage_1_valid_i[4];
logic stage_1_valid_o[4];
logic [31:0] stage_1_val_i[8];
logic [31:0] stage_1_val_o[8];

//signals for stage two
logic stage_2_descend_i[2];
logic stage_2_descend_o[2];
logic stage_2_valid_i[2];
logic stage_2_valid_o[2];
logic [31:0] stage_2_val_i[8];
logic [31:0] stage_2_val_o[8];

//signals for stage three / UUT
logic uut_descend_i[4];
logic uut_descend_o[4];
logic uut_valid_i, uut_valid_o;
logic [31:0] uut_val_i[8];
logic [31:0] uut_val_o[8];

//period
parameter realtime ClockPeriod = clock_period_p;
integer errors;
localparam sample_size_lp = sample_size_p;

//create a mock first stage of 4 PE sorters - already tested
bitonic_sorter_pe preprocessor_1 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(stage_1_descend_i[0]),
    .val_1_i(stage_1_val_i[0]),
    .val_2_i(stage_1_val_i[1]),
    .valid_i(stage_1_valid_i[0]),
    .valid_o(stage_1_valid_o[0]),
    .descend_o(stage_1_descend_o[0]),
    .high_o(stage_1_val_o[0]),
    .low_o(stage_1_val_o[1])
);

bitonic_sorter_pe preprocessor_2 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(stage_1_descend_i[1]),
    .val_1_i(stage_1_val_i[2]),
    .val_2_i(stage_1_val_i[3]),
    .valid_i(stage_1_valid_i[1]),
    .valid_o(stage_1_valid_o[1]),
    .descend_o(stage_1_descend_o[1]),
    .high_o(stage_1_val_o[2]),
    .low_o(stage_1_val_o[3])
);

bitonic_sorter_pe preprocessor_3 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(stage_1_descend_i[2]),
    .val_1_i(stage_1_val_i[4]),
    .val_2_i(stage_1_val_i[5]),
    .valid_i(stage_1_valid_i[2]),
    .valid_o(stage_1_valid_o[2]),
    .descend_o(stage_1_descend_o[2]),
    .high_o(stage_1_val_o[4]),
    .low_o(stage_1_val_o[5])
);

bitonic_sorter_pe preprocessor_4 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(stage_1_descend_i[3]),
    .val_1_i(stage_1_val_i[6]),
    .val_2_i(stage_1_val_i[7]),
    .valid_i(stage_1_valid_i[3]),
    .valid_o(stage_1_valid_o[3]),
    .descend_o(stage_1_descend_o[3]),
    .high_o(stage_1_val_o[6]),
    .low_o(stage_1_val_o[7])
);

//assigning outputs from stage 1 into stage 2
assign stage_2_val_i[0] = stage_1_val_o[0];
assign stage_2_val_i[1] = stage_1_val_o[1];
assign stage_2_val_i[2] = stage_1_val_o[2];
assign stage_2_val_i[3] = stage_1_val_o[3];
assign stage_2_val_i[4] = stage_1_val_o[4];
assign stage_2_val_i[5] = stage_1_val_o[5];
assign stage_2_val_i[6] = stage_1_val_o[6];
assign stage_2_val_i[7] = stage_1_val_o[7];
assign stage_2_descend_i[0] = stage_1_descend_o[0];
assign stage_2_descend_i[1] = stage_1_descend_o[1];
assign stage_2_descend_i[2] = stage_1_descend_o[2];
assign stage_2_descend_i[3] = stage_1_descend_o[3];
assign stage_2_valid_i[0] = stage_1_valid_o[0] & stage_1_valid_o[1];
assign stage_2_valid_i[1] = stage_1_valid_o[2] & stage_1_valid_o[3];

//Mock Second Stage - already tested
bitonic_sorter_merger_4_elem merger_4_pe_1 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_1_i(stage_2_descend_i[0]),
    .descend_2_i(stage_2_descend_i[1]),
    .val_1_i(stage_2_val_i[0]),
    .val_2_i(stage_2_val_i[1]),
    .val_3_i(stage_2_val_i[2]),
    .val_4_i(stage_2_val_i[3]),
    .descend_1_o(stage_2_descend_o[0]),
    .descend_2_o(stage_2_descend_o[1]),
    .valid_i(stage_2_valid_i[0]),
    .valid_o(stage_2_valid_o[0]),
    .val_1_o(stage_2_val_o[0]),
    .val_2_o(stage_2_val_o[1]),
    .val_3_o(stage_2_val_o[2]),
    .val_4_o(stage_2_val_o[3])
);

bitonic_sorter_merger_4_elem merger_4_pe_2 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_1_i(stage_2_descend_i[2]),
    .descend_2_i(stage_2_descend_i[3]),
    .val_1_i(stage_2_val_i[4]),
    .val_2_i(stage_2_val_i[5]),
    .val_3_i(stage_2_val_i[6]),
    .val_4_i(stage_2_val_i[7]),
    .descend_1_o(stage_2_descend_o[2]),
    .descend_2_o(stage_2_descend_o[3]),
    .valid_i(stage_2_valid_i[1]),
    .valid_o(stage_2_valid_o[1]),
    .val_1_o(stage_2_val_o[4]),
    .val_2_o(stage_2_val_o[5]),
    .val_3_o(stage_2_val_o[6]),
    .val_4_o(stage_2_val_o[7])
);

//assigning outputs from stage 2 into UUT
assign uut_val_i[0] = stage_2_val_o[0];
assign uut_val_i[1] = stage_2_val_o[1];
assign uut_val_i[2] = stage_2_val_o[2];
assign uut_val_i[3] = stage_2_val_o[3];
assign uut_val_i[4] = stage_2_val_o[4];
assign uut_val_i[5] = stage_2_val_o[5];
assign uut_val_i[6] = stage_2_val_o[6];
assign uut_val_i[7] = stage_2_val_o[7];
assign uut_descend_i[0] = stage_2_descend_o[0];
assign uut_descend_i[1] = stage_2_descend_o[1];
assign uut_descend_i[2] = stage_2_descend_o[2];
assign uut_descend_i[3] = stage_2_descend_o[3];
assign uut_valid_i = stage_2_valid_o[0] & stage_2_valid_o[1];

//Thrid Stage - The actual UUT
bitonic_sorter_merger_8_elem uut (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_1_i(uut_descend_i[0]),
    .descend_2_i(uut_descend_i[1]),
    .descend_3_i(uut_descend_i[2]),
    .descend_4_i(uut_descend_i[3]),
    .valid_i(uut_valid_i),
    .val_1_i(uut_val_i[0]),
    .val_2_i(uut_val_i[1]),
    .val_3_i(uut_val_i[2]),
    .val_4_i(uut_val_i[3]),
    .val_5_i(uut_val_i[4]),
    .val_6_i(uut_val_i[5]),
    .val_7_i(uut_val_i[6]),
    .val_8_i(uut_val_i[7]),
    .valid_o(uut_valid_o),
    .descend_1_o(uut_descend_o[0]),
    .descend_2_o(uut_descend_o[1]),
    .descend_3_o(uut_descend_o[2]),
    .descend_4_o(uut_descend_o[3]),
    .val_1_o(uut_val_o[0]),
    .val_2_o(uut_val_o[1]),
    .val_3_o(uut_val_o[2]),
    .val_4_o(uut_val_o[3]),
    .val_5_o(uut_val_o[4]),
    .val_6_o(uut_val_o[5]),
    .val_7_o(uut_val_o[6]),
    .val_8_o(uut_val_o[7])
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
    for (int i = 0; i < 8; i++) begin
        stage_1_val_i[i] = '0;
    end
    for (int j = 0; j < 4; j++) begin
        stage_1_descend_i[j] = '0;
        stage_1_valid_i[j] = '0;
    end
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
        for(int i = 0; i < 8; i++) begin
            stage_1_val_i[i] = $urandom();
        end
        for(int j = 0; j < 4; j++) begin
            stage_1_descend_i[j] = descend;
            stage_1_valid_i[j] = '1;
        end
        wait(uut_valid_o == '1);
        @(posedge clk_i);
        //logic 
        if(descend) begin // G to L
            for(int i = 0; i < 7; i++) begin
                if(uut_val_o[i] < uut_val_o[i+1]) begin
                    error_found_this_call = 1'b1;
                    $display("Error: Index %d (%d) < Index %d (%d) in G to L sort", 
                              i, uut_val_o[i], i+1, uut_val_o[i+1]);
                end
            end
        end else begin // L to G
            for(int i = 0; i < 7; i++) begin
                if(uut_val_o[i] > uut_val_o[i+1]) begin
                    error_found_this_call = 1'b1;
                    $display("Error: Index %d (%d) > Index %d (%d) in L to G sort", 
                              i, uut_val_o[i], i+1, uut_val_o[i+1]);
                end
            end
        end

        // Only increment the global error counter once if any violation occurred
        if (error_found_this_call) begin
            errors++;
        end
        for(int i = 0; i < 8; i++) begin
            stage_1_val_i[i] = '0;
        end
        for(int j = 0; j < 4; j++) begin
            stage_1_descend_i[j] = descend;
            stage_1_valid_i[j] = '0;
        end
        //flush uut
        wait(uut_valid_o == 0);
        @(negedge clk_i);
    end
endtask

initial begin
    $dumpfile( "bitonic_sorter_merger_8_elem.fst" );
    $dumpvars;
    $display("Beginning Bitonc Sorter Merger 8 Element Simulation");
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
    $display("Summarizing Bitonc Sorter Merger 8 Element Simulation");
    if(errors) begin
        $error("Failed %d/%d tests", errors, 2 * sample_size_lp);
    end else begin
        $display("Passed all %d tests!", 2 * sample_size_lp);
    end
    @(posedge clk_i);
end

endmodule
