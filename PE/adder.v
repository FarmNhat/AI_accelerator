
module adder (
    input  wire        clk,
    input  wire        rst,       // Synchronous reset
    input  wire        en,        // Enable signal
    input  wire [7:0]  a,         // Activation input
    input  wire [7:0]  b,         // Weight input
    output reg  [7:0]  add    // 8-bit output
);

    wire [15:0] add_result;
    //wire [15:0] acc_result;

    assign add_result = a + b;             // 8x8 multiplication
    //assign acc_result  = add + mult_result; // Accumulate

    always @(posedge clk) begin
        if (rst)
            add <= 8'd0;
        else if (en)
            add <= add_result[7:0];     // Truncate to 8-bit
    end

endmodule
