
//`include "psum_acc.v"
`include "PE.v"

module pe_array_3x3 (
    input  wire        clk,
    input  wire        en,
    input  wire        rst,
    input  wire [199:0] ifmap_in_flat ,
    input  wire [71:0] filter_in_flat ,
    output wire [71:0] sum_out_flat
    //for test
    //output wire [7:0] psum_test0

);

wire [7:0] ifmap_in[24:0]; // 5x5 = 25 ph?n t?
wire [7:0] filter_in[8:0]; // 3x3 = 9 ph?n t?
reg [7:0] sum_out[8:0]; // 3x3 = 9 ph?n t?


genvar k;
generate
    for (k = 0; k < 25; k = k + 1)
        assign ifmap_in[k] = ifmap_in_flat[k * 8 +: 8];
    endgenerate
    
genvar y;
generate
    for (y = 0; y < 9; y = y + 1)
        assign filter_in[y] = filter_in_flat[y * 8 +: 8];
endgenerate


genvar m;
generate
        for (m = 0; m < 9; m = m + 1) begin
            assign sum_out_flat[m*8 +: 8] = sum_out[m];
        end
    endgenerate
    
reg [7:0] temp_ifmap[2:0][2:0]; // psum_out c?a t?ng PE
wire [7:0] temp_filter[2:0][2:0];
wire [7:0] psum_temp[2:0]; // psum c?a t?ng PE

    assign psum_test0 = temp_filter[0][1];
    
reg [2:0] cnt;

    genvar i, j;
    generate
        for (i = 0; i < 3; i = i + 1) begin :row// row và col là tên c?a các instance ki?u row[1] ...
            wire [7:0] psum_row [2:0]; // T?ng psum c?a 3 PE trong m?t hàng
            for (j = 0; j < 3; j = j + 1) begin :col   //pe_array_3x3.row[1].pe ------- uut.row_block[1].col_block[2].u_pe.y
                
                pe pe (
                    .clk(clk),
                    .rst(rst),
                    .en(en),
                    .input_ifmap(temp_ifmap[i][j]),
                    .input_filter(temp_filter[i][j]),
                    .output_psum(psum_row[j])
                );

            end
        
            assign psum_temp[i]  = psum_row[0] + psum_row[1] + psum_row[2]; 
        end
    endgenerate
 
    always @(posedge clk)begin
        if(rst) begin
            cnt <= 0;
            //idx <= 0;
        end
        else if(cnt == 6) begin 
            cnt <= 0; 
            //idx <= 0; // Reset cnt and idx when reaching the end of the ifmap
        end
        else begin
            cnt <= cnt + 1;
        end
    end

    always @(psum_temp[0], psum_temp[1], psum_temp[2]) begin
        if(cnt > 2)begin
        //sum_out[0] = psum_temp[0];
         sum_out[cnt-3] <= psum_temp[0];
         sum_out[cnt] <= psum_temp[1];
         sum_out[cnt+3] <= psum_temp[2];
            //idx <= idx + 1; // Chuy?n sang hàng ti?p theo
        end
    end

    // genvar a;
    // generate
    //     for (a = 0; a < 3; a = a + 1) begin
    //         assign temp_filter[0][a] = filter_in[a];
    //         assign temp_filter[1][a] = filter_in[a + 3];
    //         assign temp_filter[2][a] = filter_in[a + 6];
    //     end
    // endgenerate

    assign temp_filter[0][0] = filter_in[0];
    assign temp_filter[1][0] = filter_in[3];
    assign temp_filter[2][0] = filter_in[6];

    assign temp_filter[0][1] = filter_in[1];
    assign temp_filter[1][1] = filter_in[4];
    assign temp_filter[2][1] = filter_in[6];

    assign temp_filter[0][2] = filter_in[2];
    assign temp_filter[1][2] = filter_in[5];
    assign temp_filter[2][2] = filter_in[7];


    always @(posedge clk) begin
        if(~rst) begin

        temp_ifmap[0][0] <= ifmap_in[cnt];
        temp_ifmap[0][1] <= ifmap_in[cnt + 5];
        temp_ifmap[0][2] <= ifmap_in[cnt + 10];
    
        temp_ifmap[1][0] <= ifmap_in[cnt + 5];
        temp_ifmap[1][1] <= ifmap_in[cnt + 10];
        temp_ifmap[1][2] <= ifmap_in[cnt + 15];
     
        temp_ifmap[2][0] <= ifmap_in[cnt + 10];
        temp_ifmap[2][1] <= ifmap_in[cnt + 15];
        temp_ifmap[2][2] <= ifmap_in[cnt + 20];
        end
    end

    //dò biến cnt này để biết đang ở cột nào của ifmap, vì biến cnt chạy tới x nên x là số giá trị (theo hàng) đc bỏ vào pe

endmodule