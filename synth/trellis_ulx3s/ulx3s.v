// (c)EMARD
// License=BSD

// Module to bypass user input and USB serial to ESP32 WiFi

module ulx3s (
    input wire clk_25mhz,  // Main clock input (25MHz)
    input wire reset_ni,
    input wire ftdi_txd,
    output reg [3:0] led,
);

wire clk;

(* FREQUENCY_PIN_CLKI="25" *)
(* FREQUENCY_PIN_CLKOP="100" *)
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
        .CLKI_DIV(1),               //Refclk divisor
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(6),              //clkout0 divisor
        .CLKOP_CPHASE(2),
        .CLKOP_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(4)   //Feedback Divisor
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

top top_inst (.clk(clk), .rst(!reset_ni), .tx_o(ftdi_txd),.led(led));

endmodule
