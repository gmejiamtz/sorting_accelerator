
dv/dv_pkg.sv

dv/ulx3s_tb.sv
dv/bitonic_sorter_pe_tb.sv
dv/bitonic_sorter_first_stage_tb.sv
dv/bitonic_sorter_second_stage_tb.sv
dv/bitonic_sorter_merger_4_elem_tb.sv
dv/bitonic_sorter_merger_8_elem_tb.sv

--timing
-j 0
-Wall
--assert
--trace-fst
--trace-structs
--main-top-name "-"

// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique

-Werror-IMPLICIT
-Werror-USERERROR
-Werror-LATCH
-Wno-WIDTHTRUNC
-Wno-UNUSEDSIGNAL