module top(
    input clk_i,
    input reset_i,
    output tx_o,
	output [7:0] led
);

//picorv32 core parameters
localparam [0:0] ENABLE_COUNTERS = 1;
localparam [0:0] ENABLE_COUNTERS64 = 1;
localparam [0:0] ENABLE_REGS_16_31 = 1;
localparam [0:0] ENABLE_REGS_DUALPORT = 1;
localparam [0:0] TWO_STAGE_SHIFT = 1;
localparam [0:0] BARREL_SHIFTER = 0;
localparam [0:0] TWO_CYCLE_COMPARE = 0;
localparam [0:0] TWO_CYCLE_ALU = 0;
localparam [0:0] COMPRESSED_ISA = 0;
localparam [0:0] CATCH_MISALIGN = 1;
localparam [0:0] CATCH_ILLINSN = 1;
localparam [0:0] ENABLE_PCPI = 1;		//for sorter and uart out
localparam [0:0] ENABLE_MUL = 1;
localparam [0:0] ENABLE_FAST_MUL = 0;
localparam [0:0] ENABLE_DIV = 1;
localparam [0:0] ENABLE_IRQ = 0;
localparam [0:0] ENABLE_IRQ_QREGS = 0;
localparam [0:0] ENABLE_IRQ_TIMER = 0;
localparam [0:0] ENABLE_TRACE = 0;
localparam [0:0] REGS_INIT_ZERO = 0;
localparam [31:0] MASKED_IRQ = 32'h 0000_0000;
localparam [31:0] LATCHED_IRQ = 32'h ffff_ffff;
localparam [31:0] PROGADDR_RESET = 32'h 0000_0000;
localparam [31:0] PROGADDR_IRQ = 32'h 0000_0000;
localparam [31:0] STACKADDR = 32'h 0100_5000;

//picorv32 instruction parameters
localparam DEPTH_P = 16; //only use 13 bits tho
localparam WIDTH_P = 32;
localparam instruction_memory_file = "/workspaces/sorting_accelerator/third_party/picorv32i_programs/bubble_sort/firmware/firmware.hex";

//interconnect addresses
localparam ROM_ADDRESS = 32'h0;
localparam RAM_ADDRESS = 32'h0100_0000;
localparam SORT_ADDRESS = 32'h1000_0000;
localparam UART_ADDRESS = 32'h1100_0000;

//sorting instruction opcode and func7
localparam SORT_INST_OPCODE = 7'b0110011;
localparam SORT_INST_FUNCT7 = 7'b1000000;

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
wire [1:0]	mem_axi_bresp;
wire [1:0]	mem_axi_rresp;
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

//pcpi inst decode logic
wire [6:0] pcpi_insn_opcode;
wire [6:0] pcpi_insn_func7;

//picorv32 interrupt bus this is unused
wire  [31:0] irq;
wire [31:0] eoi;

//trace interface also unused
wire trace_valid;
wire [35:0] trace_data;

//rom axi wires
wire        rom_axi_awvalid;
wire        rom_axi_awready;
wire [31:0] rom_axi_awaddr;
wire [ 2:0] rom_axi_awprot;

wire        rom_axi_wvalid;
wire        rom_axi_wready;
wire [31:0] rom_axi_wdata;
wire [ 3:0] rom_axi_wstrb;

wire        rom_axi_bvalid;
wire        rom_axi_bready;

wire        rom_axi_arvalid;
wire        rom_axi_arready;
wire [31:0] rom_axi_araddr;
wire [ 2:0] rom_axi_arprot;

wire        rom_axi_rvalid;
wire        rom_axi_rready;
wire [31:0] rom_axi_rdata;
wire [1:0]	rom_axi_bresp;
wire [1:0]	rom_axi_rresp;

//ram axi wires
wire        ram_axi_awvalid;
wire        ram_axi_awready;
wire [31:0] ram_axi_awaddr;
wire [ 2:0] ram_axi_awprot;

wire        ram_axi_wvalid;
wire        ram_axi_wready;
wire [31:0] ram_axi_wdata;
wire [ 3:0] ram_axi_wstrb;

wire        ram_axi_bvalid;
wire        ram_axi_bready;

wire        ram_axi_arvalid;
wire        ram_axi_arready;
wire [31:0] ram_axi_araddr;
wire [ 2:0] ram_axi_arprot;

