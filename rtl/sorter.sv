module sorter #(
    parameter int DATA_WIDTH = 8,
    parameter int DATA_ENTRIES = 8
) (
    input   logic   [0:0]              clk_i,
    input   logic   [0:0]              rst_i,

    input   logic   [0:0]              write_valid_i,
    input   logic   [DATA_WIDTH-1:0]   data_i,
    output  logic   [0:0]              busy_o,
    output  logic   [0:0]              read_valid_o,
    output  logic   [DATA_WIDTH-1:0]   data_o
);

reg [DATA_WIDTH-1:0] mem [DATE_ENTRIES-1:0];

logic [1:0] state_d, state_q;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        state_q <= 2'b00;
    end else begin
        state_q <= state_d;
    end
end


logic   [0:0] 
always_comb begin
    state_d = state_q;
    busy_o = 1'b0;
    data_o = 'x;
    read_valid_o = 1'b0;
    case(state_q)
        2'b00 : begin
            if (busy_o || !write_valid_i) begin 
                state_d = 2'b00;
            end else if (!busy_o && write_valid_i) begin
                state_d = 2'b01;
            end
        end
        2'b01 : begin
            ;
        end
        2'b10 : 
        2'b11 : 
    endcase
end