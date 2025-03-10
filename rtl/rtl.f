
-I${BASEJUMP_STL_DIR}/bsg_misc
-I${ALEXFORENCICH_UART_DIR}
-I${VERILOG_AXI_DIR}
-I${UART_AXI_DIR}
-I${PICORV32_DIR}

${BASEJUMP_STL_DIR}/bsg_misc/bsg_counter_up_down.sv
${ALEXFORENCICH_UART_DIR}/rtl/uart_rx.v
${ALEXFORENCICH_UART_DIR}/rtl/uart_tx.v
${ALEXFORENCICH_UART_DIR}/rtl/uart.v
${PICORV32_DIR}/picorv32.v
${VERILOG_AXI_DIR}/rtl/axil_ram.v
${VERILOG_AXI_DIR}/rtl/axil_interconnect.v
${VERILOG_AXI_DIR}/rtl/arbiter.v
${VERILOG_AXI_DIR}/rtl/priority_encoder.v
${UART_AXI_DIR}/rtl/axiluart.v
${UART_AXI_DIR}/rtl/rxuart.v
${UART_AXI_DIR}/rtl/txuart.v
${UART_AXI_DIR}/rtl/ufifo.v
rtl/axil_rom.v
rtl/config_pkg.sv
rtl/pico_to_mems_and_uart.v
rtl/top.sv
