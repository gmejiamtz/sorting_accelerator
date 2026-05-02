module bitonic_sorter_core_tb
    import config_pkg::*;
    import dv_pkg::*;
;

logic clk_i;
logic resetn_i;

//UUT Signals
logic descend_i;
logic packet_valid_i;
logic packet_ready_o;
logic [31:0] packet_data_i;
logic [31:0] data_o;
logic valid_o;
logic ready_i;

//TB signals
logic task_result;

//period
parameter realtime ClockPeriod = clock_period_p;
integer errors;
//localparam sample_size_lp = sample_size_p;

bitonic_sorter_core uut (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    //Inputs
    .descend_i(descend_i),
    .packet_valid_i(packet_valid_i),
    .packet_data_i(packet_data_i),
    .packet_ready_o(packet_ready_o),
    //Outputs
    .valid_o(valid_o),
    .ready_i(ready_i),
    .data_o(data_o)
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
    packet_data_i = '0;
    packet_valid_i = '0;
    descend_i = '0;
    ready_i = '0;
    task_result = '0;
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

/* All tasks can be used to check each state and move thru the FSM */
task automatic check_header(input [31:0] packet_i, output logic result_o);
    begin
        @(negedge clk_i);
        if (uut.state_q != idle) begin
            $display("check_header task expects core to be in idle state");
            result_o = '1;
        end else begin
            packet_valid_i = '1;
            packet_data_i = packet_i;
            @(posedge clk_i);
            if(packet_data_i == 32'h6c_6f_61_64) begin
                $display("Expected FSM State Movement: idle -> size");
                if(uut.state_d != size) begin
                    $display("FSM State Update FAILED! Went to state: %b", uut.state_d);
                    result_o = '1;
                end else begin
                    $display("FSM State Update PASSED! Went to state: %b", uut.state_q);
                    wait(uut.state_q == size);
                    result_o = '0;
                end
            end else begin
                $display("Expected FSM State Movement: idle -> error");
                if(uut.state_d != error) begin
                    $display("FSM State Update FAILED! Went to state: %b", uut.state_q);
                    result_o = '1;
                end else begin
                    $display("FSM State Update PASSED! Went to state: %b", uut.state_q);
                    wait(uut.state_q == idle);
                    result_o = '0;
                end
            end
            @(negedge clk_i);
            packet_data_i = '0;
            packet_valid_i = '0;
        end
    end
endtask

initial begin
    $dumpfile( "bitonic_sorter_core.fst" );
    $dumpvars;
    $display("Beginning Bitonc Sorter Core Simulation");
    reset();
    check_header(32'h6c_6f_61_64,task_result);
    if(task_result) begin
        $display("Failed the header check");
        errors++;
    end
    $finish;
end

final begin
    $display("Summarizing Bitonc Sorter Core Simulation");
    if(errors) begin
        $error("Failed %d tests", errors);
    end else begin
        $display("Passed with %d errors!", errors);
    end
    @(posedge clk_i);
end

endmodule
