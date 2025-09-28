`include "serial.v"
`include "parallel.v"
`include "pe_3x3.v"

module top(
    input  wire              clk,
    input  wire              done_serial,
    //input  wire              start_para,
    input  wire              rst,
    input  wire              en,
    input  wire [7:0]        in_ifmap,
    input  wire [7:0]        in_filter,
    output reg [7:0]         out
);

wire [199:0]ifmap_bus;
wire [71:0]filter_bus;
wire [71:0]out_bus;

serial #(.BUS(199)) serial_ifmap (
    .clk(clk),
    .rst(rst),
    .en(done_serial),
    .in_ifmap(in_ifmap),
    .out_ifmap(ifmap_bus)
);

serial #(.BUS(71)) serial_filter (
    .clk(clk),
    .rst(rst),
    .en(done_serial),
    .in_ifmap(in_filter),
    .out_ifmap(filter_bus)
);

pe_array_3x3 pe_array (
    .clk(clk),
    .en(~done_serial),
    .rst(done_serial),
    .ifmap_in_flat(ifmap_bus),
    .filter_in_flat(filter_bus),
    .sum_out_flat(out_bus)
);

paralel #(.BUS(71)) out_para (
    .clk(clk),
    .rst(rst),
    .en(done_serial),
    .in_ifmap(out_bus),
    .out_ifmap(out)
);

endmodule