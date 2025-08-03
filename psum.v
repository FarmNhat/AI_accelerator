module scratchpad_psum (
    input  wire        clk,
    input  wire [4:0]  addr,
    input  wire        wr_en,
    input  wire [15:0] data_in,
    output wire [15:0] data_out
);

    reg [15:0] mem [0:23];  // 24 x 64-bit

    assign data_out = mem[addr];

    always @(posedge clk) begin
        if (wr_en)
            mem[addr] <= data_in;
    end

endmodule
