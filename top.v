// `include "serial.v"
// `include "parallel.v"
// `include "pe_3x3.v"

// module top(
//     input  wire              clk,
//     input  wire              done_serial1,  // =1 là chế độ đọc serial
//     input  wire              done_serial2,
//     input  wire              done_para,
//     input  wire              rst,
//     input  wire              en,
//     input  wire [7:0]        in_ifmap,
//     input  wire [7:0]        in_filter,
//     output reg [7:0]         out
// );

// wire [199:0]ifmap_bus;
// wire [71:0]filter_bus;
// wire [71:0]out_bus;

// serial #(.BUS(199)) serial_ifmap (
//     .clk(clk),
//     .rst(rst),
//     .en(done_serial1),
//     .in_ifmap(in_ifmap),
//     .out_ifmap(ifmap_bus)
// );

// serial #(.BUS(71)) serial_filter (
//     .clk(clk),
//     .rst(rst),
//     .en(done_serial2),
//     .in_ifmap(in_filter),
//     .out_ifmap(filter_bus)
// );

// pe_array_3x3 pe_array (
//     .clk(clk),
//     .en(~done_serial1),
//     .rst(done_serial1),
//     .ifmap_in_flat(ifmap_bus),
//     .filter_in_flat(filter_bus),
//     .sum_out_flat(out_bus)
// );

// paralel #(.BUS(71)) out_para (
//     .clk(clk),
//     .rst(rst),
//     .en(done_para),
//     .in_ifmap(out_bus),
//     .out_ifmap(out)
// );

// endmodule


`include "serial.v"
`include "parallel.v"
`include "pe_3x3.v"

module top#(
    parameter IFMAP=5,
    parameter FILTER=3,
    parameter OUT = IFMAP - FILTER + 1
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              en,
    input  wire [7:0]        in_ifmap,
    input  wire [7:0]        in_filter,
    output reg  [7:0]        out,
    output reg              done
);

    // FSM States
    localparam IDLE         = 3'd0;
    localparam SERIAL_LOAD_1  = 3'd1;
    localparam SERIAL_LOAD_2  = 3'd2;
    localparam COMPUTE      = 3'd3;
    localparam PARALLEL_OUT = 3'd4;
    localparam DONE         = 3'd5;

    reg [2:0] state, next_state;
    reg [8:0] compute_cnt; // count up to 345
    reg done_serial1, done_serial2, done_para;

    wire [199:0] ifmap_bus;
    wire [71:0]  filter_bus;
    wire [71:0]  out_bus;
    wire done_compute;

    // ========== SERIAL LOAD ==========
    serial #(.BUS(IFMAP*IFMAP*8 - 1)) serial_ifmap (
        .clk(clk),
        .rst(rst),
        .en(done_serial1),
        .in_ifmap(in_ifmap),
        .out_ifmap(ifmap_bus)
    );

    serial #(.BUS(FILTER*FILTER*8 - 1)) serial_filter (
        .clk(clk),
        .rst(rst),
        .en(done_serial2),
        .in_ifmap(in_filter),
        .out_ifmap(filter_bus)
    );

    // ========== PE ARRAY ==========
    pe_array_3x3 #(
    .IFMAP(IFMAP), 
    .FILTER(FILTER), 
    .OUT(OUT))
    pe_array (
        .clk(clk),
        .en(~done_serial1),
        .rst(done_serial1),
        .ifmap_in_flat(ifmap_bus),
        .filter_in_flat(filter_bus),
        .sum_out_flat(out_bus),
        .done_compute(done_compute)
    );

    // ========== PARALLEL OUTPUT ==========
    paralel #(.BUS(OUT*OUT*8 - 1)) out_para (
        .clk(clk),
        .rst(rst),
        .en(done_para),
        .in_ifmap(out_bus),
        .out_ifmap(out)
    );

    // ========== FSM NEXT STATE LOGIC ==========
    always @(posedge clk) begin
        //next_state = state;
        if (rst) begin
            state         <= IDLE;
            compute_cnt   <= 0;
            done_serial1  <= 0;
            done_serial2  <= 0;
            done_para     <= 0;
            done          <= 0;
            //out           <= 0;
        end else begin
        case (state)
            IDLE: 
                if (en) begin
                    compute_cnt  <= 0;
                    done_serial1 <= 1;
                    done_serial2 <= 1;
                    done_para    <= 0;
                    state = SERIAL_LOAD_1;
                end
            SERIAL_LOAD_1: begin
                compute_cnt  <= compute_cnt + 1;
                if (compute_cnt == FILTER*FILTER - 1)begin
                    done_serial1 = 1;
                    done_serial2 = 0;
                    state = SERIAL_LOAD_2;
                end
            end
            SERIAL_LOAD_2: begin
            compute_cnt  <= compute_cnt + 1;
                if (compute_cnt == IFMAP*IFMAP - 1)begin
                    done_serial1 <= 0;
                    done_serial2 <= 0;
                    compute_cnt <= 0;
                    state = COMPUTE;
                end    
            end
            COMPUTE:begin
            compute_cnt  <= compute_cnt + 1;
                if (done_compute == 1)begin
                    done_para <= 1;
                    compute_cnt <= 0;
                    state = PARALLEL_OUT;
                end
            end
            PARALLEL_OUT: begin
            compute_cnt  <= compute_cnt + 1;
                if(compute_cnt == OUT*OUT) begin
                    state = DONE;
                end
            end
            DONE: begin
                done <= 1;
                compute_cnt   <= 0;
                done_serial1  <= 0;
                done_serial2  <= 0;
                done_para     <= 0;
                done_para     <= 0;
            end
        endcase
    end
    end

endmodule
