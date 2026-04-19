module bitonic_sorter_pe_tb;

logic clk_i;
logic resetn_i;
logic descend_i;
logic [31:0] val_1_i, val_2_i;
logic [31:0] high_o,low_o;

//period
parameter realtime ClockPeriod = 20ns;
integer errors;
localparam sample_size_lp = 1000000;

bitonic_sorter_pe uut (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .descend_i(descend_i),
    .val_1_i(val_1_i),
    .val_2_i(val_2_i),
    .high_o(high_o),
    .low_o(low_o)
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

task automatic input_values(input [31:0] val_1, input [31:0] val_2,input [0:0] descend);
    begin
        val_1_i = val_1;
        val_2_i = val_2;
        descend_i = descend;
        @(negedge clk_i);
        @(posedge clk_i); //sorter pe takes a cycle to compute its values
        if(descend_i) begin
            if(high_o < low_o) begin
                errors++;
                $display("G to L sort failed! %d not greater than or equal to %d", high_o,low_o);
            end
        end else begin
            if(high_o > low_o) begin
                errors++;
                $display("L to G sort failed! %d not less than or equal to %d", low_o,high_o);
            end
        end
    end
endtask

initial begin
    $dumpfile( "bitonic_sorter_pe.fst" );
    $dumpvars;
    $display("Beginning Bitonc Sorter PE Simulation");
    reset();
    $display("Testing L to G sorting");
    for(int i = 0; i < sample_size_lp; i++) begin
        input_values($urandom(), $urandom(), '0);
    end
    $display("Testing G to L sorting");
    for(int i = 0; i < sample_size_lp; i++) begin
        input_values($urandom(), $urandom(), '1);
    end
    $finish;
end

final begin
    $display("Summarizing Bitonc Sorter PE Simulation");
    if(errors) begin
        $error("Failed %d/%d tests", errors, 2 * sample_size_lp);
    end else begin
        $display("Passed all %d tests!", 2 * sample_size_lp);
    end
end

endmodule
