`include "PE.v"
//`include "psum_acc.v"

module pe_array_3x3 (
    input  wire        clk,
    input  wire        en,
    input  wire        rst,
    input  wire [399:0] ifmap_in_flat ,
    input  wire [143:0] filter_in_flat ,
    output wire [143:0] sum_out_flat, 
    //for test
    output wire [15:0] psum_test0, // 9 phần tử psum_out
    output wire [15:0] psum_test1,
    output wire [15:0] psum_test2,

    output wire [15:0] sum_test0, // 9 phần tử psum_out
    output wire [15:0] sum_test1,
    output wire [15:0] sum_test2
);

reg [15:0] ifmap_in[24:0]; // 5x5 = 25 phần tử
reg [15:0] filter_in[8:0]; // 3x3 = 9 phần tử
reg [15:0] sum_out[8:0]; // 3x3 = 9 phần tử


integer k;
always @(posedge clk) begin
    if (rst) begin
        for (k = 0; k < 25; k = k + 1)
            ifmap_in[k] <= ifmap_in_flat[k * 16 +: 16];
        for (k = 0; k < 9; k = k + 1)
            filter_in[k] <= filter_in_flat[k * 16 +: 16];
    end
end

genvar m;
    generate
        for (m = 0; m < 9; m = m + 1) begin 
            assign sum_out_flat[m*16 +: 16] = sum_out[m];
        end
    endgenerate

reg [15:0] temp_ifmap[2:0][2:0]; // psum_out của từng PE
reg [15:0] temp_filter[2:0][2:0];
wire [15:0] psum_temp[2:0]; // psum của từng PE

assign sum_test0 = sum_out[0];
assign sum_test1 = sum_out[1];
assign sum_test2 = sum_out[2];

assign psum_test0 = psum_temp[0];
assign psum_test1 = psum_temp[1];
assign psum_test2 = psum_temp[2];

reg [2:0] cnt;

    genvar i, j;
    generate
        for (i = 0; i < 3; i = i + 1) begin : row   // row và col là tên của các instance kiểu row[1] ...
            wire [15:0] psum_row [2:0]; // Tổng psum của 3 PE trong một hàng
            for (j = 0; j < 3; j = j + 1) begin : col   //pe_array_3x3.row[1].pe ------- uut.row_block[1].col_block[2].u_pe.y
                
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
            //idx <= idx + 1; // Chuyển sang hàng tiếp theo
        end
    end

    integer a;
    always @(posedge clk) begin
        for (a = 0; a < 3; a = a + 1) begin
            temp_filter[0][a] <= filter_in[a];
            temp_filter[1][a] <= filter_in[a + 3];
            temp_filter[2][a] <= filter_in[a + 6];
        end

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

endmodule