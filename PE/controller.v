`include "adder.v"
`include "filter_spad.v"
`include "ifmap_spad.v"
`include "parsum_spad.v"
`include "mult.v"

module controller(
    input  wire        clk,
    input  wire        rst,       // Synchronous reset
    input  wire        en,        // Enable signal
    input  wire [7:0]  a,         // Activation input
    input  wire [7:0]  b,         // Weight input
    output reg  [7:0]  add_out,   // Output of adder
    output reg  [7:0]  mult_out,  // Output of multiplier
    output reg  [7:0]  ifmap_out, // Output from ifmap_spad
    output reg  [7:0]  filter_out,// Output from filter_spad
    output reg  [7:0]  parsum_out // Output from parsum_spad
);

    adder u_adder (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(a),
        .b(b),
        .add(add_out)
    );

    mult u_mult (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(a),
        .b(b),
        .mult(mult_out)
    );

    ifmap_spad u_ifmap_spad (
        .clk(clk),
        .rd(en),
        .wr(en),
        .addr(4'b0000), // Example address
        .data_in(a),   // Example data input
        .data_out(ifmap_out)
    );

    filter_spad u_filter_spad (
        .clk(clk),
        .rd(en),
        .wr(en),
        .addr(6'b000000), // Example address
        .data_in(b),     // Example data input
        .data_out(filter_out)
    );

    parsum_spad u_parsum_spad (
        .clk(clk),
        .rd(en),
        .wr(en),
        .addr(6'b000000), // Example address
        .data_in(add_out),// Example data input from adder output
        .data_out(parsum_out)
)
endmodule