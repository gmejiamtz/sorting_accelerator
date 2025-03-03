module sorter_tb;

sorter_runner sorter_runner();

initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);
    $timeformat( -3, 3, "ms", 0);

    #500;
    sorter_runner.reset_to_start();
    repeat (8) begin
        // Delay some random time
        #50;
        sorter_runner.ready_and_write();
        sorter_runner.delay();
    end

    #1000;
    $display( "End simulation." );
    $finish;
end

endmodule
