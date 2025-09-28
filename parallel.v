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
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer    <= in_ifmap;
        end else if (en) begin
            out_ifmap <= buffer[7:0];
            buffer <= buffer >> 8;
        end
    end
    
    //assign out_ifmap = buffer[7:0];

endmodule
