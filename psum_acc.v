module psum_acc (
    input  wire        clk,
    input  wire        rst,
    input  wire        en, // Enable signal (not used in this example)
    input  wire [15:0] psum_in,
    output reg  [15:0] accum_out
);

    reg [15:0] psum_buffer [0:2];    // Lưu 3 phần tử
    reg [2:0]  psum_count;  
    //reg full;
             
    always @(posedge clk) begin
        if (rst || !en) begin
            psum_count <= 0;
            psum_buffer[0] <= 0;
            psum_buffer[1] <= 0;
            psum_buffer[2] <= 0;
            accum_out  <= 0;
        end 
        else begin
            if (psum_count == 0) begin 
                psum_buffer[0] = psum_in; // Lưu phần tử đầu tiên
                //accum_out = psum_in;       // Cập nhật giá trị đầu ra
                psum_count <= psum_count + 1;
            end 
            else if (psum_count == 1) begin
                psum_buffer[1] = psum_in; // Lưu phần tử thứ hai
                //accum_out = psum_buffer[0] + psum_in; // Cập nhật giá trị đầu ra
                psum_count <= psum_count + 1;
            end 
            else if (psum_count > 1)begin
                psum_buffer[psum_count[1:0]] = psum_in;
                accum_out = psum_buffer[0] + psum_buffer[1] + psum_buffer[2];

                if (psum_count[1:0] == 2)begin
                    psum_count[1:0] = 2'b00; // Reset đếm phần tử
                    psum_count[2] = 1;
                end
                else begin
                    psum_count <= psum_count + 1;
                end
            end
        end
    end
endmodule