wire        ram_axi_rvalid;
wire        ram_axi_rready;
wire [31:0] ram_axi_rdata;
wire [1:0]	ram_axi_bresp;
wire [1:0]	ram_axi_rresp;

//pico to sorter mem axi wires
wire        cpu_to_sort_ram_axi_awvalid;
wire        cpu_to_sort_ram_axi_awready;
wire [31:0] cpu_to_sort_ram_axi_awaddr;
wire [ 2:0] cpu_to_sort_ram_axi_awprot;

wire        cpu_to_sort_ram_axi_wvalid;
wire        cpu_to_sort_ram_axi_wready;
wire [31:0] cpu_to_sort_ram_axi_wdata;
wire [ 3:0] cpu_to_sort_ram_axi_wstrb;

wire        cpu_to_sort_ram_axi_bvalid;
wire        cpu_to_sort_ram_axi_bready;

wire        cpu_to_sort_ram_axi_arvalid;
wire        cpu_to_sort_ram_axi_arready;
wire [31:0] cpu_to_sort_ram_axi_araddr;
wire [ 2:0] cpu_to_sort_ram_axi_arprot;

wire        cpu_to_sort_ram_axi_rvalid;
wire        cpu_to_sort_ram_axi_rready;
wire [31:0] cpu_to_sort_ram_axi_rdata;
wire [1:0]	cpu_to_sort_ram_axi_bresp;
wire [1:0]	cpu_to_sort_ram_axi_rresp;

//uart axi wires
wire        uart_axi_awvalid;
wire        uart_axi_awready;
wire [31:0] uart_axi_awaddr;
wire [ 2:0] uart_axi_awprot;

wire        uart_axi_wvalid;
wire        uart_axi_wready;
wire [31:0] uart_axi_wdata;
wire [ 3:0] uart_axi_wstrb;

wire        uart_axi_bvalid;
wire        uart_axi_bready;

wire        uart_axi_arvalid;
wire        uart_axi_arready;
wire [31:0] uart_axi_araddr;
wire [ 2:0] uart_axi_arprot;

wire        uart_axi_rvalid;
wire        uart_axi_rready;
wire [31:0] uart_axi_rdata;
wire [1:0]	uart_axi_bresp;
wire [1:0]	uart_axi_rresp;

//uart fifo wires

wire [7:0] uart_fifo_m_axis_tdata;
wire       uart_fifo_m_axis_tvalid;
wire       uart_fifo_m_axis_tready;

//stdout done
wire stdout_done;

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
        .pcpi_valid(pcpi_valid),
        .pcpi_insn(pcpi_insn),
        .pcpi_rs1(pcpi_rs1),
        .pcpi_rs2(pcpi_rs2),
        .pcpi_wr(pcpi_wr),
        .pcpi_rd(pcpi_rd),
        .pcpi_wait(pcpi_wait),
        .pcpi_ready(pcpi_ready),
		.irq(irq),
        .eoi(),
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

