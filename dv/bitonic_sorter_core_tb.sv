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
        ready_i = 0;
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
                ready_i = 1;
                @(posedge clk_i);
                if(uut.state_d != error) begin
                    $display("FSM State Update FAILED! Went to state: %b", uut.state_q);
                    result_o = '1;
                end else begin
                    $display("FSM State Update PASSED! Went to state: %b", uut.state_q);
                    wait(uut.state_q == idle);
                    result_o = '0;
                end
            end
            //reset valid and data on negedge of clock
            @(negedge clk_i);
            packet_data_i = '0;
            packet_valid_i = '0;
            ready_i = 0;
        end
    end
endtask

task automatic check_size(input [31:0] packet_i, output logic result_o);
    begin
        @(negedge clk_i);
        ready_i = 0;
        if (uut.state_q != size) begin
            $display("check_size task expects core to be in size state");
            result_o = '1;
        end else begin
            packet_valid_i = '1;
            packet_data_i = packet_i;
            @(posedge clk_i);
            if(uut.size_valid_l) begin
                $display("Expected FSM State Movement: size -> load");
                if(uut.state_d != load) begin
                    $display("FSM State Update FAILED! Went to state: %b", uut.state_d);
                    result_o = '1;
                end else begin
                    $display("FSM State Update PASSED! Went to state: %b", uut.state_q);
                    wait(uut.state_q == load);
                    result_o = '0;
                end
            end else begin
                ready_i = 1;
                @(posedge clk_i);
                $display("Expected FSM State Movement: size -> error");
                if(uut.state_d != error) begin
                    $display("FSM State Update FAILED! Went to state: %b", uut.state_q);
                    result_o = '1;
                end else begin
                    $display("FSM State Update PASSED! Went to state: %b", uut.state_q);
                    wait(uut.state_q == idle);
                    result_o = '0;
                end
            end
            //reset valid and data on negedge of clock
            @(negedge clk_i);
            packet_data_i = '0;
            packet_valid_i = '0;
            ready_i = 0;
        end
    end
endtask

task automatic input_array(output logic result_o);
    begin
        @(negedge clk_i);
        result_o = 0;
        ready_i = 1;
        if (uut.state_q != load) begin
            $display("input_array task expects core to be in load state");
            result_o = '1;
        end else begin
            $display("Loading %d elements!",uut.array_size_q);
            for (int i = 0; i < uut.array_size_q; i++) begin
                wait(uut.packet_ready_o);   //wait until the core can take stuff
                packet_valid_i = '1;
                packet_data_i = $urandom();
                $display("Index %d | Loading %h", i, packet_data_i);
                @(posedge clk_i);
                if(uut.state_d == error) begin
                    $display("Load State is going to timeout!");
                    result_o = '1;
                    @(posedge clk_i);    
                    break;
                end
                @(negedge clk_i);   //negedge on next iteration or exit
                packet_data_i = '0;
                packet_valid_i = '0;
            end
            if(uut.state_d == error) begin
                    $display("Load State is going to timeout!");
                    result_o = '1;
                    @(posedge clk_i);    
                end
            //reset valid and data on negedge of clock
            if(!result_o) begin
                $display("Done loading %d elements", uut.array_size_q);
            end
            ready_i = 0;
            packet_data_i = '0;
            packet_valid_i = '0;

            wait(uut.state_d == sort || uut.state_d == error);
            @(negedge clk_i);
            /* - this block hangs when array is 64
            while(uut.state_d != sort) begin
                @(negedge clk_i);
            end
            */
            /* - this fails when array is 16
            while(uut.state_q != sort) begin
                @(posedge clk_i);
            end
            */
        end
    end
endtask

task automatic run_sorter(output logic result_o);
    begin
        @(negedge clk_i)
        result_o = 0;
        if(uut.state_q != sort) begin
            $display("run_sorter task expects core to be in sort state, it is at state %b", uut.state_q);
            result_o = '1;
        end else begin
            $display("Sorter STATE TBA");
            @(posedge clk_i);
        end
        @(negedge clk_i);
        packet_data_i = '0;
        packet_valid_i = '0;
    end
endtask

task automatic read_transmission(output logic result_o);
    begin
        @(negedge clk_i);
        if(uut.state_q == transmit_left_bracket) begin
            result_o = 0;
            ready_i = 1;
            while(uut.state_q != idle) begin
                if(uut.state_d == error) begin
                    $display("LIKLEY TIMED OUT DURING TRANSMISSION!!!!");
                    result_o = 1;
                    break;
                end
                @(posedge clk_i);
                if(ready_i & valid_o) begin
                    $display("Sent Word: 0x%h", data_o);
                end
            end
            @(negedge clk_i);
            ready_i = 0;
        end else begin
            $display("Core does not have message to transmit!!!");
        end
    end
endtask

initial begin
    $dumpfile( "bitonic_sorter_core.fst" );
    $dumpvars;
    $display("Beginning Bitonc Sorter Core Simulation");
    reset();
    //a correct sequence into the FSM
    $display("Testing an expected working sequence of the core");
    check_header(header_string,task_result);
    if(task_result) begin
        $display("Failed the header check");
        errors++;
        $finish;
    end
    check_size(32'd16,task_result);
    if(task_result) begin
        $display("Failed the size check");
        errors++;
        $finish;
    end
    input_array(task_result);
    if(task_result) begin
        $display("INPUT ARRAY TIMEOUT!!");
        errors++;
        $finish;
    end
    run_sorter(task_result);
    if(task_result) begin
        $display("CORE SORT TIMEOUT!!");
        errors++;
        $finish;
    end
    read_transmission(task_result);
    if(task_result) begin
        $display("READ TRANSMISSION TIMEOUT!!");
        errors++;
        $finish;
    end
    $display("Testing Bad headers");
    wait(uut.state_q == idle);
    check_header(32'h0, task_result);
    if(task_result) begin
        $display("An incorrect header was read as correct, FAILED!");
        errors++;
        $finish;
    end
    $display("Testing Bad Sizes");
    check_header(header_string, task_result);
    if(task_result) begin
        $display("Failed the header check");
        errors++;
        $finish;
    end
    check_size(32'd15, task_result);
    if(task_result) begin
        $display("Failed the size check");
        errors++;
        $finish;
    end
    check_header(header_string, task_result);
    if(task_result) begin
        $display("Failed the header check");
        errors++;
        $finish;
    end
    check_size(32'd33, task_result);
    if(task_result) begin
        $display("Failed the size check");
        errors++;
        $finish;
    end
    $display("Testing Size 64 Array");
    check_header(header_string, task_result);
    if(task_result) begin
        $display("Failed the header check");
        errors++;
        $finish;
    end
    check_size(32'd64, task_result);
    if(task_result) begin
        $display("Failed the size check");
        errors++;
        $finish;
    end
    input_array(task_result);
    if(task_result) begin
        $display("INPUT ARRAY TIMEOUT!!");
        errors++;
        $finish;
    end
    run_sorter(task_result);
    if(task_result) begin
        $display("CORE SORT TIMEOUT!!");
        errors++;
        $finish;
    end
    read_transmission(task_result);
    if(task_result) begin
        $display("READ TRANSMISSION TIMEOUT!!");
        errors++;
        $finish;
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
    //@(posedge clk_i);
end

endmodule
