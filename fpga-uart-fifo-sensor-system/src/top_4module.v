`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/03 11:16:31
// Design Name: 
// Module Name: top_4module
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


module top_4module (
    input clk,
    input rst,
    input btn_R,
    input btn_L,
    input btn_U,
    input btn_D,
    input sw,
    input echo,
    input rx,
    
    output trig,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [5:0] led,
    output tx,


    inout dht11
);

    wire [7:0] w_humidity, w_humidity_dec, w_temperature, w_temperature_dec;
    wire [8:0] w_distance;
    wire w_timeout;
    wire w_valid;  // explanation

    wire [6:0] sw_msec, watch_msec;
    wire [5:0] sw_sec,  watch_sec;
    wire [5:0] sw_min,  watch_min;
    wire [4:0] sw_hour, watch_hour;
    wire [1:0] w_T,w_M;
 
wire [5:0] w_sec  = (w_M==2'b00) ?  sw_sec  : ((!(w_M[1]) && (w_M[0]))) ? watch_sec : 0;
wire [6:0] w_msec = (w_M==2'b00) ?  sw_msec : ((!(w_M[1]) && (w_M[0]))) ? watch_msec : 0; 
wire [5:0] w_min  = (w_M==2'b00) ?  sw_min  : ((!(w_M[1]) && (w_M[0]))) ? watch_min : 0;
wire [4:0] w_hour = (w_M==2'b00) ?  sw_hour : ((!(w_M[1]) && (w_M[0]))) ? watch_hour : 0;

wire w_uart_btn_R, w_uart_btn_L, w_uart_btn_U, w_uart_btn_D;


    TOP_sr04_controller U_SR04 (
        .clk     (clk),
        .rst     (rst),
        .btn_R   (btn_R),
        .uart_btn_R(w_uart_btn_R),
        .echo    (echo),
        .sw      ({sw,w_M,w_T}),          // btn 8,9
        .trig    (trig),
        .distance(w_distance),
        .timeout (w_timeout)
    );


    dht11 U_DHT11 (
        .clk(clk),
        .rst(rst),
        .btn_R(btn_R),
        .uart_btn_R(w_uart_btn_R),
        .sw({sw,w_M,w_T}),
        .humidity(w_humidity),
        .humidity_dec(w_humidity_dec),
        .temperature(w_temperature),
        .temperature_dec(w_temperature_dec),
        .valid(w_valid),  // explanation
        .dht11(dht11)
    );


    watch U_WATCH (
        .clk (clk),
        .rst (rst),
        .btnR(btn_R),
        .btnL(btn_L),
        .btnU(btn_U),
        .btnD(btn_D),
        .uart_btn_R(w_uart_btn_R),
        .uart_btn_L(w_uart_btn_L),
        .uart_btn_U(w_uart_btn_U),
        .uart_btn_D(w_uart_btn_D),
        .sw  ({sw,w_M,w_T}),
        .hour(watch_hour),
        .sec (watch_sec),
        .min (watch_min),
        .msec(watch_msec),
        .led (led[5:2])
    );

    top_stopwatch_watch U_STOPWATCH (
        .clk (clk),
        .rst (rst),
        .btnR(btn_R),
        .btnL(btn_L),
        .btnU(btn_U),
        .btnD(btn_D),
        .uart_btn_R(w_uart_btn_R),
        .uart_btn_L(w_uart_btn_L),
        .uart_btn_U(w_uart_btn_U),
        .uart_btn_D(w_uart_btn_D),
        .sw  ({sw,w_M,w_T}),
        .hour(sw_hour),
        .sec (sw_sec),
        .min (sw_min),
        .msec(sw_msec),
        .led (led[1:0])
    );

    fnd_ctrl_final #(
        .MSEC_WIDTH(7),
        .SEC_WIDTH (6),
        .MIN_WIDTH (6),
        .HOUR_WIDTH(5)
    ) U_FND_CTRL (
        .clk(clk),
        .rst(rst),
        .sw({sw,w_M,w_T}),
        .humidity(w_humidity),
        .humidity_dec(w_humidity_dec),
        .temperature(w_temperature),
        .temperature_dec(w_temperature_dec),
        .distance(w_distance),
        .timeout(w_timeout),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );



uart_fifo_whole U_FIFO_WHOLE(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .sec_clock(w_sec),
        .sec_sw(w_sec),
        .min_clock(w_min),
        .min_sw(w_min),
        .hour_clock(w_hour),
        .hour_sw(w_hour),
        .dist(w_distance),
        .hum(w_humidity),
        .temp(w_temperature),
        .R(w_uart_btn_R),
        .L(w_uart_btn_L),
        .U(w_uart_btn_U),
        .D(w_uart_btn_D),
        .M(w_M),
        .T(w_T),
        .tx(tx)
    );















endmodule
