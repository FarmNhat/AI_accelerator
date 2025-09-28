module psum_acc (
    input  wire        clk,
    input  wire        rst,
    input  wire        en, // Enable signal (not used in this example)

    //output wire [15:0] psum_out2,
    input  wire [7:0] psum_in,
    output reg  [7:0] accum_out
);

    reg [7:0] psum_buffer [0:2];    // Lưu 3 phần tử
    reg [2:0]  psum_count;  
    //reg full;

    //assign psum_out2 = psum_buffer[0]; // Kết nối đầu ra psum_out2 với accum_out
             
    always @(posedge clk ) begin
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
                psum_count = psum_count + 1;
                
            end 
            else if (psum_count == 1) begin
                psum_buffer[1] = psum_in; // Lưu phần tử thứ hai
                psum_count = psum_count + 1;
                
            end 
            else if (psum_count > 1)begin
                psum_buffer[psum_count[1:0]] = psum_in;
                
                accum_out = psum_buffer[0] + psum_buffer[1] + psum_buffer[2]; // Cập nhật giá trị đầu ra

                if (psum_count[1:0] == 2)begin
                    psum_count[1:0] = 2'b00; // Reset đếm phần tử
                    psum_count[2] = 1;
                end
                else begin
                    psum_count = psum_count + 1;
                end
            end
        end
    end
endmodule

// FAIL: Khi psum_buffer[2] được gán là 2,
// psum_buffer[0] vẫn chưa phải 12 nếu bạn
// đ�?c nó ngay sau đó, mà vẫn là 0 (vì mới 
// được gán ở tick 5).

/*psum_in là input từ bên ngoài, nhưng nếu 
bạn thay đổi nó trong testbench ngay trước 
cạnh đồng hồ, thì mô ph�?ng vẫn chưa đưa giá
trị đó vào module cho đến cạnh đồng hồ tiếp theo.*/


