module sm import config_pkg::*;
#(
    parameter RSC_p = 2, //clk 133MHz
    parameter RP_p = 2, //15ns
    parameter RCD_p = 2, 
    parameter XSR_p = 75, //min of 72, making it 75 for some leeway
    parameter REF_p = 0, //temp
    parameter burst_len_p = 8,
    parameter data_len_p = 0, //temp
    parameter cas_laten_p = 2 
)(
    input   logic   [0:0]   clk_i,
    input   logic   [0:0]   rst_i,
    input   logic   [0:0]   go_i,
    input   logic   [0:0]   delay_i,
    input   logic   [0:0]   rw_en_i, //1 = write, 0 == read
    input   logic   [0:0]   read_valid_i, //check handshake smh sean
    input   logic   [0:0]   write_ready_i,

    output  logic   [0:0]   ic_CS_o,
    output  logic   [0:0]   ic_RAS_o,
    output  logic   [0:0]   ic_CAS_o,
    output  logic   [0:0]   ic_WE_o,
    output  logic   [0:0]   ic_CKE_o,

    output  logic   [0:0]   read_ready_o,
    output  logic   [0:0]   write_valid_o
);


//fix parameter bus sizes im hella stupid lol, make them clog2ß

//TRP TIMER
    logic [0:0] trp_cnt_rst;
    logic [1:0] trp_cnt_d, trp_cnt_q;

    always_ff @(posedge clk_i) begin
        if (rst_i || trp_cnt_rst) begin
            trp_cnt_q <= 1'b0;
        end else if (state_q == PC) begin
            //will change later to be better
            trp_cnt_q <= trp_cnt_q + 1;
        end 
    end

//RSC TIMER
    logic [0:0] trsc_cnt_rst;
    logic [$clog2(RSC_p):0] trsc_cnt_d, trsc_cnt_q;

    always_ff @(posedge clk_i) begin
        if (rst_i || trsc_cnt_rst) begin
            trsc_cnt_q <= 1'b0;
        end else if (state_q == MR) begin
            //will change later to be better
            trsc_cnt_q <= trsc_cnt_q + 1;
        end 
    end

//RCD TIMER
    logic [0:0] trcd_cnt_rst;
    logic [$clog2(RCD_p):0] trcd_cnt_d, trcd_cnt_q;

    always_ff @(posedge clk_i) begin
        if (rst_i || trcd_cnt_rst) begin
            trcd_cnt_q <= 1'b0;
        end else if (state_q == BA) begin
            //will change later to be better
            trcd_cnt_q <= trcd_cnt_q + 1;
        end 
    end

//REF TIMER
    logic [0:0] tref_cnt_rst;
    //maybe it should be clog2(ref_p)-1, but the earlier cases cant be -1 so we'll stay consistent *for now*
    logic [$clog2(REF_p):0] tref_cnt_d, tref_cnt_q;

    always_ff @(posedge clk_i) begin
        if (rst_i || tref_cnt_rst) begin
            tref_cnt_q <= 1'b0;
        end else if (state_q == SR) begin
            //will change later to be better
            tref_cnt_q <= tref_cnt_q + 1;
        end 
    end    

//XSR TIMER
    logic [0:0] txsr_cnt_rst;
    //maybe it should be clog2(xsr_p)-1, but the earlier cases cant be -1 so we'll stay consistent *for now*
    logic [$clog2(XSR_p):0] txsr_cnt_d, txsr_cnt_q;

    always_ff @(posedge clk_i) begin
        if (rst_i || txsr_cnt_rst) begin
            txsr_cnt_q <= 1'b0;
        end else if (xsr_flag) begin
            //will change later to be better
            txsr_cnt_q <= txsr_cnt_q + 1;
        end 
    end    


//READ COUNT
    logic [0:0] tread_cnt_rst, tread_cas_rst;
    logic [7:0] tread_cnt_d, tread_cnt_q; 

    always_ff @(posedge clk_i) begin
        if (rst_i || tread_cnt_rst) begin
            tread_cnt_q <= 1'b0;
        end else if (state_q == READ) begin
            //will change later to be better
            tread_cnt_q <= tread_cnt_d + 1;
        end 
    end 

    logic [1:0] tread_cas_del_d, tread_cas_del_q;
    logic [0:0] tread_flag;
    always_ff @(posedge clk_i) begin
        if (rst_i || tread_cas_rst) begin
            tread_cas_q <= 0;
        end else if ((state_q == READ) & tread_flag) begin
            //will change later to be better
            tread_cas_q <= tread_cas_d + 1;
        end 
    end 


