
rtl/config_pkg.sv

-DNO_ECP5_DEFAULT_ASSIGNMENTS
${YOSYS_DATDIR}/ecp5/cells_sim.v
${YOSYS_DATDIR}/ecp5/cells_bb.v

-I${YOSYS_DATDIR}/ecp5

synth/trellis_ulx3s/build/synth.v
synth/trellis_ulx3s/ulx3s_runner.sv

rtl/top.sv
rtl/sm.sv
rtl/config_pkg.sv

imports/Config-AC.v
imports/W9825G6KH.nc.vp
