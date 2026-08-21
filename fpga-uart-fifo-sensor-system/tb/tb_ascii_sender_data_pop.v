`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/01 15:13:27
// Design Name: 
// Module Name: tb_ascii_sender_data_pop
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


module tb_ascii_sender_data_pop();
    reg       clk;
    reg       rst;
    reg [1:0] mode;
    reg       start;
    reg       tick_gen;
    reg [7:0] sec_1_ascii;
    reg [7:0] sec_10_ascii;
    reg [7:0] min_1_ascii;
    reg [7:0] min_10_ascii;
    reg [7:0] hour_1_ascii;
    reg [7:0] hour_10_ascii;
    reg [7:0] hum_1_ascii;
    reg [7:0] hum_10_ascii;
    reg [7:0] temp_1_ascii;
    reg [7:0] temp_10_ascii;
    
    wire [7:0]pop_data;
    wire      push;
    wire w_tick_gen;
    tick_gen_us dut(
    .clk(clk),
    .rst(rst),
    .tick_us(w_tick_gen)
);
    ascii_sender_data_pop dut2(
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .start(start),
    .tick_gen(w_tick_gen),
    .sec_1_ascii(sec_1_ascii),
    .sec_10_ascii(sec_10_ascii),
    .min_1_ascii(min_1_ascii),
    .min_10_ascii(min_10_ascii),
    .hour_1_ascii(hour_1_ascii),
    .hour_10_ascii(hour_10_ascii),
    .hum_1_ascii(hum_1_ascii),
    .hum_10_ascii(hum_10_ascii),
    .temp_1_ascii(temp_1_ascii),
    .temp_10_ascii(temp_10_ascii),
    .pop_data(pop_data),
    .push(push)
);
    always #5 clk=~clk;
    initial begin
        clk=0;
        rst=1;
        mode=0;
        start=0;
        sec_1_ascii=0;
        sec_10_ascii=0;
        min_1_ascii=0;
        min_10_ascii=0;
        hour_1_ascii=0;
        hour_10_ascii=0;
        hum_1_ascii=0;
        hum_10_ascii=0;
        temp_1_ascii=0;
        temp_10_ascii=0;
        #1
        #10;
        rst=0;
        start=1;
        sec_1_ascii=8'h30;
        sec_10_ascii=8'h31;
        min_1_ascii=8'h32;
        min_10_ascii=8'h33;
        hour_1_ascii=8'h34;
        hour_10_ascii=8'h35;
        hum_1_ascii  =8'h36;
        hum_10_ascii =8'h37;
        temp_1_ascii =8'h38;
        temp_10_ascii=8'h39;
        #10;
        start=0;
        #20000;
        #1000;
        start=1;
        mode=1;
        sec_1_ascii=8'h30;
        sec_10_ascii=8'h31;
        min_1_ascii=8'h32;
        min_10_ascii=8'h33;
        hour_1_ascii=8'h34;
        hour_10_ascii=8'h35;
        hum_1_ascii  =8'h36;
        hum_10_ascii =8'h37;
        temp_1_ascii =8'h38;
        temp_10_ascii=8'h39;
        #10;
        start=0;
         #20000;
         #1000;
        start=1;
        mode=2;
        sec_1_ascii=8'h30;
        sec_10_ascii=8'h31;
        min_1_ascii=8'h32;
        min_10_ascii=8'h33;
        hour_1_ascii=8'h34;
        hour_10_ascii=8'h35;
        hum_1_ascii  =8'h36;
        hum_10_ascii =8'h37;
        temp_1_ascii =8'h38;
        temp_10_ascii=8'h39;
        #10;
        start=0;
         #20000;
         #1000;
        start=1;
        mode=3;
        sec_1_ascii=8'h30;
        sec_10_ascii=8'h31;
        min_1_ascii=8'h32;
        min_10_ascii=8'h33;
        hour_1_ascii=8'h34;
        hour_10_ascii=8'h35;
        hum_1_ascii  =8'h36;
        hum_10_ascii =8'h37;
        temp_1_ascii =8'h38;
        temp_10_ascii=8'h39;
        #10;
        start=0;
         #20000;
         
        #5000;
        $stop;
    end
    endmodule
