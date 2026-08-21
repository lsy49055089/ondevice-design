`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/17 16:15:36
// Design Name: 
// Module Name: watch
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


module watch (
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
    output [3:0] led
);

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [MSEC_WIDTH - 1 : 0] w_msec;
    wire [ SEC_WIDTH - 1 : 0] w_sec;
    wire [ MIN_WIDTH - 1 : 0] w_min;
    wire [HOUR_WIDTH - 1 : 0] w_hour;
    wire w_btnR, w_btnL, w_btnD, w_btnU;
    wire [1:0] w_mode;
    wire [1:0] w_led;


    parameter NORMAL = 0, SEC = 1, MIN = 2, HOUR = 3;

    assign led = (w_mode == NORMAL) ? 4'b0001:
                 (w_mode == SEC)    ? 4'b0010: 
                 (w_mode == MIN)    ? 4'b0100: 4'b1000;

    wire btnU_sec = (w_mode == SEC) ? w_btnU : 0;
    wire btnU_min = (w_mode == MIN) ? w_btnU : 0;
    wire btnU_hour = (w_mode == HOUR) ? w_btnU : 0;

    wire btnD_sec = (w_mode == SEC) ? w_btnD : 0;
    wire btnD_min = (w_mode == MIN) ? w_btnD : 0;
    wire btnD_hour = (w_mode == HOUR) ? w_btnD : 0;

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



    watch_control_unit U_COUTROL_UNIT (
        .clk   (clk),
        .rst   (rst),
        .i_btnR(sw[1]&w_btnR),  // right
        .i_btnL(sw[1]&w_btnL),  // left
        .sw    (sw),
        .o_led (w_led),
        .o_mode(w_mode)
    );




    watch_datapath U_STOPWATCH_DATAPATH (
        .clk        (clk),
        .rst        (rst),
        .i_btnU_sec (btnU_sec),
        .i_btnU_min (btnU_min),
        .i_btnU_hour(btnU_hour),

        .i_btnD_sec (btnD_sec),
        .i_btnD_min (btnD_min),
        .i_btnD_hour(btnD_hour),
        .msec       (msec),
        .sec        (sec),
        .min        (min),
        .hour       (hour)
    );


    //    fnd_controller U_FND_CTRL (
    //        .sw  (sw[0]),   // sw[0], 0 : msec_sec, 1 : min_hour




endmodule
