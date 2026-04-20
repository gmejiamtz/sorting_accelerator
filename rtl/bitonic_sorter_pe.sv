module bitonic_sorter_pe (
    input clk_i,
    input resetn_i,
    input descend_i,    //if high sort G to L
    //input values
    input [31:0] val_1_i,
    input [31:0] val_2_i,
    input valid_i,
    //output values
    output descend_o,   //output descend signal to next stage, pipelined
    output valid_o,     //tells when data is done, should take 1 cycle
    output [31:0] high_o,
    output [31:0] low_o
);

logic [31:0] high_d, high_q;    //high value
logic [31:0] low_d, low_q;      //low value
logic descend_d, descend_q;
logic valid_d, valid_q;

always_ff @( posedge clk_i ) begin : valid_ff
    if (!resetn_i) begin
        valid_q <= '0;
    end else begin
        valid_q <= valid_d;
    end
end

always_ff @( posedge clk_i ) begin : descend_ff
    if (!resetn_i) begin
        descend_q <= '0;
    end else begin
        descend_q <= descend_d;
    end
end

always_ff @( posedge clk_i ) begin : high_ff
    if (!resetn_i) begin
        high_q <= '0;
    end else begin
        high_q <= high_d;
    end
end

always_ff @( posedge clk_i ) begin : low_ff
    if (!resetn_i) begin
        low_q <= '0;
    end else begin
        low_q <= low_d;
    end
end

always_comb begin : comb_logic
    descend_d = descend_i;
    valid_d = valid_i;
    if(descend_i) begin     // G to L
        high_d = val_1_i >= val_2_i ? val_1_i : val_2_i;
        low_d = val_1_i >= val_2_i ? val_2_i : val_1_i;
    end else begin
        high_d = val_1_i >= val_2_i ? val_2_i : val_1_i;
        low_d = val_1_i >= val_2_i ? val_1_i : val_2_i;
    end
end

assign high_o = high_q;
assign low_o = low_q;
assign descend_o = descend_q;
assign valid_o = valid_q;

endmodule
