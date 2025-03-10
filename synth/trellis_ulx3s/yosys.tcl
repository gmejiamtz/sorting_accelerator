
yosys -import

read_verilog synth/build/rtl.sv2v.v synth/trellis_ulx3s/ulx3s.v

# synth_ecp5 -top ulx3s
synth_ecp5 -top sorter

write_verilog -noexpr -noattr -simple-lhs synth/build/synth.v
write_json synth/build/synth.json