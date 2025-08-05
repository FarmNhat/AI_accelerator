// `include "ifmap.v"
// `include "filter.v"
 `include "psum_acc.v"

module pe (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input reg [15:0] input_ifmap,   // external input ifmap (optional override)
    input wire [15:0] input_filter,  // external input filter (optional override)
    output wire [15:0] output_psum     // final output psum
);

    wire [31:0] mult_result;
    wire [15:0] acc_result;

    assign mult_result = rst ? 32'd0 : input_ifmap * input_filter; // Multiplication result
    assign output_psum = en ? acc_result : 16'd0;

    psum_acc psum_acc_inst (
        .clk(clk),
        .rst(rst),
        .en(en), // Enable signal
        .psum_in(mult_result[15:0]), // Take lower 16 bits of multiplication result
        .accum_out(output_psum)
    );


endmodule
