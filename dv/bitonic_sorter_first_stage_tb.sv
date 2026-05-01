module bitonic_sorter_first_stage_tb
    import config_pkg::*;
    import dv_pkg::*;
;

logic clk_i;
logic resetn_i;
logic descend_i;
logic valid_i;
logic [31:0] val_1_i;
logic [31:0] val_2_i;
logic [31:0] val_3_i;
logic [31:0] val_4_i;
logic [31:0] val_5_i;
logic [31:0] val_6_i;
logic [31:0] val_7_i;
logic [31:0] val_8_i;
logic [31:0] val_9_i;
logic [31:0] val_10_i;
logic [31:0] val_11_i;
logic [31:0] val_12_i;
logic [31:0] val_13_i;
logic [31:0] val_14_i;
logic [31:0] val_15_i;
logic [31:0] val_16_i;
logic [31:0] val_1_o;
logic [31:0] val_2_o;
logic [31:0] val_3_o;
logic [31:0] val_4_o;
logic [31:0] val_5_o;
logic [31:0] val_6_o;
logic [31:0] val_7_o;
logic [31:0] val_8_o;
logic [31:0] val_9_o;
logic [31:0] val_10_o;
logic [31:0] val_11_o;
logic [31:0] val_12_o;
logic [31:0] val_13_o;
logic [31:0] val_14_o;
logic [31:0] val_15_o;
logic [31:0] val_16_o;
logic valid_o;
logic descend_o;

//period
parameter realtime ClockPeriod = clock_period_p;
integer errors;
localparam sample_size_lp = sample_size_p;

bitonic_sorter_first_stage uut (
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
    val_1_i = '0;
    val_2_i = '0;
    val_3_i = '0;
    val_4_i = '0;
    val_5_i = '0;
    val_6_i = '0;
    val_7_i = '0;
    val_8_i = '0;
    val_9_i = '0;
    val_10_i = '0;
    val_11_i = '0;
    val_12_i = '0;
    val_13_i = '0;
    val_14_i = '0;
    val_15_i = '0;
    val_16_i = '0;
    errors = 0;
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
        logic [31:0] output_array [16];
        @(negedge clk_i);
        val_1_i = $urandom();
        val_2_i = $urandom();
        val_3_i = $urandom();
        val_4_i = $urandom();
        val_5_i = $urandom();
        val_6_i = $urandom();
        val_7_i = $urandom();
        val_8_i = $urandom();
        val_9_i = $urandom();
        val_10_i = $urandom();
        val_11_i = $urandom();
        val_12_i = $urandom();
        val_13_i = $urandom();
        val_14_i = $urandom();
        val_15_i = $urandom();
        val_16_i = $urandom();
        descend_i = descend;
        valid_i = 1;
        wait(valid_o == 1);
        @(posedge clk_i);
        output_array[0] =  val_1_o;
        output_array[1] =  val_2_o;
        output_array[2] =  val_3_o;
        output_array[3] =  val_4_o;
        output_array[4] =  val_5_o;
        output_array[5] =  val_6_o;
        output_array[6] =  val_7_o;
        output_array[7] =  val_8_o;
        output_array[8] =  val_9_o;
        output_array[9] =  val_10_o;
        output_array[10] =  val_11_o;
        output_array[11] =  val_12_o;
        output_array[12] =  val_13_o;
        output_array[13] =  val_14_o;
        output_array[14] =  val_15_o;
        output_array[15] =  val_16_o;
        //logic 
        if(descend_i) begin
            for(int i = 0; i < 16; i=2+i) begin
                if(output_array[i] < output_array[i+1]) begin
                    errors++;
                    $display("Bitonic Sorter %d G to L sort failed! %d not greater than or equal to %d", i/2, output_array[i], output_array[i+1]);
                end
            end
        end else begin
            for(int i = 0; i < 16; i=2+i) begin
                if(output_array[i] > output_array[i+1]) begin
                    errors++;
                    $display("Bitonic Sorter %d L to G sort failed! %d not lesser than or equal to %d", i/2, output_array[i], output_array[i+1]);
                end
            end
        end
    end
    valid_i = 0;
    wait(valid_o == 0);
    @(negedge clk_i);
endtask

initial begin
    $dumpfile( "bitonic_sorter_first_stage.fst" );
    $dumpvars;
    $display("Beginning Bitonc Sorter First Stage Simulation");
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
    $display("Summarizing Bitonc Sorter First Stage Simulation");
    if(errors) begin
        $error("Failed %d/%d tests", errors, 2 * sample_size_lp);
    end else begin
        $display("Passed all %d tests!", 2 * sample_size_lp);
    end
end

endmodule
