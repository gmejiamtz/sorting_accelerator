
TOP := ulx3s_tb

export BASEJUMP_STL_DIR := $(abspath third_party/basejump_stl)
export ALEXFORENCICH_UART_DIR := $(abspath third_party/alexforencich_uart)
export YOSYS_DATDIR := $(shell yosys-config --datdir)

RTL := $(shell \
 BASEJUMP_STL_DIR=$(BASEJUMP_STL_DIR) \
 ALEXFORENCICH_UART_DIR=$(ALEXFORENCICH_UART_DIR) \
 python3 misc/convert_filelist.py Makefile rtl/rtl.f \
)

SV2V_ARGS := $(shell \
 BASEJUMP_STL_DIR=$(BASEJUMP_STL_DIR) \
 ALEXFORENCICH_UART_DIR=$(ALEXFORENCICH_UART_DIR) \
 python3 misc/convert_filelist.py sv2v rtl/rtl.f \
)

.PHONY: lint sim gls trellis_ulx3s_gls trellis_ulx3s_program trellis_ulx3s_flash clean

lint:
	verilator lint/verilator.vlt -f rtl/rtl.f -f dv/dv.f --lint-only --top top

sim:
	verilator lint/verilator.vlt --Mdir ${TOP}_$@_dir -f rtl/rtl.f -f dv/pre_synth.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/build/rtl.sv2v.v: ${RTL} rtl/rtl.f
	mkdir -p $(dir $@)
	sv2v ${SV2V_ARGS} -w $@ -DSYNTHESIS

gls: synth/yosys_generic/build/synth.v
	verilator lint/verilator.vlt --Mdir ${TOP}_$@_dir -f synth/yosys_generic/gls.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/yosys_generic/build/synth.v: synth/build/rtl.sv2v.v synth/yosys_generic/yosys.tcl
	mkdir -p $(dir $@)
	yosys -p 'tcl synth/yosys_generic/yosys.tcl synth/build/rtl.sv2v.v' -l synth/yosys_generic/build/yosys.log

trellis_ulx3s_gls: synth/trellis_ulx3s/build/synth.v
	verilator lint/verilator.vlt --Mdir ${TOP}_$@_dir -f synth/trellis_ulx3s/gls.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/trellis_ulx3s/build/synth.v synth/trellis_ulx3s/build/synth.json: synth/build/rtl.sv2v.v synth/trellis_ulx3s/ulx3s.v synth/trellis_ulx3s/yosys.tcl
	mkdir -p $(dir $@)
	yosys -p 'tcl synth/trellis_ulx3s/yosys.tcl' -l synth/trellis_ulx3s/build/yosys.log

synth/trellis_ulx3s/build/ulx3s.config: synth/trellis_ulx3s/build/synth.json synth/trellis_ulx3s/nextpnr.py synth/trellis_ulx3s/nextpnr_ecp5.lpf
	nextpnr-ecp5 --12k --json synth/trellis_ulx3s/build/synth.json \
	 --pre-pack synth/trellis_ulx3s/nextpnr.py \
	 --package CABGA381 \
	 --lpf synth/trellis_ulx3s/nextpnr_ecp5.lpf \
	 --report synth/trellis_ulx3s/build/timing.json \
	 --placed-svg synth/trellis_ulx3s/build/placement.svg \
	 --routed-svg synth/trellis_ulx3s/build/route.svg \
	 --textcfg $@

%.bit: %.config
	ecppack $< $@

trellis_ulx3s_program: synth/trellis_ulx3s/build/ulx3s.bit
	sudo $(shell which fujprog) $<

trellis_ulx3s_flash: synth/trellis_ulx3s/build/ulx3s.bit
	sudo $(shell which fujprog) $<

clean:
	rm -rf \
	 *.memh *.memb \
	 *sim_dir *gls_dir \
	 dump.vcd dump.fst \
	 synth/build \
	 synth/yosys_generic/build \
	 synth/trellis_ulx3s/build
