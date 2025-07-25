module parsum_spad (
    input  wire        clk,
    input  wire        rd, wr,      
    //input  wire [5:0]  addr_in,        
    input  wire [5:0]  addr_out,       
    input  wire [7:0]  data_in,   // 8-bit input data
    output reg  [7:0]  data_out   // 8-bit output data
);

    reg [7:0] mem [64:0];
    reg count;

    always @(posedge clk) begin
        if(rst)
            count <= 0;
            data_out <= 8'b00000000;                     // Reset count on reset signal
        if (wr)
            mem[count] <= data_in;         // Reset output to zero
            count <= count + 1;             // Increment count on write
        if (rd)
            data_out <= mem[addr_out];       // Load new data when enabled
    end
endmodule