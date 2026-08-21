`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/17 19:39:11
// Design Name: 
// Module Name: toptop
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


module toptop(
input clk,
input rst,
input btnR,
input btnL,
input btnU,
input btnD,
input [1:0] sw,

output [3:0] fnd_com,
output [7:0] fnd_data,
output [5:0] led
    );


    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [MSEC_WIDTH - 1 : 0] w_msec_0;
    wire [ SEC_WIDTH - 1 : 0] w_sec_0;
    wire [ MIN_WIDTH - 1 : 0] w_min_0;
    wire [HOUR_WIDTH - 1 : 0] w_hour_0;

    wire [MSEC_WIDTH - 1 : 0] w_msec_1;
    wire [ SEC_WIDTH - 1 : 0] w_sec_1;
    wire [ MIN_WIDTH - 1 : 0] w_min_1;
    wire [HOUR_WIDTH - 1 : 0] w_hour_1;

    wire [MSEC_WIDTH - 1 : 0] w_msec;
    wire [ SEC_WIDTH - 1 : 0] w_sec;
    wire [ MIN_WIDTH - 1 : 0] w_min;
    wire [HOUR_WIDTH - 1 : 0] w_hour;



watch U_WATCH(
    .clk(clk),
    .rst(rst),
    .btnR(btnR),
    .btnL(btnL),
    .btnU(btnU),
    .btnD(btnD),
    .sw(sw),

    .hour(w_hour_1),
    .sec(w_sec_1),
    .min(w_min_1),
    .msec(w_msec_1),
    .led(led[5:2])
);




top_stopwatch_watch U_STOPWATCH(
    .clk(clk),
    .rst(rst),
    .btnR(btnR),
    .btnL(btnL),
    .btnU(btnU),
    .btnD(btnD),
    .sw(sw),

    .hour(w_hour_0),
    .sec(w_sec_0),
    .min(w_min_0),
    .msec(w_msec_0),
    .led(led[1:0])
);


fnd_controller U_FND_CTRL(
    .clk(clk),
    .rst(rst),
    .sw(sw),    // sw[0], 0 : msec_sec, 1 : min_hour
    .msec(w_msec),
    .sec(w_sec),
    .min(w_min),
    .hour(w_hour),
    
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);





mux_2x1_final U_MUX_FINAL(

    .msec_0(w_msec_0),
    .sec_0(w_sec_0),
    .min_0(w_min_0),
    .hour_0(w_hour_0),
    .msec_1(w_msec_1),
    .sec_1(w_sec_1),
    .min_1(w_min_1),
    .hour_1(w_hour_1),
    .sel(sw[1]),

    .hour(w_hour),
    .sec(w_sec),
    .min(w_min),
    .msec(w_msec)
);



endmodule



module mux_2x1_final (

    input [6:0] msec_0,
    input [5:0] sec_0,
    input [5:0] min_0,
    input [4:0] hour_0,
    input [6:0] msec_1,
    input [5:0] sec_1,
    input [5:0] min_1,
    input [4:0] hour_1,
    input           sel,
    output [4:0] hour,
    output [5:0] sec,
    output [5:0] min,
    output [6:0] msec
);

assign  hour    = (sel) ? hour_1: hour_0;
assign  min    = (sel) ? min_1: min_0;
assign  sec    = (sel) ? sec_1: sec_0;
assign  msec    = (sel) ? msec_1: msec_0;



endmodule