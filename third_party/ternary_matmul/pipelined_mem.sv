module pipelined_mem #(
    parameter int DATA_WIDTH = 8,
    parameter int NUM_ENTRIES = 256,
    parameter int ID_WIDTH = 8
) (
    input  logic                           clk_i,
    input  logic                           rst_ni,

    output logic                           request_ready_o,
    input  logic                           request_valid_i,
    input  logic                           request_write_not_read_i,
    input  logic [$clog2(NUM_ENTRIES)-1:0] request_addr_i,
    input  logic [ID_WIDTH-1:0]            request_id_i, // optional id
    input  logic [DATA_WIDTH-1:0]          request_w_data_i,

    input  logic                           read_ready_i,
    output logic                           read_valid_o,
    output logic [$clog2(NUM_ENTRIES)-1:0] read_addr_o,
    output logic [ID_WIDTH-1:0]            read_id_o, // optional id
    output logic [DATA_WIDTH-1:0]          read_data_o
);

logic [DATA_WIDTH-1:0] MEM [NUM_ENTRIES];

logic read_valid_d, read_valid_q1;
assign read_valid_d = (request_valid_i && !request_write_not_read_i);

logic write_valid_d, write_valid_q1;
assign write_valid_d = (request_valid_i && request_write_not_read_i);

logic [$clog2(NUM_ENTRIES)-1:0] request_addr_q1;
logic [DATA_WIDTH-1:0] request_w_data_q1;

logic [ID_WIDTH-1:0] request_id_q1;

logic stall1, stall2;
assign stall1 = stall2 && (read_valid_q1 || write_valid_q1);
assign stall2 = !read_ready_i && read_valid_o;

assign request_ready_o = !stall1;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        read_valid_q1 <= 0;
        write_valid_q1 <= 0;
        request_addr_q1 <= 0;
        request_w_data_q1 <= 0;
        request_id_q1 <= '0;
    end else if (!stall1) begin
        read_valid_q1 <= read_valid_d;
        write_valid_q1 <= write_valid_d;
        request_addr_q1 <= request_addr_i;
        request_w_data_q1 <= request_w_data_i;
        request_id_q1 <= request_id_i;
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        read_valid_o <= 0;
        read_addr_o <= 0;
        read_id_o <= 0;
    end else if (!stall2) begin
        read_valid_o <= read_valid_q1;
        read_addr_o <= read_valid_q1 ? request_addr_q1 : 'x;
        read_id_o <= read_valid_q1 ? request_id_q1 : 'x;
    end
end

always_ff @(posedge clk_i) begin
    if (!stall2) begin
        read_data_o <= 'x;
        if (write_valid_q1) begin
            MEM[request_addr_q1] <= request_w_data_q1;
        end else if (read_valid_q1) begin
            read_data_o <= MEM[request_addr_q1];
        end
    end
end

endmodule
