module pe_array_3x3 (
    input  wire        clk,
    input  wire        en,
    input  wire        rst,
    input  reg [15:0] ifmap_in [4:0][4:0],
    input  reg [15:0] filter_in [2:0][2:0],
    
    output  wire [15:0] sum_out [2:0][2:0],
);

reg [15:0] temp_ifmap[2:0][2:0]; // psum_out của từng PE
reg [15:0] temp_filter[2:0][2:0];
reg [15:0] psum[2:0][2:0]; // psum của từng PE
reg [2:0] cnt;

    genvar i, j, k;
    generate
        for (i = 0; i < 3; i = i + 1) begin : row   // row và col là tên của các instance kiểu row[1] ...
            for (j = 0; j < 3; j = j + 1) begin : col   //pe_array_3x3.row[1].pe ------- uut.row_block[1].col_block[2].u_pe.y
                


                pe pe (
                    .clk(clk),
                    .rst(rst),
                    .en(en),
                    .input_ifmap(temp_ifmap[i][j]),
                    .input_filter(temp_filter[i][j]),
                    .input_psum(psum[i][j]),
                    .output_psum(sum_out[i][j])
                );

            end
        end
    endgenerate

    always @(posedge clk)begin
        if(rst)
            cnt <= 0;
        else if(cnt == 4) 
            cnt <= 0; 
        else 
            cnt <= cnt + 1;
    end

    always @(posedge clk) begin
        temp_ifmap[2:0][0] <= ifmap_in[2:0][cnt]; // Lấy dữ liệu từ ifmap vào mảng tạm thời
        temp_ifmap[2:0][1] <= ifmap_in[3:1][cnt];
        temp_ifmap[2:0][2] <= ifmap_in[4:2][cnt];
    end

endmodule