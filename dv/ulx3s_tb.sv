
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
    ulx3s_runner.send_byte(8'h6c);
    ulx3s_runner.send_byte(8'h6c);
    ulx3s_runner.send_byte(8'h6c);
    ulx3s_runner.send_byte(8'h6c);
    ulx3s_runner.send_byte(8'h6c);
    $display( "End simulation." );
    $finish;
end

endmodule
