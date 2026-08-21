`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/02 14:48:13
// Design Name: 
// Module Name: tb_uart_fifo_whole
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


module tb_uart_fifo_whole();
        parameter BAUD_DELAY=2000;
        parameter BAUD_PERIOD = ((100_000_000 / 9600) * 10)-BAUD_DELAY;
        reg [7:0] compare_data;
        reg        clk;
        reg        rst;
        reg        rx;
        reg [5:0]  sec_clock;
        reg [5:0]  sec_sw;
        reg [5:0]  min_clock;
        reg [5:0]  min_sw;
        reg [4:0]  hour_clock;
        reg [4:0]  hour_sw;
        reg [8:0]  distance;
        reg [7:0]  hum;
        reg [7:0]  temp;
        wire       R;
        wire       L;
        wire       U;
        wire       D;
        wire[1:0]  M;
        wire[1:0]  T;
        wire       tx;
        uart_fifo_whole dut(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .sec_clock(sec_clock),
        .sec_sw(sec_sw),
        .min_clock(min_clock),
        .min_sw(min_sw),
        .hour_clock(hour_clock),
        .hour_sw(hour_sw),
        .distance(distance),
        .hum(hum),
        .temp(temp),
        .R(R),
        .L(L),
        .U(U),
        .D(D),
        .M(M),
        .T(T),
        .tx(tx)
    );
    always #5 clk=~clk;
    
    integer i = 0;

    task SENDER_UART(input [7:0] send_data);
        //start
        begin
            rx = 0;
            #(BAUD_PERIOD);
            //data bit
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BAUD_PERIOD);

            end
            //stop bit
            rx = 1;
            #(BAUD_PERIOD);
        end
        //start bit
    endtask
    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        compare_data = 8'h52; //R
        @(negedge clk);
        @(negedge clk);

        rst = 0;
        SENDER_UART(compare_data);
        sec_clock = $random % 60;
        sec_sw = $random % 60;
        min_clock = $random % 60;
        min_sw = $random % 60;
        hour_clock = $random % 24;
        hour_sw = $random % 24;
        distance = $random % 400;
        hum = $random % 90;
        temp = $random % 50;
        compare_data=8'h53; //S
        SENDER_UART(compare_data);
        #(BAUD_PERIOD * 400);
        compare_data=8'h52; //R
        SENDER_UART(compare_data);
        #(BAUD_PERIOD * 400);
        compare_data=8'h4D; //M
        SENDER_UART(compare_data);
        #(BAUD_PERIOD * 400);
        compare_data=8'h53; //S
        SENDER_UART(compare_data);
        #(BAUD_PERIOD * 400);


        $stop;
    end
endmodule
