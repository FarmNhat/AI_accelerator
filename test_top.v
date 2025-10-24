
`timescale 1ps/1ps
`include "top.v"

module tb_top;

  reg clk;
  reg rst;
  reg en;
  reg [7:0] in_ifmap;
  reg [7:0] in_filter;
  wire [7:0] out;
  reg done;

  // file handles
  integer fd_ifmap, fd_filter, fd_out;
  integer r_ifmap, r_filter;
  integer val_ifmap, val_filter;

  // Instantiate DUT
  top #(
    .IFMAP(5),
    .FILTER(3)
  ) uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .in_ifmap(in_ifmap),
    .in_filter(in_filter),
    .out(out),
    .done(done)
  );

  // Clock generation (10 ns period)
  always #5 clk = ~clk;

  // =========================================================
  initial begin
    $dumpfile("test_top.vcd");
    $dumpvars(0, tb_top);

    // Initialize signals
    clk = 0;
    rst = 1;
    en  = 0;
    in_ifmap  = 0;
    in_filter = 0;

    // Open input/output files
    fd_ifmap  = $fopen("img.txt", "r");
    fd_filter = $fopen("kernel.txt", "r");
    fd_out    = $fopen("result.txt", "w");

    if (fd_ifmap == 0 || fd_filter == 0 || fd_out == 0) begin
      $display("ERROR: Cannot open input/output file(s)");
      $finish;
    end

    // Apply reset
    #20;
    rst = 0;
    en  = 1;
  end

  // =========================================================
  // Sequential input feeding
  // Reads 1 pixel/weight per clock until EOF
  // =========================================================
  always @(posedge clk) begin
    if (!rst && en) begin
      if (!$feof(fd_ifmap)) begin
        r_ifmap = $fscanf(fd_ifmap, "%d", val_ifmap);
        if (r_ifmap == 1) in_ifmap <= val_ifmap;
      end else begin
        in_ifmap <= 0;
      end

      if (!$feof(fd_filter)) begin
        r_filter = $fscanf(fd_filter, "%d", val_filter);
        if (r_filter == 1) in_filter <= val_filter;
      end else begin
        in_filter <= 0;
      end
    end
  end

  // =========================================================
  // Output logging
  // =========================================================
  always @(posedge clk) begin
    // Write output whenever nonzero (or replace with enable signal)
    if (out !== 0 && !rst) begin
      $fwrite(fd_out, "%0d ", out);
    end

    // Monitor console
    $display("time=%0t ns, in_ifmap=%0d, in_filter=%0d, out=%0d",
             $time, in_ifmap, in_filter, out);
  end

  // =========================================================
  // Simulation end
  // =========================================================
  initial begin
    // Run long enough for FSM: serial + 345 cycles compute + output
    #500;
    $display("Simulation finished.");
    $fclose(fd_ifmap);
    $fclose(fd_filter);
    $fclose(fd_out);
    $finish;
  end

endmodule