pico_to_mems #(
    .DATA_WIDTH(WIDTH_P),
    .ADDR_WIDTH(WIDTH_P),
    .M00_BASE_ADDR(ROM_ADDRESS),
    .M01_BASE_ADDR(RAM_ADDRESS),
    .M02_BASE_ADDR(SORT_ADDRESS)
)
pico_to_memories_interconnect_inst
(
    .clk(clk_i),
    .rst(reset_i),
    
	//pico mem bus
    .s00_axil_awaddr(mem_axi_awaddr),
    .s00_axil_awprot(mem_axi_awprot),
    .s00_axil_awvalid(mem_axi_awvalid),
    .s00_axil_awready(mem_axi_awready),
    .s00_axil_wdata(mem_axi_wdata),
    .s00_axil_wstrb(mem_axi_wstrb),
    .s00_axil_wvalid(mem_axi_wvalid),
    .s00_axil_wready(mem_axi_wready),
    .s00_axil_bresp(mem_axi_bresp),
    .s00_axil_bvalid(mem_axi_bvalid),
    .s00_axil_bready(mem_axi_bready),
    .s00_axil_araddr(mem_axi_araddr),
	.s00_axil_arprot(mem_axi_arprot),
    .s00_axil_arvalid(mem_axi_arvalid),
    .s00_axil_arready(mem_axi_arready),
    .s00_axil_rdata(mem_axi_rdata),
    .s00_axil_rresp(mem_axi_rresp),
    .s00_axil_rvalid(mem_axi_rvalid),
    .s00_axil_rready(mem_axi_rready),

	//rom bus
	.m00_axil_awaddr(rom_axi_awaddr),
    .m00_axil_awprot(rom_axi_awprot),
    .m00_axil_awvalid(rom_axi_awvalid),
    .m00_axil_awready(rom_axi_awready),
    .m00_axil_wdata(rom_axi_wdata),
    .m00_axil_wstrb(rom_axi_wstrb),
    .m00_axil_wvalid(rom_axi_wvalid),
    .m00_axil_wready(rom_axi_wready),
    .m00_axil_bresp(rom_axi_bresp),
    .m00_axil_bvalid(rom_axi_bvalid),
    .m00_axil_bready(rom_axi_bready),
    .m00_axil_araddr(rom_axi_araddr),
    .m00_axil_arprot(rom_axi_arprot),
    .m00_axil_arvalid(rom_axi_arvalid),
    .m00_axil_arready(rom_axi_arready),
    .m00_axil_rdata(rom_axi_rdata),
    .m00_axil_rresp(rom_axi_rresp),
    .m00_axil_rvalid(rom_axi_rvalid),
	.m00_axil_rready(rom_axi_rready),

	//ram mem bus
    .m01_axil_awaddr(ram_axi_awaddr),
    .m01_axil_awprot(ram_axi_awprot),
    .m01_axil_awvalid(ram_axi_awvalid),
    .m01_axil_awready(ram_axi_awready),
    .m01_axil_wdata(ram_axi_wdata),
    .m01_axil_wstrb(ram_axi_wstrb),
	.m01_axil_wvalid(ram_axi_wvalid),
    .m01_axil_wready(ram_axi_wready),
    .m01_axil_bresp(ram_axi_bresp),
    .m01_axil_bvalid(ram_axi_bvalid),
    .m01_axil_bready(ram_axi_bready),
    .m01_axil_araddr(ram_axi_araddr),
    .m01_axil_arprot(ram_axi_arprot),
    .m01_axil_arvalid(ram_axi_arvalid),
    .m01_axil_arready(ram_axi_arready),
    .m01_axil_rdata(ram_axi_rdata),
    .m01_axil_rresp(ram_axi_rresp),
    .m01_axil_rvalid(ram_axi_rvalid),
    .m01_axil_rready(ram_axi_rready),

	//sorter ram mem bus
    .m02_axil_awaddr(cpu_to_sort_ram_axi_awaddr),
    .m02_axil_awprot(cpu_to_sort_ram_axi_awprot),
    .m02_axil_awvalid(cpu_to_sort_ram_axi_awvalid),
    .m02_axil_awready(cpu_to_sort_ram_axi_awready),
    .m02_axil_wdata(cpu_to_sort_ram_axi_wdata),
    .m02_axil_wstrb(cpu_to_sort_ram_axi_wstrb),
    .m02_axil_wvalid(cpu_to_sort_ram_axi_wvalid),
    .m02_axil_wready(cpu_to_sort_ram_axi_wready),
    .m02_axil_bresp(cpu_to_sort_ram_axi_bresp),
    .m02_axil_bvalid(cpu_to_sort_ram_axi_bvalid),
    .m02_axil_bready(cpu_to_sort_ram_axi_bready),
    .m02_axil_araddr(cpu_to_sort_ram_axi_araddr),
    .m02_axil_arprot(cpu_to_sort_ram_axi_arprot),
    .m02_axil_arvalid(cpu_to_sort_ram_axi_arvalid),
    .m02_axil_arready(cpu_to_sort_ram_axi_arready),
    .m02_axil_rdata(cpu_to_sort_ram_axi_rdata),
    .m02_axil_rresp(cpu_to_sort_ram_axi_rresp),
    .m02_axil_rvalid(cpu_to_sort_ram_axi_rvalid),
    .m02_axil_rready(cpu_to_sort_ram_axi_rready)
);

