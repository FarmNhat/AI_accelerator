module filter_spad (
    input  wire        clk,
    input  wire        rd, wr,      
    input  wire [5:0]  addr,        
    input  wire [7:0]  data_in,   // 8-bit input data
    output reg  [7:0]  data_out   // 8-bit output data
);

    reg [7:0] mem [64:0];

    always @(posedge clk) begin
        if (wr)
            mem[addr] <= data_in;         // Reset output to zero
        if (rd)
            data_out <= mem[addr];       // Load new data when enabled
    end
endmodule