`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/17 11:35:19
// Design Name: 
// Module Name: watch_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module watch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                       clk,
    input                       rst,
    input                       i_btnU_sec,
    input                       i_btnU_min,
    input                       i_btnU_hour,
    input                       i_btnD_sec,
    input                       i_btnD_min,
    input                       i_btnD_hour,
    output [MSEC_WIDTH  -1 : 0] msec,
    output [ SEC_WIDTH - 1 : 0] sec,
    output [ MIN_WIDTH - 1 : 0] min,
    output [  HOUR_WIDTH - 1:0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;


    // hour
    watch_tick_counter #(
        .TIMES(24),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_hour_tick),  // from min o_tick
        .i_btnU      (i_btnU_hour),
        .i_btnD      (i_btnD_hour),
        .time_counter(hour),
        .o_tick      ()
    );


    // min
    watch_tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_min_tick),  // from sec o_tick
        .i_btnU      (i_btnU_min),
        .i_btnD      (i_btnD_min),
        .time_counter(min),
        .o_tick      (w_hour_tick)  // to hour i_tick
    );



    // sec
    watch_tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_sec_tick),  // from msec o_tick
        .i_btnU      (i_btnU_sec),
        .i_btnD      (i_btnD_sec),
        .time_counter(sec),
        .o_tick      (w_min_tick)   // to min i_tick
    );



    // msec
    watch_tick_counter #(
        .TIMES(100),
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_tick_100hz),  // from msec o_tick
        .i_btnU      (1'b0),
        .i_btnD      (1'b0),
        .time_counter(msec),
        .o_tick      (w_sec_tick)     // to sec i_tick
    );


    watch_tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .o_tick_100hz(w_tick_100hz)
    );







endmodule







module watch_tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
) (
    input                         clk,
    input                         rst,
    input                         i_tick,
    input                         i_btnU,
    input                         i_btnD,
    output     [BIT_WIDTH -1 : 0] time_counter,
    output reg                    o_tick
);


    // counter register
    reg [BIT_WIDTH - 1 : 0] counter_reg, counter_next;

    assign time_counter = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;

        end
    end
    // next counter CL : blocking
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
	if (i_tick && i_btnU)
	    counter_next = counter_reg + 2;
        else if (i_tick | i_btnU) begin
            counter_next = counter_reg + 1;
            if (counter_reg == TIMES - 1) begin
                counter_next = 0;
                o_tick = 1'b1;
            end else begin
                o_tick = 1'b0;
            end
        end

        if (i_btnD) begin
            counter_next = counter_reg - 1;
            if (counter_reg == 0) begin
                o_tick = 1'b1;
                counter_next = TIMES - 1;
            end else begin
                o_tick = 1'b0;

            end
        end
    end
endmodule





module watch_tick_gen_100hz (
    input      clk,
    input      rst,
    output reg o_tick_100hz
);
    // 100 Hz counter number * 1000 for simulation
    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT)-1 : 0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg  <= 0;
            o_tick_100hz <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg  <= 0;
                o_tick_100hz <= 1'b1;
            end else begin
                o_tick_100hz <= 1'b0;
            end
        end
    end
endmodule


