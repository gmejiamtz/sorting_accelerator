always_ff @(posedge clk_i) begin
    if (rst_i) begin
        sort_done = 1'b0;
        min = 'x;
        sort_data_i = 'x;
        data_min = 'x;
        data_comp = 'x;
        data_intr = 'x;
        sort_addr = 'x;
        sort_rw_en = 1'b0;
        sort_request = 1'b0;
    end else if (sort_en) begin
        for (int i = 0; i < DATA_ENTRIES; i++) begin
            min <= i;
            for (int j = i + 1; j < DATA_ENTRIES; j++) begin
                sort_rw_en <= 1'b0;
                sort_request <= 1'b1;
                sort_addr <= min[7:0];
                @(posedge clk_i);
                sort_rw_en <= 1'b0;
                sort_request <= 1'b1;
                sort_addr <= j[7:0];
                @(posedge clk_i);
                data_min <= read_data_mem;
                @(posedge clk_i);
                data_comp <= read_data_mem;
                sort_request <= 1'b0;
                if (data_comp < data_min) begin
                    min <= j;
                end
            end
            sort_request <= 1'b1;
            sort_rw_en <= 1'b0;
            sort_addr <= i[7:0];
            repeat(2) @(posedge clk_i);
            data_intr <= read_data_mem;
            @(posedge clk_i);
            sort_request <= 1'b1;
            sort_rw_en <= 1'b1;
            sort_addr <= i[7:0];
            sort_data_i <= data_min;
            @(posedge clk_i);
            sort_request <= 1'b1;
            sort_rw_en <= 1'b1;
            sort_addr <= min[7:0];
            sort_data_i <= data_intr;
            @(posedge clk_i);
            sort_request <= 1'b0;
            sort_rw_en <= 1'b0;
        end
        sort_done <= 1'b1;
    end
    else begin
        min = 'x;
        sort_done = 1'b0;
        sort_rw_en = 1'b0;
        sort_request = 1'b0;
        sort_data_i = 'x;
        data_min = 'x;
        data_comp = 'x;
        data_intr = 'x;
        sort_addr = 'x;
        sort_rw_en = 1'b0;
        sort_request = 1'b0;
    end
end