axil_rom #
(
    .DATA_WIDTH(WIDTH_P),
    .ADDR_WIDTH(DEPTH_P),
	.filename_p(instruction_memory_file)
) instruction_memory_inst (
    .clk(clk_i),
    .rst(reset_i),
    .s_axil_awaddr(rom_axi_awaddr),
    .s_axil_awprot(rom_axi_awprot),
    .s_axil_awvalid(rom_axi_awvalid),
	.s_axil_awready(rom_axi_awready),
    .s_axil_wdata(rom_axi_wdata),
    .s_axil_wstrb(rom_axi_wstrb),
    .s_axil_wvalid(rom_axi_wvalid),
    .s_axil_wready(rom_axi_wready),
	.s_axil_bresp(rom_axi_bresp),
    .s_axil_bvalid(rom_axi_bvalid),
    .s_axil_bready(rom_axi_bready),
    .s_axil_araddr(rom_axi_araddr),
    .s_axil_arprot(rom_axi_arprot),
    .s_axil_arvalid(rom_axi_arvalid),
    .s_axil_arready(rom_axi_arready),
    .s_axil_rdata(rom_axi_rdata),
    .s_axil_rresp(rom_axi_rresp),
    .s_axil_rvalid(rom_axi_rvalid),
	.s_axil_rready(rom_axi_rready)
);

axil_ram #
(
    .DATA_WIDTH(WIDTH_P),
    .ADDR_WIDTH(DEPTH_P)
) pico_memory_inst (
    .clk(clk_i),
    .rst(reset_i),
    .s_axil_awaddr(ram_axi_awaddr),
    .s_axil_awprot(ram_axi_awprot),
    .s_axil_awvalid(ram_axi_awvalid),
	.s_axil_awready(ram_axi_awready),
    .s_axil_wdata(ram_axi_wdata),
    .s_axil_wstrb(ram_axi_wstrb),
    .s_axil_wvalid(ram_axi_wvalid),
    .s_axil_wready(ram_axi_wready),
	.s_axil_bresp(ram_axi_bresp),
    .s_axil_bvalid(ram_axi_bvalid),
    .s_axil_bready(ram_axi_bready),
    .s_axil_araddr(ram_axi_araddr),
    .s_axil_arprot(ram_axi_arprot),
    .s_axil_arvalid(ram_axi_arvalid),
    .s_axil_arready(ram_axi_arready),
    .s_axil_rdata(ram_axi_rdata),
    .s_axil_rresp(ram_axi_rresp),
    .s_axil_rvalid(ram_axi_rvalid),
	.s_axil_rready(ram_axi_rready)
);

axil_ram #
(
    .DATA_WIDTH(WIDTH_P),
    .ADDR_WIDTH(DEPTH_P)
) sorter_memory_inst (
    .clk(clk_i),
    .rst(reset_i),
    .s_axil_awaddr(cpu_to_sort_ram_axi_awaddr),
    .s_axil_awprot(cpu_to_sort_ram_axi_awprot),
    .s_axil_awvalid(cpu_to_sort_ram_axi_awvalid),
	.s_axil_awready(cpu_to_sort_ram_axi_awready),
    .s_axil_wdata(cpu_to_sort_ram_axi_wdata),
    .s_axil_wstrb(cpu_to_sort_ram_axi_wstrb),
    .s_axil_wvalid(cpu_to_sort_ram_axi_wvalid),
    .s_axil_wready(cpu_to_sort_ram_axi_wready),
	.s_axil_bresp(cpu_to_sort_ram_axi_bresp),
    .s_axil_bvalid(cpu_to_sort_ram_axi_bvalid),
    .s_axil_bready(cpu_to_sort_ram_axi_bready),
    .s_axil_araddr(cpu_to_sort_ram_axi_araddr),
    .s_axil_arprot(cpu_to_sort_ram_axi_arprot),
    .s_axil_arvalid(cpu_to_sort_ram_axi_arvalid),
    .s_axil_arready(cpu_to_sort_ram_axi_arready),
    .s_axil_rdata(cpu_to_sort_ram_axi_rdata),
    .s_axil_rresp(cpu_to_sort_ram_axi_rresp),
    .s_axil_rvalid(cpu_to_sort_ram_axi_rvalid),
	.s_axil_rready(cpu_to_sort_ram_axi_rready)
);

