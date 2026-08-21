`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/02 14:02:16
// Design Name: 
// Module Name: uart_fifo_whole
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


module uart_fifo_whole(
        input        clk,
        input        rst,
        input        rx,
        input [5:0]  sec_clock,
        input [5:0]  sec_sw,
        input [5:0]  min_clock,
        input [5:0]  min_sw,
        input [4:0]  hour_clock,
        input [4:0]  hour_sw,
        input [8:0]  dist,
        input [7:0]  hum,
        input [7:0]  temp,
        output       R,
        output       L,
        output       U,
        output       D,
        output [1:0] M,
        output [1:0] T,
        output       tx
    );
    wire w_sender_push;
    wire [7:0] w_uart_fifo_pop_data,w_uart_fifo_push_data;
    wire w_S;
    wire [1:0] w_M;
    wire [1:0]  w_T;
    assign M=w_M;
    assign T=w_T;

    uart_fifo U_UART_FIFO(
    .clk(clk),
    .rst(rst),
    .uart_fifo_push_data(w_uart_fifo_push_data),
    .rx(rx),
    .push(w_sender_push),
    .uart_fifo_pop_data(w_uart_fifo_pop_data),
    .tx(tx)
);
    ascii_decoder U_ASCII_DECODER(
        .clk(clk),
        .rst(rst),
        .ascii_text(w_uart_fifo_pop_data),
        .R(R),
        .L(L),
        .U(U),
        .D(D),
        .M(w_M),
        .T(w_T),
        .S(w_S)
    );
    top_ascii_sender U_TOP_ASCII_SENDER(
    .clk(clk),
    .rst(rst),
    .mode(w_M),
    .hum_or_temp_sel(w_T),
    .start(w_S),
    .sec_clock(sec_clock),
    .sec_sw(sec_sw),
    .min_clock(min_clock),
    .min_sw(min_sw),
    .hour_clock(hour_clock),
    .hour_sw(hour_sw),
    .dist(dist),
    .hum(hum),
    .temp(temp),
    .pop_data(w_uart_fifo_push_data),
    .push(w_sender_push)
);
    
endmodule
