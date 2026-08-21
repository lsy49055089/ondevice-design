`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/18 13:32:06
// Design Name: 
// Module Name: tb_watch
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


module tb_watch ();

    reg clk, rst, btnR, btnL, btnD, btnU;
    reg  [1:0] sw;

    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [5:0] led;



    toptop U_TOP (
        .clk (clk),
        .rst (rst),
        .btnR(btnR),
        .btnL(btnL),
        .btnU(btnU),
        .btnD(btnD),
        .sw  (sw),

        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );


    always #5 clk = ~clk;

    initial begin

        clk  = 0;
        rst  = 1;
        btnR = 1'b0;
        btnL = 1'b0;
        btnU = 1'b0;
        btnD = 1'b0;
        sw   = 2'b10; 


        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        rst = 0;
        

        btnR = 1;
        #100_000;
        btnR = 0;       //HOUR

        #100_000;
        btnR = 1;
        #100_000;
        btnR = 0;       //MIN


        #100_000_000
        btnR = 1;
        #100_000;
        btnR = 0;       //SEC

        #100_000_000
        btnR = 1;
        #100_000;
        btnR = 0;       //NORMAL

        #100_000_000
        btnL = 1;
        #100_000;
        btnL = 0;       //SEC

        #100_000;
        btnL = 1;
        #100_000;
        btnL = 0;       //MIN

        #100_000_000
        btnL = 1;
        #100_000;
        btnL = 0;       //HOUR

        #100_000_000
        btnL = 1;
        #100_000;
        btnL = 0;       //NORMAL

        #100_000_000
        btnU = 1;
        #100_000;
        btnU = 0;       //

        #360_000_000
        $stop;






    end



endmodule






