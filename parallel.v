module paralel #(
    parameter BUS = 31   // độ rộng bus (từ 0 đến BUS → BUS+1 bit)
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              en,
    input  wire [BUS:0]    in_ifmap,
    output reg [7:0]      out_ifmap
);

    // Thanh ghi đệm dữ liệu
    reg [BUS:0] buffer;
    reg [2:0] cnt;
    always @(posedge clk or posedge en) begin
        if (rst) begin
            cnt <= 0;
            out_ifmap <= 0;
        end 
        else if (en) begin
            cnt <= 1;
            if(cnt == 0)begin
                buffer <= in_ifmap;
            end
            else begin
                out_ifmap <= buffer[7:0];
                buffer <= buffer >> 8;
            end
        end 
    end
    
    //assign out_ifmap = buffer[7:0];

endmodule
