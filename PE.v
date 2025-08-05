// `include "ifmap.v"
// `include "filter.v"
// `include "psum.v"

module pe (
    input  wire        clk,
    input  wire        rst,
    input  wire        cnt,

    //input  wire        wr_en_psum,
    input wire [15:0] input_psum,     // external input psum (optional override)

    //input wire        wr_en_ifmap,  // write enable for ifmap
    input reg [15:0] input_ifmap,   // external input ifmap (optional override)

    //input wire        wr_en_filter, // write enable for filter
    input wire [15:0] input_filter,  // external input filter (optional override)

    output wire [15:0] output_psum     // final output psum
);

    // wire [15:0] ifmap_data;
    // wire [15:0] filter_data;
    // wire [15:0] psum_data;

    reg [31:0] mult_result;
    reg [15:0] acc_result;
    
    always @(posedge clk) begin
        if (rst) begin
            acc_result <= 16'd0;
        end else if (en) begin
            mult_result = input_ifmap * input_filter;
            acc_result = psum_data + mult_result[15:0]; // Use lower 16 bits of multiplication result
        end
    end

    assign output_psum = acc_result;




    // scratchpad_ifmap ifmap_pad (
    //     .clk(clk),
    //     .wr_en(wr_en_ifmap),
    //     .addr(addr_ifmap),
    //     .data_in(input_ifmap),
    //     .data_out(ifmap_data)
    // );

    // scratchpad_filter filter_pad (
    //     .clk(clk),
    //     .wr_en(wr_en_filter),
    //     .addr(addr_filter),
    //     .data_in(input_filter),
    //     .data_out(filter_data)
    // );

    // scratchpad_psum psum_pad (
    //     .clk(clk),
    //     .addr(addr_psum),
    //     .wr_en(wr_en_psum),
    //     .data_in(input_psum),
    //     .data_out(psum_data)
    // );


endmodule
