module bitonic_sorter_merger_4_elem_tb;

logic clk_i;
logic resetn_i;
logic descend_1_i, descend_2_i;
logic descend_1_o, descend_2_o;
logic pe_1_valid_i, pe_2_valid_i;
logic pe_1_valid_o, pe_2_valid_o;
logic [31:0] val_1_i, val_2_i, val_3_i, val_4_i;
logic [31:0] val_1_o, val_2_o, val_3_o, val_4_o;
logic [31:0] output_array [4];  //array sorted by the uut
logic uut_valid_o;

//period
parameter realtime ClockPeriod = 20ns;
integer errors;
localparam sample_size_lp = 10;

//create a mock first stage of 2 PE sorters - alreadt tested
bitonic_sorter_pe preprocessor_1 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(descend_1_i),
    .val_1_i(val_1_i),
    .val_2_i(val_2_i),
    .valid_i(pe_1_valid_i),
    .valid_o(pe_1_valid_o),
    .descend_o(descend_1_o),
    .high_o(val_1_o),
    .low_o(val_2_o)
);

bitonic_sorter_pe preprocessor_2 (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(descend_2_i),
    .val_1_i(val_3_i),
    .val_2_i(val_4_i),
    .valid_i(pe_2_valid_i),
    .valid_o(pe_2_valid_o),
    .descend_o(descend_2_o),
    .high_o(val_3_o),
    .low_o(val_4_o)
);

bitonic_sorter_merger_4_elem uut (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_1_i(descend_1_o),
    .descend_2_i(descend_2_o),
    .val_1_i(val_1_o),
    .val_2_i(val_2_o),
    .val_3_i(val_3_o),
    .val_4_i(val_4_o),
    .descend_1_o(),
    .descend_2_o(),
    .valid_i(pe_1_valid_o & pe_2_valid_o),
    .valid_o(uut_valid_o),
    .val_1_o(output_array[0]),
    .val_2_o(output_array[1]),
    .val_3_o(output_array[2]),
    .val_4_o(output_array[3])
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
    resetn_i <= 0;
    val_1_i <= '0;
    val_2_i <= '0;
    val_3_i <= '0;
    val_4_i <= '0;
    descend_1_i <= '0;
    descend_2_i <= '0;
    errors <= 0;
    //reset for 5 cycles
    repeat (5) begin
        @(posedge clk_i);
    end
    resetn_i <= 1;
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
        val_1_i = $urandom();
        val_2_i = $urandom();
        val_3_i = $urandom();
        val_4_i = $urandom();
        descend_1_i = descend;
        descend_2_i = descend;
        pe_1_valid_i = 1;
        pe_2_valid_i = 1;
        wait(uut_valid_o == '1);
        @(posedge clk_i);
        //logic 
        if(descend) begin // G to L
            for(int i = 0; i < 3; i++) begin
                if(output_array[i] < output_array[i+1]) begin
                    error_found_this_call = 1'b1;
                    $display("Error: Index %d (%d) < Index %d (%d) in G to L sort", 
                              i, output_array[i], i+1, output_array[i+1]);
                end
            end
        end else begin // L to G
            for(int i = 0; i < 3; i++) begin
                if(output_array[i] > output_array[i+1]) begin
                    error_found_this_call = 1'b1;
                    $display("Error: Index %d (%d) > Index %d (%d) in L to G sort", 
                              i, output_array[i], i+1, output_array[i+1]);
                end
            end
        end

        // Only increment the global error counter once if any violation occurred
        if (error_found_this_call) begin
            errors++;
        end
        pe_1_valid_i = 0;
        pe_2_valid_i = 0;
        val_1_i = 0;
        val_2_i = 0;
        val_3_i = 0;
        val_4_i = 0;
        //flush uut
        wait(uut_valid_o == 0);
        @(negedge clk_i);
    end
endtask

initial begin
    $dumpfile( "bitonic_sorter_merger_4_elem.fst" );
    $dumpvars;
    $display("Beginning Bitonc Sorter Merger 4 Element Simulation");
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
    $display("Summarizing Bitonc Sorter Merger 4 Element Simulation");
    if(errors) begin
        $error("Failed %d/%d tests", errors, 2 * sample_size_lp);
    end else begin
        $display("Passed all %d tests!", 2 * sample_size_lp);
    end
    @(posedge clk_i);
end

endmodule
