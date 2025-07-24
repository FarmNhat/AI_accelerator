
//`timescale 1ns / 1ps
module mult (
    input  wire        clk,
    input  wire        rst,       // Synchronous reset
    input  wire        en,        // Enable signal
    input  wire [7:0]  a,         // Activation input
    input  wire [7:0]  b,         // Weight input
    output reg  [7:0]  acc_out    // 8-bit output
);

    wire [15:0] mult_result;
    //wire [15:0] acc_result;

    assign mult_result = a * b;             // 8x8 multiplication
    //assign acc_result  = acc_out + mult_result; // Accumulate

    always @(posedge clk) begin
        if (rst)
            acc_out <= 8'd0;
        else if (en)
            acc_out <= mult_result[7:0];     // Truncate to 8-bit
    end

endmodule
