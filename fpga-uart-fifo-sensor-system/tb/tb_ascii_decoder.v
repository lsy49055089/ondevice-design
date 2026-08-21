`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/29 19:38:34
// Design Name: 
// Module Name: tb_ascii_decoder
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


module tb_ascii_decoder();
    reg         clk;
    reg         rst;
    reg [7:0]   ascii_text;
    wire        R;
    wire        L;
    wire        U;
    wire        D;
    wire[1:0]   M;
    wire[1:0]   T;
    wire        S;
    ascii_decoder dut(
        .clk(clk),
        .rst(rst),
        .ascii_text(ascii_text),
        .R(R),
        .L(L),
        .U(U),
        .D(D),
        .M(M),
        .T(T),
        .S(S)
    );
    always #5 clk=~clk;
    initial begin
        clk=0;
        rst=1;
        ascii_text=0;
        #10;
        rst=0;
        #6
        ascii_text=8'h52;
        #10;
        ascii_text=8'h4C;
        #10;
        ascii_text=8'h55;
        #10;
        ascii_text=8'h44;
        #10;
        ascii_text=8'h4D;
        #10;
        ascii_text=8'h53;
        #10;
         ascii_text=8'h4D;
        #10;
         ascii_text=8'h4D;
        #10;
         ascii_text=8'h4D;
        #10;
         ascii_text=8'h54;
        #10
         ascii_text=8'h54;
        #10
         ascii_text=$random%256;
         #10;
         #10;
        $stop;
    end
endmodule
