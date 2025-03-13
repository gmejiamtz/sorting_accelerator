
module ulx3s_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

ulx3s_runner ulx3s_runner ();

initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);
    $timeformat( -3, 3, "ms", 0);
    ulx3s_runner.reset();
    ulx3s_runner.wait_n_cycles(2);
    ulx3s_runner.run_until_ebreak();
    $display("Dumping stdout buffer.");
    ulx3s_runner.dump_stdout_buffer();
    ulx3s_runner.wait_n_cycles(500000);
    $display( "End simulation." );
    $finish;
end

endmodule
