module serial #(
    parameter BUS = 31   // độ rộng bus (từ 0 đến BUS → BUS+1 bit)
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              en,
    input  wire [7:0]        in_ifmap,
    output wire [BUS:0]      out_ifmap
);

    // Thanh ghi đệm dữ liệu
    reg [BUS:0] buffer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer    <= { (BUS+1){1'b0} };
        end else if (en) begin
            buffer    <= {in_ifmap, buffer[BUS:8]};
        end
    end
    
    assign out_ifmap = buffer;

endmodule
