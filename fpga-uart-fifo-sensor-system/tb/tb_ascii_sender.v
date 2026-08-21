`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/01 13:47:33
// Design Name: 
// Module Name: tb_ascii_sender
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


module tb_ascii_sender_data ();
    reg  [5:0] sec_clock;
    reg  [5:0] sec_sw;
    reg  [5:0] min_clock;
    reg  [5:0] min_sw;
    reg  [4:0] hour_clock;
    reg  [4:0] hour_sw;
    reg        mode;
    wire [7:0] sec_1_ascii;
    wire [7:0] sec_10_ascii;
    wire [7:0] min_1_ascii;
    wire [7:0] min_10_ascii;
    wire [7:0] hour_1_ascii;
    wire [7:0] hour_10_ascii;
    ascii_sender_data dut (
        .sec_clock(sec_clock),
        .sec_sw(sec_sw),
        .min_clock(min_clock),
        .min_sw(min_sw),
        .hour_clock(hour_clock),
        .hour_sw(hour_sw),
        .mode(mode),
        .sec_1_ascii(sec_1_ascii),
        .sec_10_ascii(sec_10_ascii),
        .min_1_ascii(min_1_ascii),
        .min_10_ascii(min_10_ascii),
        .hour_1_ascii(hour_1_ascii),
        .hour_10_ascii(hour_10_ascii)
    );
    initial begin
        sec_clock=0;
        sec_sw=0;
        min_clock=0;
        min_sw=0;
        hour_clock=0;
        hour_sw=0;
        mode=0;
        #10
        sec_clock=10;
        min_clock=20;
        hour_clock=04;
        #10;
        mode=1;
        sec_sw=21;
        min_sw=31;
        hour_sw=15;
        #10;
        $stop;
    end
endmodule
