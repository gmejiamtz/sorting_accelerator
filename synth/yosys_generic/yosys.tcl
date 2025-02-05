
yosys -import

read_verilog synth/build/rtl.sv2v.v
read_verilog -sv synth/yosys_generic/ulx3s_sim.sv

prep
opt -full
stat

write_verilog -noexpr -noattr -simple-lhs synth/yosys_generic/build/synth.v