//WRITE COUNT
    logic [0:0] twrite_cnt_rst;
    logic [7:0] twrite_cnt_d, twrite_cnt_q; 

    always_ff @(posedge clk_i) begin
        if (rst_i || twrite_cnt_rst) begin
            twrite_cnt_q <= 0;
        end else if (state_q == WRITE) begin
            //will change later to be better
            twrite_cnt_q <= twrite_cnt_d + 1;
        end 
    end 

    state_t [2:0] state_d, state_q;
    always_ff @(posedge clk_i) begin
        if (rst_i) state_q <= 3'd0;
        else state_q <= state_d;
    end


    ic_l = {ic_CS_o, ic_RAS_o, ic_CAS_o, ic_WE_o};

    always_comb begin
        state_d = state_q;

        //counter stuff here
        trp_cnt_rst = 1'b0;
        trsc_cnt_rst = 1'b0;
        trcd_cnt_rst = 1'b0;
        tref_cnt_rst = 1'b0;
        txsr_cnt_rst = 1'b0;

        tread_cnt_rst = 1'b0;
        tread_cas_rst = 1'b0;
        twrite_cnt_rst = 1'b0;
        tread_flag = 1'b0;

        ic_CKE_o = 1'b1;
        xsr_flag = 1'b0;

        read_ready_o = 1'b0;
        write_valid_o = 1'b0;
        
        case(state_q)
            INIT: begin
                ic_l = 4'b0111;

                //remember to include timer values
                if (go_i) begin
                    state_d = PC_activ;
                    ic_l = 4'b0010;
                    trp_cnt_rst = 1'b1;
                end else begin
                    state_d = INIT;
                    ic_l = 4'b0111;
                end
            end

            PC_activ: begin
                ic_l = 4'b0111;

                if (trp_cnt_q >= 2'b10) begin
                    state_d = MR;
                    ic_l = 4'b0000;
                    trsc_cnt_rst = 1'b1;
                end else begin
                    state_d = PC_activ;
                    ic_l = 4'b0111;
                end
            end

            MR: begin 
                ic_l = 4'b0111;

                if (trsc_cnt_q >= RSC_p) begin
                    state_d = BA;
                    ic_l = 4'b0011;
                    trcd_cnt_rst = 1'b1;
                end else begin
                    state_d = MR;
                    ic_l = 4'b0111;
                end
            end

            BA: begin 
                ic_l = 4'b0111;

                if (trcd_cnt_q >= RCD_p) begin
                    if (rw_en_i && write_ready_i) begin 
                        state_d = WRITE;
                        ic_l = 4'b0101;      
                    end else if (!rw_en_i && read_valid_i) begin
                        state_d = READ;
                        ic_l = 4'b0100;
                    end
                end
            end

            READ: begin
                ic_l = 4'b0111;

                if (tread_cnt_q >= burst_len_p) begin
                    //tread_cnt_rst = 1'b1; // Might not want? It'll reset immediately, but not get through 2nd if statement in time b4 goes to 0
                    tread_flag = 1'b1;
                    if (tread_cas_del_q >= 2) begin
                        state_d = PC_deactiv;
                        read_ready_o = 1'b1;
                        tread_cas_rst = 1'b1;
                        tread_cnt_rst = 1'b1;
                        tread_flag = 1'b0;
                        ic_l = 4'b0010;
                    end else begin
                        state_d = READ;
                        ic_l = 4'b0111;
                    end 
                end else begin
                    state_d = READ;
                    ic_l = 4'b0111;
                end
            end

            WRITE: begin
                ic_l = 4'b0111;

                if (twrite_cnt_q >= burst_len_p) begin
                    state_d = PC_deactiv;
                    write_valid_o = 1'b1;
                    twrite_cnt_rst = 1'b1;
                    ic_l = 4'b0010;
                end else begin
                    state_d = WRITE;
                    ic_l = 4'b0111;
                end
            end
            
            PC_deactiv: begin
                ic = 4'b0111;
                
                if (trp_cnt_q >= 2'b10) begin
                    state_d = SR;
                    ic_l = 4'b0001;
                    ic_CKE_o = 1'b0;
                    trsc_cnt_rst = 1'b1;
                end else begin
                    state_d = PC_deactiv;
                    ic_l = 4'b0111;
                end
            end
            
            SR: begin
                ic_l = 4'b0111;
                ic_CKE_o = 1'b0;

                if (tref_cnt_q >= REF_p) begin
                    xsr_flag = 1'b1;
                    if (txsr_cnt_q >= XSR_p) begin
                        state_d = INIT;
                        ic_l = 4'b0111;
                        ic_CKE_o = 1'b1;
                    end else begin
                        state_d = SR;
                        ic_l = 4'b0001;
                        ic_CKE_o = 1'b0;
                    end
                end else begin
                    state_d = SR;
                    ic_l = 4'b0001;
                    ic_CKE_o = 1'b0;
                end
            end

        endcase
    end



endmodule