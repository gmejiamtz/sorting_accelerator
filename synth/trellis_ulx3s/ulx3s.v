// (c)EMARD
// License=BSD

// Module to bypass user input and USB serial to ESP32 WiFi

module ulx3s (
    input wire clk_25mhz,  // Main clock input (25MHz)
    input wire reset_ni,

    // UART0 (FTDI USB slave serial)
    output reg ftdi_rxd,
    input wire ftdi_txd,
    
    // FTDI additional signaling
    inout wire ftdi_ndtr,
    // inout wire ftdi_ndsr,
    inout wire ftdi_nrts,
    inout wire ftdi_txden,

    // UART1 (WiFi serial)
    output reg wifi_rxd,
    input wire wifi_txd,

    // WiFi additional signaling
    inout wire wifi_en,
    inout wire wifi_gpio0,
    // inout wire wifi_gpio2,
    inout wire wifi_gpio5,
    inout wire wifi_gpio16,
    inout wire wifi_gpio17,

    // Onboard blinky
    output reg [7:0] led,
    input wire [6:1] btn,
    input wire [3:0] sw,
    output reg oled_csn,
    output reg oled_clk,
    output reg oled_mosi,
    output reg oled_dc,
    output reg oled_resn,

    // GPIO (some shared with WiFi and ADC)
    inout wire [27:0] gp,
    inout wire [27:0] gn,

    // SHUTDOWN: logic '1' here will shut down power on PCB >= v1.7.5
    output reg shutdown,

    // Audio jack 3.5mm
    inout wire [3:0] audio_l,
    inout wire [3:0] audio_r,
    inout wire [3:0] audio_v,

    // Flash ROM (SPI0)
    output reg flash_holdn,
    output reg flash_wpn,

    // SD card (SPI1)
    inout wire [3:0] sd_d,
    input wire sd_cmd,  // WiFi GPIO15
    input wire sd_clk,  // WiFi GPIO14
    input wire sd_cdn,
    input wire sd_wp,

    output reg user_programn // setting this low will skip to next multiboot image
);

// Internal registers
reg [1:0] S_prog_in, R_prog_in, S_prog_out;
reg [7:0] R_spi_miso;
reg S_oled_csn;
reg [17:0] R_prog_release; // Timeout counter
reg [7:0] R_progn;

assign led[5] = sw[0];
assign led[4] = !sw[0];

// TX/RX passthru logic
always @(*) begin
    if (sw[0] == 1) begin
        ftdi_rxd = wifi_txd;
        wifi_rxd = ftdi_txd;
    end else begin
        ftdi_rxd = wifi_gpio17;
        wifi_rxd = 1;
    end
    // wifi_gpio16 = (sw[0] == 1) ? 1 : ftdi_txd;
end

// Programming logic
always @(*) begin
    S_prog_in = {ftdi_ndtr, ftdi_nrts};
    case (S_prog_in)
        2'b10: S_prog_out = 2'b01;
        2'b01: S_prog_out = 2'b10;
        default: S_prog_out = 2'b11;
    endcase

    wifi_en = S_prog_out[1];
    wifi_gpio0 = S_prog_out[0] & btn[0]; // Hold BTN0 to keep gpio0 LOW
    sd_d[0] = (R_prog_release[17] == 0) ? S_prog_out[0] : 1'bz;
end

// OLED connection
always @(*) begin
    S_oled_csn = 1;
    oled_csn = S_oled_csn;
    oled_clk = sd_clk;
    oled_mosi = sd_cmd;
    oled_dc = 1;
    oled_resn = gp[11];
end

// LED control signals
// always @(*) begin
//     led[7] = wifi_gpio5;
//     led[6] = S_prog_out[1]; // Green LED when ESP32 disabled
//     led[5] = ~R_prog_release[17]; // Indicate ESP32 programming start
// end

// Programming release counter
always @(posedge clk) begin
    R_prog_in <= S_prog_in;
    if (S_prog_out == 2'b01 && R_prog_in == 2'b11) begin
        R_prog_release <= 0;
    end else if (R_prog_release[17] == 0) begin
        R_prog_release <= R_prog_release + 1;
    end
end

// Multiboot selection via button press
always @(posedge clk) begin
    if (btn[0] == 0 && btn[1] == 1) begin
        R_progn <= R_progn + 1;
    end else begin
        R_progn <= 0;
    end
end

wire clk;

(* FREQUENCY_PIN_CLKI="25" *)
(* FREQUENCY_PIN_CLKOP="32.256" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(7),               //Refclk divisor
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(19),              //clkout0 divisor
        .CLKOP_CPHASE(2),
        .CLKOP_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(9)   //Feedback Divisor
    ) pll (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clk_25mhz),
        .CLKOP(clk),
        .CLKFB(clk),
        .CLKINTFB(),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);

top top_inst (.clk(clk), .rst(!reset_ni), .rx_i(wifi_txd), .tx_o());

// reg [31:0] irq;
// wire trap, mem_valid, mem_instr, mem_ready;
// wire [31:0] mem_addr, mem_wdata, mem_rdata, mem_la_addr, mem_la_wdata, pcpi_insn, pcpi_rs1, pcpi_rs2, eoi;
// wire [3:0] mem_wstrb, mem_la_wstrb;
// wire mem_la_read, mem_la_write, pcpi_valid, pcpi_wr, pcpi_wait, pcpi_ready;
// wire [31:0] pcpi_rd;

