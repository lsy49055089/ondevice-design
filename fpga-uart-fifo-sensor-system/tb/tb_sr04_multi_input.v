`timescale 1ns / 1ps

module tb_sr04_multi_input();

    parameter US_DELAY = 1000, MS_DELAY = 1_000_000;


    reg clk, rst, sr04_start, tick_us, echo;
    reg [4:0] sw;
    wire trig, timeout;
    wire [8:0] distance;
    wire w_tick_us;

    sr04_controller dut (

        .clk(clk),
        .rst(rst),
        .sr04_start(sr04_start),
        .tick_us(w_tick_us),
        .sw(sw),
        .echo(echo),
        .trig(trig),
        .distance(distance),
        .timeout(timeout)
    );



    tick_gen_us dut2 (
        .clk(clk),
        .rst(rst),
        .tick_us(w_tick_us)
    );

always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sr04_start = 0;
        echo = 0;
        sw = 5'b01100; // sw[3] && sw[2] = 1

        #20;
        rst = 0;

        // start sr04
        @(posedge clk);
        sr04_start = 1;
        @(posedge clk);
        sr04_start = 0;
        //echo response

        #(US_DELAY * 15);
        // @(negedge trig);
        echo = 1;
        #(20*MS_DELAY);
        echo = 0;


        #(US_DELAY * 20);
        sr04_start = 1;
        @(posedge clk);
        sr04_start = 0;

        #(US_DELAY * 15);
        // @(negedge trig);
        echo = 1;
        #(30*MS_DELAY);
        echo = 0;



        #(US_DELAY * 20);
        sr04_start = 1;
        @(posedge clk);
        sr04_start = 0;

        #(MS_DELAY * 35);
        // @(negedge trig);
        echo = 1;
        #(30*MS_DELAY);
        echo = 0;




        #(US_DELAY * 20);
        sr04_start = 1;
        @(posedge clk);
        sr04_start = 0;

        #(US_DELAY * 20);
        // @(negedge trig);
        echo = 1;
        #(10*MS_DELAY);
        echo = 0;

        $stop;

    end



endmodule
