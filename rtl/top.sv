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
localparam [31:0] STACKADDR = 32'h 0000_2000;

//picorv32 instruction parameters
localparam DEPTH_P = 16; //only use 13 bits tho
localparam WIDTH_P = 32;
localparam instruction_memory_file = "/workspaces/sorting_accelerator/misc/firmware.hex";

//picorv32 wires
wire        mem_axi_awvalid;
wire        mem_axi_awready;
wire [31:0] mem_axi_awaddr;
wire [ 2:0] mem_axi_awprot;

wire        mem_axi_wvalid;
wire        mem_axi_wready;
wire [31:0] mem_axi_wdata;
wire [ 3:0] mem_axi_wstrb;

wire        mem_axi_bvalid;
wire        mem_axi_bready;

wire        mem_axi_arvalid;
wire        mem_axi_arready;
wire [31:0] mem_axi_araddr;
wire [ 2:0] mem_axi_arprot;

wire        mem_axi_rvalid;
wire        mem_axi_rready;
wire [31:0] mem_axi_rdata;
wire trap;

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


picorv32_axi #(
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
	) picorv32_axi_core (
		.clk            (clk_i),
		.resetn         (!reset_i),
		.trap           (trap),
		.mem_axi_awvalid(mem_axi_awvalid),
		.mem_axi_awready(mem_axi_awready),
		.mem_axi_awaddr (mem_axi_awaddr ),
		.mem_axi_awprot (mem_axi_awprot ),
		.mem_axi_wvalid (mem_axi_wvalid ),
		.mem_axi_wready (mem_axi_wready ),
		.mem_axi_wdata  (mem_axi_wdata  ),
		.mem_axi_wstrb  (mem_axi_wstrb  ),
		.mem_axi_bvalid (mem_axi_bvalid ),
		.mem_axi_bready (mem_axi_bready ),
		.mem_axi_arvalid(mem_axi_arvalid),
		.mem_axi_arready(mem_axi_arready),
		.mem_axi_araddr (mem_axi_araddr ),
		.mem_axi_arprot (mem_axi_arprot ),
		.mem_axi_rvalid (mem_axi_rvalid ),
		.mem_axi_rready (mem_axi_rready ),
		.mem_axi_rdata  (mem_axi_rdata  ),
		.irq            (irq            ),
`ifdef RISCV_FORMAL
		.rvfi_valid     (rvfi_valid     ),
		.rvfi_order     (rvfi_order     ),
		.rvfi_insn      (rvfi_insn      ),
		.rvfi_trap      (rvfi_trap      ),
		.rvfi_halt      (rvfi_halt      ),
		.rvfi_intr      (rvfi_intr      ),
		.rvfi_rs1_addr  (rvfi_rs1_addr  ),
		.rvfi_rs2_addr  (rvfi_rs2_addr  ),
		.rvfi_rs1_rdata (rvfi_rs1_rdata ),
		.rvfi_rs2_rdata (rvfi_rs2_rdata ),
		.rvfi_rd_addr   (rvfi_rd_addr   ),
		.rvfi_rd_wdata  (rvfi_rd_wdata  ),
		.rvfi_pc_rdata  (rvfi_pc_rdata  ),
		.rvfi_pc_wdata  (rvfi_pc_wdata  ),
		.rvfi_mem_addr  (rvfi_mem_addr  ),
		.rvfi_mem_rmask (rvfi_mem_rmask ),
		.rvfi_mem_wmask (rvfi_mem_wmask ),
		.rvfi_mem_rdata (rvfi_mem_rdata ),
		.rvfi_mem_wdata (rvfi_mem_wdata ),
`endif
		.trace_valid    (trace_valid    ),
		.trace_data     (trace_data     )
	);

axil_ram #
(
    .DATA_WIDTH(WIDTH_P),
    .ADDR_WIDTH(DEPTH_P),
	.filename_p(instruction_memory_file)
) memory_inst (
    .clk(clk_i),
    .rst(reset_i),
    .s_axil_awaddr(mem_axi_awaddr),
    .s_axil_awprot(mem_axi_awprot),
    .s_axil_awvalid(mem_axi_awvalid),
	.s_axil_awready(mem_axi_awready),
    .s_axil_wdata(mem_axi_wdata),
    .s_axil_wstrb(mem_axi_wstrb),
    .s_axil_wvalid(mem_axi_wvalid),
    .s_axil_wready(mem_axi_wready),
	.s_axil_bresp(),	//unused
    .s_axil_bvalid(mem_axi_bvalid),
    .s_axil_bready(mem_axi_bready),
    .s_axil_araddr(mem_axi_araddr),
    .s_axil_arprot(mem_axi_arprot),
    .s_axil_arvalid(mem_axi_arvalid),
    .s_axil_arready(mem_axi_arready),
    .s_axil_rdata(mem_axi_rdata),
    .s_axil_rresp(),		//unused
    .s_axil_rvalid(mem_axi_rvalid),
	.s_axil_rready(mem_axi_rready)
);
endmodule