// // Instantiate the PicoRV32 RISC-V Core
// picorv32 #(
//     .ENABLE_COUNTERS(1),
//     .ENABLE_COUNTERS64(1),
//     .ENABLE_REGS_16_31(1),
//     .ENABLE_REGS_DUALPORT(1),
//     .LATCHED_MEM_RDATA(0),
//     .TWO_STAGE_SHIFT(1),
//     .BARREL_SHIFTER(0),
//     .TWO_CYCLE_COMPARE(0),
//     .TWO_CYCLE_ALU(0),
//     .COMPRESSED_ISA(0),
//     .CATCH_MISALIGN(1),
//     .CATCH_ILLINSN(1),
//     .ENABLE_PCPI(0),
//     .ENABLE_MUL(0),
//     .ENABLE_FAST_MUL(0),
//     .ENABLE_DIV(0),
//     .ENABLE_IRQ(0),
//     .ENABLE_IRQ_QREGS(1),
//     .ENABLE_IRQ_TIMER(1),
//     .ENABLE_TRACE(0),
//     .REGS_INIT_ZERO(0),
//     .MASKED_IRQ(32'h00000000),
//     .LATCHED_IRQ(32'hffffffff),
//     .PROGADDR_RESET(32'h00000000),
//     .PROGADDR_IRQ(32'h00000010),
//     .STACKADDR(32'hffffffff)
// ) pico_inst (
//     .clk(clk),
//     .resetn(!reset_ni),
//     .trap(trap),

//     .mem_valid(mem_valid),
//     .mem_instr(mem_instr),
//     .mem_ready(mem_ready),

//     .mem_addr(mem_addr),
//     .mem_wdata(mem_wdata),
//     .mem_wstrb(mem_wstrb),
//     .mem_rdata(mem_rdata),

//     .mem_la_read(mem_la_read),
//     .mem_la_write(mem_la_write),
//     .mem_la_addr(mem_la_addr),
//     .mem_la_wdata(mem_la_wdata),
//     .mem_la_wstrb(mem_la_wstrb),

//     .pcpi_valid(pcpi_valid),
//     .pcpi_insn(pcpi_insn),
//     .pcpi_rs1(pcpi_rs1),
//     .pcpi_rs2(pcpi_rs2),
//     .pcpi_wr(pcpi_wr),
//     .pcpi_rd(pcpi_rd),
//     .pcpi_wait(pcpi_wait),
//     .pcpi_ready(pcpi_ready),

//     .irq(irq),
//     .eoi(eoi),

// `ifdef RISCV_FORMAL
//     .rvfi_valid(rvfi_valid),
//     .rvfi_order(rvfi_order),
//     .rvfi_insn(rvfi_insn),
//     .rvfi_trap(rvfi_trap),
//     .rvfi_halt(rvfi_halt),
//     .rvfi_intr(rvfi_intr),
//     .rvfi_mode(rvfi_mode),
//     .rvfi_ixl(rvfi_ixl),
//     .rvfi_rs1_addr(rvfi_rs1_addr),
//     .rvfi_rs2_addr(rvfi_rs2_addr),
//     .rvfi_rs1_rdata(rvfi_rs1_rdata),
//     .rvfi_rs2_rdata(rvfi_rs2_rdata),
//     .rvfi_rd_addr(rvfi_rd_addr),
//     .rvfi_rd_wdata(rvfi_rd_wdata),
//     .rvfi_pc_rdata(rvfi_pc_rdata),
//     .rvfi_pc_wdata(rvfi_pc_wdata),
//     .rvfi_mem_addr(rvfi_mem_addr),
//     .rvfi_mem_rmask(rvfi_mem_rmask),
//     .rvfi_mem_wmask(rvfi_mem_wmask),
//     .rvfi_mem_rdata(rvfi_mem_rdata),
//     .rvfi_mem_wdata(rvfi_mem_wdata),
//     .rvfi_csr_mcycle_rmask(rvfi_csr_mcycle_rmask),
//     .rvfi_csr_mcycle_wmask(rvfi_csr_mcycle_wmask),
//     .rvfi_csr_mcycle_rdata(rvfi_csr_mcycle_rdata),
//     .rvfi_csr_mcycle_wdata(rvfi_csr_mcycle_wdata),
//     .rvfi_csr_minstret_rmask(rvfi_csr_minstret_rmask),
//     .rvfi_csr_minstret_wmask(rvfi_csr_minstret_wmask),
//     .rvfi_csr_minstret_rdata(rvfi_csr_minstret_rdata),
//     .rvfi_csr_minstret_wdata(rvfi_csr_minstret_wdata),
// `endif

//     .trace_valid(trace_valid),
//     .trace_data(trace_data)
// );


assign led[2] = !ftdi_rxd;
// assign led[5] = !wifi_txd;
// assign led[2] = !btn[0];
// assign wifi_en = 1;
assign user_programn = ~R_progn[7];

endmodule
