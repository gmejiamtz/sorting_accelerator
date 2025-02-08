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

// TX/RX passthru logic
always @(*) begin
    ftdi_rxd = wifi_txd;
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
always @(*) begin
    led[7] = wifi_gpio5;
    led[6] = S_prog_out[1]; // Green LED when ESP32 disabled
    led[5] = ~R_prog_release[17]; // Indicate ESP32 programming start
end

// Programming release counter
always @(posedge clk_25mhz) begin
    R_prog_in <= S_prog_in;
    if (S_prog_out == 2'b01 && R_prog_in == 2'b11) begin
        R_prog_release <= 0;
    end else if (R_prog_release[17] == 0) begin
        R_prog_release <= R_prog_release + 1;
    end
end

// Multiboot selection via button press
always @(posedge clk_25mhz) begin
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

top top_inst (.clk(clk), .rst(!reset_ni), .rx_i(ftdi_rxd), .tx_o(ftdi_txd));

assign led[2] = !ftdi_rxd;
assign led[4] = !sw[0];
assign led[5] = 1;
// assign led[2] = !btn[0];
// assign wifi_en = 1;
assign user_programn = ~R_progn[7];

endmodule
