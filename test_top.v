// `include "top.v"

// `timescale 1ps/1ps

// module tb_top;

//   reg clk;
//   reg done_serial = 0; 
//   reg rst;
//   reg en;
//   reg [7:0] in_ifmap;
//   reg [7:0] in_filter;
//   wire [7:0] out;


//   // Instantiate DUT
//   top uut (
//     .clk(clk),
//     .rst(rst),
//     .done_serial(done_serial),
//     .en(en),
//     .in_ifmap(in_ifmap),
//     .in_filter(in_filter),
//     .out(out)
//   );

//   // Clock: 10ns period
//   always #5 clk = ~clk;

//   initial begin
//     // Initial values
//     $dumpfile("test_top.vcd"); 
//     $dumpvars(0, tb_top);



//     clk = 0;
//     rst = 1;
//     en  = 0 ;
//     in_ifmap  = 0;
//     in_filter = 0;
//     done_serial = 0;

//     // Reset active
//     #20;
//     rst = 0;
//     en  = 1;
//     done_serial = 1;

//     // Feed in 4 known values
//     @(posedge clk); in_ifmap = 8'd12;
//     @(posedge clk); in_ifmap = 8'd11;
//     @(posedge clk); in_ifmap = 8'd10;
//     @(posedge clk); in_ifmap = 8'd9;
//     @(posedge clk); in_ifmap = 8'd8;

//     @(posedge clk); in_ifmap = 8'd7;
//     @(posedge clk); in_ifmap = 8'd6;
//     @(posedge clk); in_ifmap = 8'd5;
//     @(posedge clk); in_ifmap = 8'd4;
//     @(posedge clk); in_ifmap = 8'd3;

//     @(posedge clk); in_ifmap = 8'd2;
//     @(posedge clk); in_ifmap = 8'd1;
//     @(posedge clk); in_ifmap = 8'd1;
//     @(posedge clk); in_ifmap = 8'd1;
//     @(posedge clk); in_ifmap = 8'd1;
    
//     @(posedge clk); in_ifmap = 8'd1;
    
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd1;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd2;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd3;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd4;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd5;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd6;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd7;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd8;
//     @(posedge clk); in_ifmap = 8'd1; in_filter = 8'd9;

//     // Stop providing inputs
//     @(posedge clk);
//     done_serial = 0;
//     en = 1;
//     in_ifmap  = 0;
//     in_filter = 0;

//     // Observe output for some cycles
//     #70;
//     done_serial = 1;
//     rst = 1;
//     @(posedge clk);
//     rst = 0;
//     #200;

    
//     $finish;
//   end
  
//   always @(posedge clk) begin
//     $display("out = %h", out);
//   end
// endmodule
`include "top.v"

`timescale 1ps/1ps

module tb_top;

  reg clk;
  reg rst;
  reg en;
  reg done_serial1;
  reg done_serial2;
  reg done_para;
  reg [7:0] in_ifmap;
  reg [7:0] in_filter;
  wire [7:0] out;

  // file handle + biến đọc
  integer fd_ifmap, fd_filter, fd_out;
  integer r_ifmap, r_filter, r_out;
  integer val_ifmap, val_filter, val_out;

  // Instantiate DUT
  top uut (
    .clk(clk),
    .rst(rst),
    .done_serial1(done_serial1),
    .done_serial2(done_serial2),
    .done_para(done_para),
    .en(en),
    .in_ifmap(in_ifmap),
    .in_filter(in_filter),
    .out(out)
  );

  // Clock: 10ns
  always #5 clk = ~clk;

  initial begin
    $dumpfile("test_top.vcd");
    $dumpvars(0, tb_top);

    clk = 0;
    rst = 1;
    en  = 0;
    done_serial1 = 0;
    done_serial2 = 0;
    done_para = 0;
    in_ifmap  = 0;
    in_filter = 0;

    // mở file
    fd_ifmap = $fopen("img.txt", "r");
    fd_filter = $fopen("kernel.txt", "r");
    fd_out = $fopen("result.txt","w");
    if (fd_out == 0) begin
      $display("Error: cannot open result.txt");
      $finish;
    end
    if (fd_ifmap == 0 || fd_filter == 0) begin
      $display("Error: cannot open input file(s)");
      $finish;
    end

    // Reset active
    #20;
    rst = 0;
    en  = 1;
    done_serial1 = 1;
    done_serial2 = 1;
  end

  // đọc tuần tự mỗi chu kỳ clock
  always @(posedge clk) begin
    if ((done_serial1 || done_serial2) && en && !rst) begin
      if (!$feof(fd_ifmap)) begin
        r_ifmap = $fscanf(fd_ifmap, "%d", val_ifmap);
        if (r_ifmap == 1) in_ifmap <= val_ifmap;
      end else begin
        //in_ifmap <= 0; // hết file thì 0
        done_serial1 <= 0; // dừng đọc file
      end

      if (!$feof(fd_filter)) begin
        r_filter = $fscanf(fd_filter, "%d", val_filter);
        if (r_filter == 1) in_filter <= val_filter;
      end else begin
        //in_filter <= 0;
        done_serial2 <= 0;
      end
    end
  end

  // ghi giá trị ra file, cách nhau bằng khoảng trắng
  always @(posedge clk) begin
    if (done_para & ~rst) begin
      $fwrite(fd_out, "%0d ", out);
    end
  end

  // giám sát output
  always @(posedge clk) begin
    $display("time=%0t, in_ifmap=%0d, in_filter=%0d, out=%0d",
             $time, in_ifmap, in_filter, out);
  end

  initial begin
    #345;  // chạy 500ns
    done_serial1 = 1;
    //done_serial2 = 0;
    rst = 1;
    done_para = 1;
    #10;
    rst = 0;
    #100;
    done_para = 0;
    $fclose(fd_ifmap);
    $fclose(fd_filter);
    $fclose(fd_out);
    $finish;
  end
endmodule
