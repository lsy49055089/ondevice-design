`timescale 1ns / 1ps



module top_stopwatch_watch (
    input        clk,
    input        rst,
    input        btnR,
    input        btnL,
    input        btnU,
    input        btnD,
    input  [1:0] sw,
    output [4:0] hour,
    output [5:0] sec,
    output [5:0] min,
    output [6:0] msec,
    output [1:0] led
);

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [MSEC_WIDTH - 1 : 0] w_msec;
    wire [ SEC_WIDTH - 1 : 0] w_sec;
    wire [ MIN_WIDTH - 1 : 0] w_min;
    wire [HOUR_WIDTH - 1 : 0] w_hour;

    wire w_runstop, w_clear, w_mode;
    wire w_btnR, w_btnL, w_btnD, w_btnU;
    wire w_moment_hold, w_moment_capture;

    // reg [MSEC_WIDTH - 1 : 0] r_moment_w_msec;
    // reg [ SEC_WIDTH - 1 : 0] r_moment_w_sec;
    // reg [ MIN_WIDTH - 1 : 0] r_moment_w_min;
    // reg [HOUR_WIDTH - 1 : 0] r_moment_w_hour;

    assign led[0] = sw[0]; 
    assign led[1] = sw[1];
    button_debounce U_BTNR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );
    button_debounce U_BTNL (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );
    button_debounce U_BTNU (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),
        .o_btn(w_btnU)
    );
    button_debounce U_BTND (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );

    control_unit U_COUTROL_UNIT (
        .clk       (clk),
        .rst       (rst),
        .i_run_stop((!sw[1])&w_btnR),
        .i_clear   ((!sw[1])&w_btnL),
        .i_mode    ((!sw[1])&w_btnD),
        .i_moment    ((!sw[1])&w_btnU),
        .o_mode    (w_mode),
        .o_clear   (w_clear),
        .o_run_stop(w_runstop),
        .o_moment_hold(w_moment_hold),      // ++
        .o_moment_capture(w_moment_capture) 
    );

    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk             (clk),
        .rst             (rst),
        .i_runstop       (w_runstop),
        .i_clear         (w_clear),
        .i_mode          (w_mode),
        .i_moment_hold   (w_moment_hold),
        .i_moment_capture(w_moment_capture),
        .msec            (msec),
        .sec             (sec),
        .min             (min),
        .hour            (hour)
    );


endmodule