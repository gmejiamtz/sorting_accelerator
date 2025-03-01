module top(
    input clk_i,
    input reset_i,
    output tx_o
);

//picorv32 core parameters
localparam [0:0] ENABLE_COUNTERS = 1;
localparam [0:0] ENABLE_COUNTERS64 = 1;
localparam [0:0] ENABLE_REGS_16_31 = 1;
localparam [0:0] ENABLE_REGS_DUALPORT = 1;
localparam [0:0] LATCHED_MEM_RDATA = 0;
localparam [0:0] TWO_STAGE_SHIFT = 1;
localparam [0:0] BARREL_SHIFTER = 0;
localparam [0:0] TWO_CYCLE_COMPARE = 0;
localparam [0:0] TWO_CYCLE_ALU = 0;
localparam [0:0] COMPRESSED_ISA = 0;
localparam [0:0] CATCH_MISALIGN = 1;
localparam [0:0] CATCH_ILLINSN = 1;
localparam [0:0] ENABLE_PCPI = 0;		//for sorter and uart out
localparam [0:0] ENABLE_MUL = 0;
localparam [0:0] ENABLE_FAST_MUL = 0;
localparam [0:0] ENABLE_DIV = 0;
localparam [0:0] ENABLE_IRQ = 0;
localparam [0:0] ENABLE_IRQ_QREGS = 0;
localparam [0:0] ENABLE_IRQ_TIMER = 0;
localparam [0:0] ENABLE_TRACE = 0;
localparam [0:0] REGS_INIT_ZERO = 0;
localparam [31:0] MASKED_IRQ = 32'h 0000_0000;
localparam [31:0] LATCHED_IRQ = 32'h ffff_ffff;
localparam [31:0] PROGADDR_RESET = 32'h 0000_0000;
localparam [31:0] PROGADDR_IRQ = 32'h 0000_0000;
localparam [31:0] STACKADDR = 32'h 0000_1000;

//picorv32 instruction parameters
localparam DEPTH_P = 8192;
localparam WIDTH_P = 32;
localparam instruction_memory_file = "/workspaces/sorting_accelerator/misc/firmware.hex";

//picorv32 wires
wire        mem_valid;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [ 3:0] mem_wstrb;
wire        mem_instr;
wire        mem_ready;
wire [31:0] mem_rdata;
wire trap;
assign mem_ready = 1'b1 ; //unsure where this should be made if at all

//picorc32 co processor wires
wire        pcpi_valid;
wire [31:0] pcpi_insn;
wire [31:0] pcpi_rs1;
wire [31:0] pcpi_rs2;
wire         pcpi_wr;
wire  [31:0] pcpi_rd;
wire         pcpi_wait;
wire         pcpi_ready;

//picorv32 interrupt bus this is unused
wire  [31:0] irq;
wire [31:0] eoi;

//trace interface also unused
wire trace_valid;
wire [35:0] trace_data;


