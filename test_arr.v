`timescale 1ps / 1ps
`include "pe_3x3.v"

module tb_pe_array_3x3;

    // Clock, enable, reset
    reg clk;
    reg en;
    reg rst;

    // Flattened inputs and output
    reg  [199:0] ifmap_in_flat;   // 25 x 16-bit
    reg  [71:0] filter_in_flat;  // 9 x 16-bit
    reg [71:0] sum_out_flat;    // 9 x 16-bit

    wire [7:0] psum_test0, psum_test1, psum_test2; // Output for testing
    wire [7:0] sum_test0, sum_test1, sum_test2; // Output for testing

    wire  [199:0] ifmap_in;   // 25 x 16-bit
    wire  [71:0] filter_in;  // 9 x 16-bit

    assign ifmap_in = ifmap_in_flat;
    assign filter_in = filter_in_flat;
    // Instantiate the DUT
    pe_array_3x3 uut (
        .clk(clk),
        .en(~rst),
        .rst(rst),
        .ifmap_in_flat(ifmap_in_flat),
        .filter_in_flat(filter_in_flat),
        .sum_out_flat(sum_out_flat)

        //.psum_test0(psum_test0)
        // .psum_test1(psum_test1),
        // .psum_test2(psum_test2),

        // .sum_test0(sum_test0),
        // .sum_test1(sum_test1),
        // .sum_test2(sum_test2)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    
    integer i;
    
    initial begin
        $dumpfile("test_arr.vcd"); 
        $dumpvars(0, tb_pe_array_3x3);
        // Initialize signals
        clk = 0;
        en = 0;
        rst = 1;

        //#10;

        en = 1;
        
        // Initialize ifmap (25 x 16-bit = 400-bit)
        for (i = 0; i < 25; i = i + 1) begin
            ifmap_in_flat[i*8 +: 8] = i + 1; // [1..25]
        end
        
        // Initialize filter (9 x 16-bit = 144-bit)
        for (i = 0; i < 9; i = i + 1) begin
            filter_in_flat[i*8 +: 8] = i + 3; // Filter = 1s
        end
        
        #10;
        rst = 0;
        // Run for 50 cycles to collect results
        #120;

        // Stop simulation
        $finish;
    end

    // Optional: Monitor output
    always @(posedge clk) begin
        $display("Time = %t | sum_out_flat = %h", $time, sum_out_flat);
    end

endmodule
