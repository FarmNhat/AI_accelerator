`include "adder.v"
`include "filter_spad.v"
`include "ifmap_spad.v"
`include "parsum_spad.v"
`include "mult.v"

module controller(
    input  wire        clk,
    input  wire        rst,       // Synchronous reset
    input  wire        en,        // Enable signal

    input  wire        load_filter,
    input  wire        load_ifmap,

    input  wire [5:0] ld_addr_filter,
    input  wire [3:0] ld_addr_ifmap,

    input  wire [5:0] sel_filter_addr,     // Select filter address to start compute
    input  wire [3:0] sel_ifmap_addr,      // Select ifmap address to start compute

    input  wire [3:0] psum_sel,         //Select psum address to start compute

    input  wire [7:0] ifmap,         
    input  wire [7:0] filter,

    input wire [7:0] psum_in, // Input from other pe

    output reg  [7:0]  psum_out // Output from parsum_spad
);

    // does not support read load at the same time, after load all the data, start fetch
    reg [5:0] addr_filter;
    reg [3:0] addr_ifmap;

    always @(posedge clk) begin
        if (load_filter) begin
            addr_filter <= ld_addr_filter;
        end
        else begin
            addr_filter <= sel_filter_addr;
        end
    end

    always @(posedge clk) begin
        if (load_ifmap) begin
            addr_ifmap <= ld_addr_ifmap;
        end
        else begin
            addr_ifmap <= sel_ifmap_addr;
        end
    end

    reg [7:0] data_out_filter;
    reg [7:0] data_out_ifmap;

    adder u_adder (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(parsum_out), // Output from parsum_spad
        .b(mult_out), // Output from multiplier
        .add(psum_out) // Output from adder
    );

    mult u_mult (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(data_out_filter),
        .b(data_out_ifmap),
        .mult(mult_out)
    );

    ifmap_spad u_ifmap_spad (
        .clk(clk),
        .rd(~load_ifmap),
        .wr(load_ifmap),
        .addr(addr_ifmap), // Example address
        .data_in(ifmap),   // Example data input
        .data_out(data_out_ifmap)
    );

    filter_spad u_filter_spad (
        .clk(clk),
        .rd(~load_filter),
        .wr(load_filter),
        .addr(addr_filter), // Example address
        .data_in(filter),     // Example data input
        .data_out(data_out_filter)
    );

    /////////////////
    wire [7:0] parsum_out; //need fix
    
    // FIFO implementation
    parsum_spad u_parsum_spad (
        .clk(clk),
        .rd(en),
        .wr(1'b1), // Write enable signal
        //.addr_in(6'b000000), // Example address
        .addr_out(psum_sel), // Example address for output
        .data_in(psum_out),// Example data input from adder output
        .data_out(parsum_out)
)
endmodule