picorv32 #(
		.ENABLE_COUNTERS     (ENABLE_COUNTERS     ),
		.ENABLE_COUNTERS64   (ENABLE_COUNTERS64   ),
		.ENABLE_REGS_16_31   (ENABLE_REGS_16_31   ),
		.ENABLE_REGS_DUALPORT(ENABLE_REGS_DUALPORT),
		.TWO_STAGE_SHIFT     (TWO_STAGE_SHIFT     ),
		.BARREL_SHIFTER      (BARREL_SHIFTER      ),
		.TWO_CYCLE_COMPARE   (TWO_CYCLE_COMPARE   ),
		.TWO_CYCLE_ALU       (TWO_CYCLE_ALU       ),
		.COMPRESSED_ISA      (COMPRESSED_ISA      ),
		.CATCH_MISALIGN      (CATCH_MISALIGN      ),
		.CATCH_ILLINSN       (CATCH_ILLINSN       ),
		.ENABLE_PCPI         (ENABLE_PCPI         ),
		.ENABLE_MUL          (ENABLE_MUL          ),
		.ENABLE_FAST_MUL     (ENABLE_FAST_MUL     ),
		.ENABLE_DIV          (ENABLE_DIV          ),
		.ENABLE_IRQ          (ENABLE_IRQ          ),
		.ENABLE_IRQ_QREGS    (ENABLE_IRQ_QREGS    ),
		.ENABLE_IRQ_TIMER    (ENABLE_IRQ_TIMER    ),
		.ENABLE_TRACE        (ENABLE_TRACE        ),
		.REGS_INIT_ZERO      (REGS_INIT_ZERO      ),
		.MASKED_IRQ          (MASKED_IRQ          ),
		.LATCHED_IRQ         (LATCHED_IRQ         ),
		.PROGADDR_RESET      (PROGADDR_RESET      ),
		.PROGADDR_IRQ        (PROGADDR_IRQ        ),
		.STACKADDR           (STACKADDR           )
	) picorv32_core (
		.clk      (clk_i   ),
		.resetn   (!reset_i),
		.trap     (trap  ),
		//mem interface
		.mem_valid(mem_valid),
		.mem_addr (mem_addr ),
		.mem_wdata(mem_wdata),
		.mem_wstrb(mem_wstrb),
		.mem_instr(mem_instr),
		.mem_ready(mem_ready),	//unsure of this signal since ram doesn't produce valid out so assuming just 1
		.mem_rdata(mem_rdata),
		//pcpi interface
		.pcpi_valid(pcpi_valid),
		.pcpi_insn (pcpi_insn ),
		.pcpi_rs1  (pcpi_rs1  ),
		.pcpi_rs2  (pcpi_rs2  ),
		.pcpi_wr   (pcpi_wr   ),
		.pcpi_rd   (pcpi_rd   ),
		.pcpi_wait (pcpi_wait ),
		.pcpi_ready(pcpi_ready),
		//interrupt interface
		.irq(irq),
		.eoi(eoi),

`ifdef RISCV_FORMAL
		.rvfi_valid    (rvfi_valid    ),
		.rvfi_order    (rvfi_order    ),
		.rvfi_insn     (rvfi_insn     ),
		.rvfi_trap     (rvfi_trap     ),
		.rvfi_halt     (rvfi_halt     ),
		.rvfi_intr     (rvfi_intr     ),
		.rvfi_rs1_addr (rvfi_rs1_addr ),
		.rvfi_rs2_addr (rvfi_rs2_addr ),
		.rvfi_rs1_rdata(rvfi_rs1_rdata),
		.rvfi_rs2_rdata(rvfi_rs2_rdata),
		.rvfi_rd_addr  (rvfi_rd_addr  ),
		.rvfi_rd_wdata (rvfi_rd_wdata ),
		.rvfi_pc_rdata (rvfi_pc_rdata ),
		.rvfi_pc_wdata (rvfi_pc_wdata ),
		.rvfi_mem_addr (rvfi_mem_addr ),
		.rvfi_mem_rmask(rvfi_mem_rmask),
		.rvfi_mem_wmask(rvfi_mem_wmask),
		.rvfi_mem_rdata(rvfi_mem_rdata),
		.rvfi_mem_wdata(rvfi_mem_wdata),
`endif
		.trace_valid(trace_valid),
		.trace_data (trace_data)
);

ram_1r1w_sync #(.width_p(WIDTH_P),
    .depth_p(DEPTH_P),
	.filename_p(instruction_memory_file))
	instruction_memory_inst (
		.clk_i(clk_i),
		.reset_i(1'b0),
		.wr_valid_i(mem_valid & ~mem_instr & |mem_wstrb),
		.wr_data_i(mem_wdata),
		.wr_addr_i(({1'b1,mem_addr[11:0]} & {13{(|mem_wstrb)}}) >> 2),
		.rd_addr_i(({~mem_instr,mem_addr[11:0]} & {13{~(|mem_wstrb)}}) >> 2),
		.rd_data_o(mem_rdata)
		//,.rd_data_valid(mem_ready)	//is this necessary cuz docs say it can just be tied high
);
/*
uart_tx #(.DATA_WIDTH(8)) uart_tx_inst (
    .clk(clk_i),
    .rst(reset_i),
    .s_axis_tdata(rx_data_out), // input
    .s_axis_tvalid(rx_valid_out), // input
    .s_axis_tready(tx_ready), // output
    .txd(tx_o),
    .busy(),
    .prescale(16'd35)
);
*/
endmodule
