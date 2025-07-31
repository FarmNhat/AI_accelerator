module parsum_spad (
    input  wire        clk,
    input  wire        rd, wr,      
    input  wire        rst,       // Synchronous reset
    //input  wire [5:0]  addr_in,        
    input  wire [5:0]  addr_out,       
    input  wire [7:0]  data_in,   // 8-bit input data
    output reg  [7:0]  data_out   // 8-bit output data
);

    reg [7:0] mem [64:0];
    reg [5:0] count;
    reg [5:0] head, tail;

    always @(posedge clk) begin
        if(rst) begin
            count <= 0;
            head <= 0;
            tail <= 0;                
            data_out <= 8'b00000000;
        end                     // Reset count on reset signal
        if (wr) begin
            mem[tail] <= data_in;         // Reset output to zero
            count <= count + 1;  
            tail <= tail + 1;             // Increment tail pointer
        end           // Increment count on write
        if (rd) begin
            data_out <= mem[head];  
            head <= head + 1;             // Increment head pointer
        end     // Load new data when enabled
    end
endmodule