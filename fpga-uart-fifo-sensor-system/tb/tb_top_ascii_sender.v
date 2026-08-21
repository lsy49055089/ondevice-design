`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/01 16:31:47
// Design Name: 
// Module Name: tb_top_ascii_sender
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


module tb_top_ascii_sender ();
    parameter BAUDRATE = 100_000_000 / 9600;
    reg        clk;
    reg        rst;
    reg  [1:0] mode;
    reg  [1:0] hum_or_temp_sel;
    reg        start;
    reg  [5:0] sec_clock;
    reg  [5:0] sec_sw;
    reg  [5:0] min_clock;
    reg  [5:0] min_sw;
    reg  [4:0] hour_clock;
    reg  [4:0] hour_sw;
    reg  [8:0] distance;
    reg  [7:0] hum;
    reg  [7:0] temp;
    wire [7:0] pop_data;
    wire       push;
    top_ascii_sender dut (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .hum_or_temp_sel(hum_or_temp_sel),
        .start(start),
        .sec_clock(sec_clock),
        .sec_sw(sec_sw),
        .min_clock(min_clock),
        .min_sw(min_sw),
        .hour_clock(hour_clock),
        .hour_sw(hour_sw),
        .distance(distance),
        .hum(hum),
        .temp(temp),
        .pop_data(pop_data),
        .push(push)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        mode = 0;
        hum_or_temp_sel = 0;
        start = 0;
        sec_clock = 0;
        sec_sw = 0;
        min_clock = 0;
        min_sw = 0;
        hour_clock = 0;
        hour_sw = 0;
        distance = 0;
        hum = 0;
        temp = 0;
        #1 
        #10;
        rst = 0;
        start = 1;
        sec_clock = $random % 60;
        sec_sw = $random % 60;
        min_clock = $random % 60;
        min_sw = $random % 60;
        hour_clock = $random % 24;
        hour_sw = $random % 24;
        distance = $random % 400;
        hum = $random % 90;
        temp = $random % 50;
        #10;
        start = 0;
        repeat(BAUDRATE*250) @(negedge clk);
        #1000;
        start = 1;
         mode = 1;
        sec_clock = $random % 60;
        sec_sw = $random % 60;
        min_clock = $random % 60;
        min_sw = $random % 60;
        hour_clock = $random % 24;
        hour_sw = $random % 24;
        distance = $random % 400;
        hum = $random % 90;
        temp = $random % 50;
        #10;
        start = 0;
        repeat(BAUDRATE*250) @(negedge clk);
        #1000;
        start = 1;
        mode = 2;
        sec_clock = $random % 60;
        sec_sw = $random % 60;
        min_clock = $random % 60;
        min_sw = $random % 60;
        hour_clock = $random % 24;
        hour_sw = $random % 24;
        distance = $random % 400;
        hum = $random % 90;
        temp = $random % 50;
        #10;
        start = 0;
        repeat(BAUDRATE*250) @(negedge clk);
        #1000;
        start = 1;
        mode = 3;
        sec_clock = $random % 60;
        sec_sw = $random % 60;
        min_clock = $random % 60;
        min_sw = $random % 60;
        hour_clock = $random % 24;
        hour_sw = $random % 24;
        distance = $random % 400;
        hum = $random % 90;
        temp = $random % 50;
        #10;
        start = 0;
        repeat(BAUDRATE*250) @(negedge clk);
        start = 1;
        mode = 2;
        hum_or_temp_sel=1;
        sec_clock = $random % 60;
        sec_sw = $random % 60;
        min_clock = $random % 60;
        min_sw = $random % 60;
        hour_clock = $random % 24;
        hour_sw = $random % 24;
        distance = $random % 400;
        hum = $random % 90;
        temp = $random % 50;
        #10;
        start = 0;
        repeat(BAUDRATE*250) @(negedge clk);
        #5000;
        $finish;
    end
endmodule
