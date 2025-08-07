`include "PE.v"
//`include "psum_acc.v"

module pe_array_3x3 (
    input  wire        clk,
    input  wire        en,
    input  wire        rst,
    input  reg [399:0] ifmap_in_flat ,
    input  reg [143:0] filter_in_flat ,
    output reg [143:0] sum_out_flat 
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
        for (k = 0; k < 9; k = k + 1) 
            sum_out_flat[k*16 +: 16] = sum_out[k];
    end 
end

reg [15:0] temp_ifmap[2:0][2:0]; // psum_out của từng PE
reg [15:0] temp_filter[2:0][2:0];
wire [15:0] psum_temp[2:0]; // psum của từng PE

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
        if(rst)
            cnt <= 0;
        else if(cnt == 5) 
            cnt <= 0; 
        else begin
            if(cnt > 1) begin
                sum_out[cnt] <= psum_temp[0];
                sum_out[cnt + 3] <= psum_temp[1];
                sum_out[cnt + 6] <= psum_temp[2];
            end
            cnt <= cnt + 1;
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