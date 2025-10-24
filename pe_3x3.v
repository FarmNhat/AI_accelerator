
//`include "psum_acc.v"
`include "PE.v"

module pe_array_3x3 #(
    parameter IFMAP,
    parameter FILTER,
    parameter OUT
)(
    input  wire        clk,
    input  wire        en,
    input  wire        rst,
    input  wire [IFMAP*IFMAP*8 - 1:0] ifmap_in_flat ,
    input  wire [FILTER*FILTER*8 - 1:0] filter_in_flat ,
    output wire [OUT*OUT*8 - 1:0] sum_out_flat,
    //for test
    output wire [7:0] psum_test0,
    output wire done_compute

);

wire [7:0] ifmap_in[IFMAP*IFMAP-1:0]; // 5x5 = 25 ph?n t?
wire [7:0] filter_in[FILTER*FILTER-1:0]; // 3x3 = 9 ph?n t?
reg [7:0] sum_out[8:0]; // 3x3 = 9 ph?n t?
reg done;

assign done_compute = done;

genvar k;
generate
    for (k = 0; k < IFMAP*IFMAP; k = k + 1)
        assign ifmap_in[k] = ifmap_in_flat[k * 8 +: 8];
    for (k = 0; k < FILTER*FILTER; k = k + 1)
        assign filter_in[k] = filter_in_flat[k * 8 +: 8];
    for (k = 0; k < 9; k = k + 1) 
        assign sum_out_flat[k*8 +: 8] = sum_out[k];
    endgenerate
    

reg [7:0] temp_ifmap[FILTER:0][FILTER:0]; // psum_out c?a t?ng PE
wire [7:0] temp_filter[FILTER:0][FILTER:0];
wire [7:0] psum_temp[FILTER:0]; // cộng chiều dọc nên tùy kích thước filter

    assign psum_test0 = psum_temp[0]; // for test
    wire [7:0] psum_row [0:FILTER-1][0:FILTER-1]; // psum_row[r][c] from PE at (r,c)
    
reg [2:0] cnt;

    genvar i, j;
    generate
        for (i = 0; i < FILTER; i = i + 1) begin :row// row và col là tên c?a các instance ki?u row[1] ...
            //wire [7:0] psum_row [2:0]; // T?ng psum c?a 3 PE trong m?t hàng
            //wire [7:0] partial_sum [FILTER:0];
            for (j = 0; j < FILTER; j = j + 1) begin :col   //pe_array_3x3.row[1].pe ------- uut.row_block[1].col_block[2].u_pe.y
                
                pe #(.ACC_NUM(3)) pe (
                    .clk(clk),
                    .rst(rst),
                    .en(en),
                    .input_ifmap(temp_ifmap[i][j]),
                    .input_filter(temp_filter[i][j]),
                    .output_psum(psum_row[i][j])
                );

            end
            // for (j = 0; j < FILTER; j = j + 1) begin
            //     assign partial_sum[j+1] = partial_sum[j] + psum_row[j];
            // end
            //assign psum_temp[i] = psum_row[0] + psum_row[1] + psum_row[2]; 
            //assign psum_temp[i] = partial_sum[FILTER];
            if (FILTER == 1) begin
                assign psum_temp[i] = psum_row[i][0];
            end else if (FILTER == 2) begin
                assign psum_temp[i] = psum_row[i][0] + psum_row[i][1];
            end else if (FILTER == 3) begin
                assign psum_temp[i] = psum_row[i][0] + psum_row[i][1] + psum_row[i][2];
            end else begin : GEN_ADDER
                // generic reduction for FILTER > 3
                // create a small adder tree
                wire [15:0] adder_stage [0:FILTER-1];
                for (j = 0; j < FILTER; j = j + 1) begin : RED
                    assign adder_stage[j] = psum_row[i][j];
                end
                integer rr;
                // iterative reduction (synthesizable)
                // pairwise reduce
                // We'll reduce in a simple loop (combinational)
                // Note: tools differ; this is conservative approach.
                reg [15:0] comb_sum;
                always @(*) begin
                    comb_sum = 0;
                    for (rr = 0; rr < FILTER; rr = rr + 1)
                        comb_sum = comb_sum + adder_stage[rr];
                end
                assign psum_temp[i] = comb_sum[7:0];
            end
        end
    endgenerate
    
    reg [2:0] cnt_out; //đếm từ psum temp ra sum out, khi cnt = 3 thì psum temp mới có gtri

    always @(posedge clk)begin
        if(rst) begin
            cnt <= 0;
            done <= 0;
        end
        else if(cnt == OUT + 1) begin 
            // keep cnt = 4 for ever
        end
        else begin
            cnt <= cnt + 1;
        end
    end

    always @(posedge clk)begin
        if(cnt == FILTER - 1) begin // bằng độ rộng filter (vì pe sẽ chạy hết chiều dài này trc khi bắt đầu tính sum)
            cnt_out <= 0;
        end
        else if(cnt_out == OUT - 1) begin // bằng out vì sau khi tính sum lần 1 sẽ cần chạy OUT lần để hết ifmap
            // keep cnt_out = 2 for ever
            done <= 1;
        end
        else begin
            cnt_out <= cnt_out + 1;
        end
    end

    always @(psum_temp[0], psum_temp[1], psum_temp[2]) begin
        if(cnt > OUT - 1)begin
        integer a;
            for (a = 0; a < FILTER; a = a + 1) begin
                sum_out[a*OUT + cnt_out] <= psum_temp[a];
            end
        end
    end

generate
    for (i = 0; i < FILTER; i = i + 1) begin : col
        for (j = 0; j < FILTER; j = j + 1) begin : row
            assign temp_filter[j][i] = filter_in[i + 3*j];
        end
    end
endgenerate



always @(posedge clk) begin
    if (~rst) begin
        integer a, b;
        for (a = 0; a < FILTER; a = a + 1) begin
            for (b = 0; b < FILTER; b = b + 1) begin
                temp_ifmap[a][b] <= ifmap_in[cnt + (a + b) * IFMAP];
            end
        end
    end
end

    //nhìn vào cnt để nhớ lại cách hđ của row stationary
    //dò biến cnt này để biết đang ở cột nào của ifmap, vì biến cnt chạy tới x nên x là số giá trị (theo hàng) đc bỏ vào pe

endmodule



