module scratchpad_ifmap (
    input  wire        clk,
    input  wire        wr_en,
    input  wire [3:0]  addr,
    input  wire [15:0] data_in,
    output wire [15:0] data_out
);

    reg [15:0] mem [0:11];  // 12 x 16-bit

    assign data_out = mem[addr];

    always @(posedge clk) begin
        if (wr_en)
            mem[addr] <= data_in;
    end

endmodule
