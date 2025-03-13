module pcpi_counter #(
    WIDTH_P=32
)(
    input clk_i,
    input reset_i,
    input        pcpi_valid,
    input [31:0] pcpi_insn,
    input [31:0] pcpi_rs1,
    input [31:0] pcpi_rs2,
    output         logic pcpi_wr,
    output  [31:0] pcpi_rd,
    output         logic pcpi_wait,
    output         logic pcpi_ready
);

typedef enum logic[1:0] {IDLE,COUNT} state_t;
assign pcpi_rd = '0;
logic [WIDTH_P-1:0] count_q,count_d;
state_t state_q,state_d;

always_ff @(posedge clk_i) begin : fsm_state
    if(reset_i) begin
        state_q <= IDLE;
    end else begin
        state_q <= state_d;
    end
end

always_ff @(posedge clk_i) begin
    if(reset_i) begin
        count_q <= '0;
    end else if (state_q == COUNT) begin
        count_q <= count_d;
    end
end

always_comb begin : count
    state_d = state_q;
    pcpi_wait = '0;
    pcpi_wr = '0;
    pcpi_ready = '0;
    count_d = count_q;
    case (state_q)
        IDLE: begin
            pcpi_wait = '0;
            if(pcpi_valid) begin
                state_d = COUNT;
            end else begin 
                state_d = IDLE;
            end
        end
        COUNT: begin
            pcpi_wait = '1;
            if(&count_q) begin
                state_d = IDLE;
                pcpi_ready = '1;
                count_d = count_q + 1;
            end else begin
                count_d = count_q + 1;
            end
        end
    endcase
end

endmodule
