module sdram_sm #(
    parameter RSC_p = 2, //clk 133MHz
    parameter RP_p = 15, //nS
    parameter RAS_p = 0, //nS
    parameter data_len_p = 0,
    parameter cas_laten_p = 2
)(
    input   logic   [0:0]   clk_i,
    input   logic   [0:0]   rst_i,
    input   logic   [0:0]   go_i,
    input   logic   [0:0]   delay_i,
    input   logic   [0:0]   rw_en_i,
    input   logic   [0:0]   read_valid_i,
    input   logic   [0:0]   write_ready_i,

    output  logic   [0:0]   ic_CS_o,
    output  logic   [0:0]   ic_RAS_o,
    output  logic   [0:0]   ic_CAS_o,
    output  logic   [0:0]   ic_WE_o,
    output  logic   [0:0]   ic_CKE_o,

    output  logic   [0:0]   read_ready_o,
    output  logic   [0:0]   write_valid_o
);

    // Flags
    logic [0:0] precharge_f, setmode_f, read_en_f, write_en_f;
    logic [0:0] t_RP_del_f, t_RSC_del_f, t_XSR_del_f, t_REF_del_f;
    
    // Delay Timer
    logic [4:0] RP_t_l;
    always_ff @(posedge clk_i) begin : RP
        if (rst_i) RP_t_l <= RP_p;
        else if (t_RP_del_f & RP_t_l != 5'd0) begin
            RP_t_l <= RP_t_l - 1;
        end
    end

    logic [4:0] RSC_t_l;
    always_ff @(posedge clk_i) begin : RP
        if (rst_i) RSC_t_l <= RSC_p;
        else if (t_RSC_del_f & RSC_t_l != 5'd0) begin
            RSC_t_l <= RSC_t_l - 1;
        end else if (RSC_t_l == 5'd0) begin
            ;
        end
    end
    

    // D, Q FFs
    logic [2:0] state_d, state_q;
    always_ff @(posedge clk_i) begin
        if (rst_i) state_q <= 3'd0;
        else state_q <= state_d;
    end

    logic [0:0] delay_d, delay_q;
    always_ff @(posedge clk_i) begin
        if (rst_i) delay_q <= 1'b0;
        else delay_q <= |{};
    end

endmodule