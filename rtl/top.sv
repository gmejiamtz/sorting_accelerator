module top(
    input   logic   [0:0]   clk_i,
    input   logic   [0:0]   rst_i,
    input   logic   [7:0]   m_data_i,
    input   logic   [7:0]   s_data_i,
    input   logic   [0:0]   go_i,
    input   logic   [0:0]   rw_en_i, // Assuming constant signal
    input   logic   [0:0]   read_valid_i,
    input   logic   [0:0]   write_ready_i,

    output  logic   [0:0]   read_ready_o,
    output  logic   [0:0]   write_valid_o,
    output  logic   [1:0]   bank_sel_o,
    output  logic   [0:0]   CS_o,
    output  logic   [0:0]   RAS_o,
    output  logic   [0:0]   CAS_o,
    output  logic   [0:0]   WE_o,
    output  logic   [0:0]   CKE_o,
    output  logic   [7:0]   m_data_o
);

    localparam BS0 = 1'b1;
    localparam BS1 = 1'b0;

    always_comb begin
        bank_sel_o = {BS1, BS0};
        if (!rw_en_i) begin // We're reading, so taking in data from SDRAM
            m_data_o = s_data_i;
        end else begin      // We're writing, so sending data to SDRAM
            m_data_o = m_data_i;
        end
    end

    logic [0:0] sm_write_valid_o, sm_read_ready_o;  
    sm memory_controller_sm (
        .clk_i,
        .rst_i,
        .go_i,
        .rw_en_i,
        .read_valid_i,
        .write_ready_i,
        .ic_CS_o(CS_o),
        .ic_CAS_o(CAS_o),
        .ic_RAS_o(RAS_o),
        .ic_WE_o(WE_o),
        .ic_CKE_o(CKE_o),
        .read_ready_o(),
        .write_valid_o()
    );





endmodule
