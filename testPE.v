`timescale 1ps/1ps
`include "PE.v"

module tb_pe;

    // Clock and reset
    reg clk, rst;

    // Control
    reg en;

    // Address
    reg [3:0]  addr_ifmap;
    reg [7:0]  addr_filter;
    reg [4:0]  addr_psum;

    // Write enables
    reg wr_en_ifmap;
    reg wr_en_filter;
    reg wr_en_psum;

    // Data inputs
    reg [15:0] input_ifmap;
    reg [15:0] input_filter;
    reg [15:0] input_psum;

    // Output
    wire [15:0] output_psum;

    // Clock generator: 10ns period
    always #5 clk = ~clk;

    // Instantiate DUT
    pe dut (
        .clk(clk),
        .rst(rst),
        .en(en),

        .addr_ifmap(addr_ifmap),
        .addr_filter(addr_filter),
        .addr_psum(addr_psum),

        .wr_en_psum(wr_en_psum),
        .input_psum(input_psum),

        .wr_en_ifmap(wr_en_ifmap),
        .input_ifmap(input_ifmap),

        .wr_en_filter(wr_en_filter),
        .input_filter(input_filter),

        .output_psum(output_psum)
    );

    initial begin
        $dumpfile("testPE.vcd");
        $dumpvars(0, tb_pe);
        //$display("Simple IFMAP SPAD Testbench");

        clk = 0;
        rst = 1;
        en = 0;

        addr_ifmap = 0;
        addr_filter = 0;
        addr_psum = 0;

        wr_en_ifmap = 0;
        wr_en_filter = 0;
        wr_en_psum = 0;

        input_ifmap = 0;
        input_filter = 0;
        input_psum = 0;

        // Reset system
        #10;
        rst = 0;

        // Write ifmap[0] = 3
        wr_en_ifmap = 1;
        input_ifmap = 16'd3;
        addr_ifmap = 4'd0;
        #10;
        wr_en_ifmap = 0;

        // Write filter[0] = 2
        wr_en_filter = 1;
        input_filter = 16'd2;
        addr_filter = 8'd0;
        #10;
        wr_en_filter = 0;

        // Write psum[0] = 10
        wr_en_psum = 1;
        input_psum = 16'd10;
        addr_psum = 5'd0;
        #10;
        wr_en_psum = 0;

        // Run PE: compute 3 * 2 + 10 = 16
        en = 1;
        #10;
        en = 0;

        // Wait for result
        #10;
        $display("Output Psum = %d", output_psum);
        if (output_psum == 16'd16)
            $display(" TEST PASSED");
        else
            $display(" TEST FAILED");

        $finish;
    end

endmodule
