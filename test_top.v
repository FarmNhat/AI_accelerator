`include "top.v"

`timescale 1ps/1ps

module tb_top;

  reg clk;
  reg done_serial = 0; 
  reg rst;
  reg en;
  reg [7:0] in_ifmap;
  reg [7:0] in_filter;
  wire [7:0] out;

  // Instantiate DUT
  top uut (
    .clk(clk),
    .rst(rst),
    .done_serial(done_serial),
    .en(en),
    .in_ifmap(in_ifmap),
    .in_filter(in_filter),
    .out(out)
  );

  // Clock: 10ns period
  always #5 clk = ~clk;

  initial begin
    // Initial values
    $dumpfile("test_top.vcd"); 
    $dumpvars(0, tb_top);

    clk = 0;
    rst = 1;
    en  = 0 ;
    in_ifmap  = 0;
    in_filter = 0;
    done_serial = 0;

    // Reset active
    #20;
    rst = 0;
    en  = 1;
    done_serial = 1;

    // Feed in 4 known values
    @(posedge clk); in_ifmap = 8'd12;
    @(posedge clk); in_ifmap = 8'd11;
    @(posedge clk); in_ifmap = 8'd10;
    @(posedge clk); in_ifmap = 8'd9;
    @(posedge clk); in_ifmap = 8'd8;

    @(posedge clk); in_ifmap = 8'd7;
    @(posedge clk); in_ifmap = 8'd6;
    @(posedge clk); in_ifmap = 8'd5;
    @(posedge clk); in_ifmap = 8'd4;
    @(posedge clk); in_ifmap = 8'd3;

    @(posedge clk); in_ifmap = 8'd2;
    @(posedge clk); in_ifmap = 8'd1;
    @(posedge clk); in_ifmap = 8'd1;
    @(posedge clk); in_ifmap = 8'd1;
    @(posedge clk); in_ifmap = 8'd1;
    
    @(posedge clk); in_ifmap = 8'd1;
    
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd1;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd2;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd3;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd4;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd5;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd6;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd7;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd8;
    @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd9;

    // Stop providing inputs
    @(posedge clk);
    done_serial = 0;
    en = 1;
    in_ifmap  = 0;
    in_filter = 0;

    // Observe output for some cycles
    #70;
    done_serial = 1;
    rst = 1;
    @(posedge clk);
    rst = 0;
    #200;

    
    $finish;
  end
  
  always @(posedge clk) begin
    $display("out = %h", out);
  end
endmodule
