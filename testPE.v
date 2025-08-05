`timescale 1ps / 1ps
`include "psum_acc.v"
module tb_psum_accumulator;

    reg clk;
    reg rst;
    reg [15:0] psum_in;
    wire [15:0] accum_out;

    // Instantiate the design under test (DUT)
    psum_accumulator dut (
        .clk(clk),
        .rst(rst),
        .psum_in(psum_in),
        .accum_out(accum_out)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        $dumpfile("testPE.vcd");
        $dumpvars(0, tb_psum_accumulator);

        clk = 0;
        rst = 1;
        psum_in = 0;

        // Hold reset for a few cycles
        #10;
        rst = 0;

        // Apply 3 input values
        psum_in = 16'd10;
        #10;
        psum_in = 16'd20;
        #10;
        psum_in = 16'd30;
        #10;

        // After 3rd input, expect output = 10 + 20 + 30 = 60
        $display("Accumulated Output: %d", accum_out);

        // Apply more values to test rolling behavior if needed
        psum_in = 16'd5;
        #10;
        psum_in = 16'd15;
        #10;
        psum_in = 16'd25;
        #10;
        $display("Accumulated Output: %d", accum_out);

        // End simulation
        $finish;
    end

endmodule