axis_fifo #(.DEPTH(256),
            .LAST_ENABLE(0)
) stdout_buffer_fifo_inst (
    .clk(clk_i),
    .rst(reset_i),

    //from cpu
    .s_axis_tdata(mem_axi_wdata[7:0] & {8{mem_axi_awaddr == (UART_ADDRESS | 32'hBEE0)}}),
    .s_axis_tkeep(1'b1),
    .s_axis_tvalid(mem_axi_wready & mem_axi_wvalid & (mem_axi_awaddr == (UART_ADDRESS | 32'hBEE0))),
    .s_axis_tready(),   //maybe unsused?
    .s_axis_tlast(mem_axi_wready & mem_axi_wvalid & (mem_axi_awaddr == (UART_ADDRESS | 32'hBEE0))),
    .s_axis_tid(8'h0),
    .s_axis_tdest(8'h0),
    .s_axis_tuser(8'h0),
    .status_good_frame(),
    .status_bad_frame(),
    .status_overflow(),
    .status_depth_commit(),
    .status_depth(),
    .pause_ack(),
    .pause_req(1'b0),
    .m_axis_tuser(),
    .m_axis_tdest(),
    .m_axis_tid(),
    .m_axis_tlast(),
    .m_axis_tkeep(),
    //from and to uart
    .m_axis_tdata(uart_fifo_m_axis_tdata),
    .m_axis_tvalid(uart_fifo_m_axis_tvalid),
    .m_axis_tready(uart_fifo_m_axis_tready)
);

uart_tx #() stdout_uart_tx_inst (
    .clk(clk_i),
    .rst(reset_i),
    .s_axis_tdata(uart_fifo_m_axis_tdata),
    .s_axis_tvalid(uart_fifo_m_axis_tvalid),
    .s_axis_tready(uart_fifo_m_axis_tready),
    .txd(tx_o),
    .busy(),
    .prescale(16'd55)
);

pcpi_counter #(.WIDTH_P(5)) pcpi_counter_inst(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .pcpi_valid(pcpi_valid & (pcpi_insn_opcode == SORT_INST_OPCODE) & (pcpi_insn_func7 == SORT_INST_FUNCT7)),
    .pcpi_insn(pcpi_insn),
    .pcpi_rs1(pcpi_rs1),
    .pcpi_rs2(pcpi_rs2),
    .pcpi_rd(pcpi_rd),
    .pcpi_wait(pcpi_wait),
    .pcpi_wr(pcpi_wr),
    .pcpi_ready(pcpi_ready)
);

/*
axiluart #(
		.INITIAL_SETUP(31'd25),
		.C_AXI_ADDR_WIDTH(WIDTH_P)
) stdout_inst(
		.S_AXI_ACLK(clk_i),
		.S_AXI_ARESETN(!reset_i),
		.S_AXI_AWVALID(uart_axi_awvalid),
		.S_AXI_AWREADY(uart_axi_awready),
		.S_AXI_AWADDR(uart_axi_awaddr),
		.S_AXI_AWPROT(uart_axi_awprot),
		.S_AXI_WVALID(uart_axi_wvalid),
		.S_AXI_WREADY(uart_axi_wready),
		.S_AXI_WDATA(uart_axi_wdata),
		.S_AXI_WSTRB(uart_axi_wstrb),
		.S_AXI_BVALID(uart_axi_bvalid),
		.S_AXI_BREADY(uart_axi_bready),
		.S_AXI_BRESP(uart_axi_bresp),
		.S_AXI_ARVALID(uart_axi_arvalid),
		.S_AXI_ARREADY(uart_axi_arready),
		.S_AXI_ARADDR(uart_axi_araddr),
		.S_AXI_ARPROT(uart_axi_arprot),
		.S_AXI_RVALID(uart_axi_rvalid),
		.S_AXI_RREADY(uart_axi_rready),
		.S_AXI_RDATA(uart_axi_rdata),
		.S_AXI_RRESP(uart_axi_rresp),
		.i_uart_rx(1'b1),
		.o_uart_tx(tx_o),
		.i_cts_n(1'b0)
);
*/

//mem axi response busses
assign led[3:0] = {mem_axi_bresp, mem_axi_rresp};

//ebreak found
assign led[6] = mem_axi_rdata == 32'h00100073;
assign led[7] = trap;
assign led[5] = stdout_done;
assign led[4] = ~trap;

//assign pcpi_inst_info

assign pcpi_insn_opcode = pcpi_insn[6:0];
assign pcpi_insn_func7 = pcpi_insn[31:25];

//assign unused inputs
assign irq = '0;

assign stdout_done = trap & !uart_fifo_m_axis_tvalid & uart_fifo_m_axis_tready;
endmodule
