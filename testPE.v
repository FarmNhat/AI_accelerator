`timescale 1ps/1ps
`include "PE.v"
module tb_pe;

    reg clk;
    reg rst;
    reg en;
    reg [15:0] input_ifmap;
    reg [15:0] input_filter;
    wire [15:0] output_psum;
    wire [15:0] psum_out2;
    // Instantiate the PE module
    wire [15:0] in_ifmap;
    wire [15:0] in_filter;

    assign in_ifmap = input_ifmap;
    assign in_filter = input_filter;
    pe uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .input_ifmap(in_ifmap),
        //.psum_out2(psum_out2), // This is not used in the PE module, but included for completeness
        .input_filter(in_filter),
        .output_psum(output_psum)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initial values
        $dumpfile("testPE.vcd"); 
        $dumpvars(0, tb_pe);
        clk = 0;
        
        rst = 1;
        en = 1; // Enable signal (not used in this test)

        // Reset pulse
        #5;
        rst = 0;
        en = 1;

        // Apply first input
    
        input_ifmap = 16'd3;
        input_filter = 16'd4;   // 3 * 4 = 12

        #10;
        input_ifmap = 16'd5;
        input_filter = 16'd6;   // 5 * 6 = 30 → psum = 12 + 30 = 42

        #10;
        input_ifmap = 16'd1;
        input_filter = 16'd2;   // 1 * 2 = 2 → psum = 42 + 2 = 44
        #10;
        en = 1; // Disable the PE to stop processing
        // Wait and observe
        #30;
        $finish; // End simulation
    end

endmodule
