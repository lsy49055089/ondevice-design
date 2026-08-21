`timescale 1ns / 1ps

module tb_top_4module;

    reg clk;
    reg rst;
    reg btn_R, btn_L, btn_U, btn_D;
    reg sw;
    reg echo;
    reg rx;

    wire trig;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [5:0] led;
    wire tx;
    wire dht11;

    reg dht_drive_en;
    reg dht_drive_val;

    assign dht11 = dht_drive_en ? dht_drive_val : 1'bz;

    top_4module DUT (
        .clk(clk),
        .rst(rst),
        .btn_R(btn_R),
        .btn_L(btn_L),
        .btn_U(btn_U),
        .btn_D(btn_D),
        .sw(sw),
        .echo(echo),
        .rx(rx),
        .trig(trig),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led),
        .tx(tx),
        .dht11(dht11)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    parameter BAUD_PERIOD = 104_167; // 9600 baud, 1 bit time

    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 1'b1;
            #(BAUD_PERIOD);

            rx = 1'b0; // start bit
            #(BAUD_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i]; // LSB first
                #(BAUD_PERIOD);
            end

            rx = 1'b1; // stop bit
            #(BAUD_PERIOD);

            #(2_000_000);
        end
    endtask

    task CMD_R; begin uart_send_byte(8'h52); end endtask // R
    task CMD_L; begin uart_send_byte(8'h4C); end endtask // L
    task CMD_U; begin uart_send_byte(8'h55); end endtask // U
    task CMD_D; begin uart_send_byte(8'h44); end endtask // D
    task CMD_M; begin uart_send_byte(8'h4D); end endtask // M
    task CMD_T; begin uart_send_byte(8'h54); end endtask // T
    task CMD_S; begin uart_send_byte(8'h53); end endtask // S

    task dht_send_bit;
        input bit_value;
        begin
            dht_drive_en  = 1'b1;
            dht_drive_val = 1'b0;
            #(50_000);

            dht_drive_val = 1'b1;
            if (bit_value)
                #(70_000);
            else
                #(26_000);

            dht_drive_val = 1'b0;
            #(2_000);
        end
    endtask

    task dht_send_byte;
        input [7:0] data;
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                dht_send_bit(data[i]);
            end
        end
    endtask

    task dht11_response;
        input [7:0] hum;
        input [7:0] hum_dec;
        input [7:0] temp;
        input [7:0] temp_dec;
        reg [7:0] checksum;
        begin
            checksum = hum + hum_dec + temp + temp_dec;

            wait (dht11 === 1'bz);

            dht_drive_en  = 1'b1;
            dht_drive_val = 1'b0;
            #(80_000);

            dht_drive_val = 1'b1;
            #(80_000);

            dht_send_byte(hum);
            dht_send_byte(hum_dec);
            dht_send_byte(temp);
            dht_send_byte(temp_dec);
            dht_send_byte(checksum);

            dht_drive_en  = 1'b0;
            dht_drive_val = 1'b1;
        end
    endtask

    task sr04_echo_response;
        input integer distance_cm;
        begin
            wait (trig == 1'b1);
            wait (trig == 1'b0);

            #(100_000);

            echo = 1'b1;
            #(distance_cm * 58_000);
            echo = 1'b0;
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        btn_R = 0;
        btn_L = 0;
        btn_U = 0;
        btn_D = 0;
        sw = 0;
        echo = 0;
        rx = 1;
        dht_drive_en = 0;
        dht_drive_val = 1;

        #(1_000);
        rst = 0;
        #(5_000_000);

        // =========================================================
        // 1. STOPWATCH : R -> U -> wait -> S -> U -> S -> M
        // w_M = 00
        // =========================================================
        $display("===== STOPWATCH SCENARIO =====");
        CMD_R();
        CMD_U();
        #(200_000_000);
        CMD_S();
        CMD_U();
        CMD_S();
        CMD_M();                 // w_M: 00 -> 01, WATCH
        #(10_000_000);

        // =========================================================
        // 2. WATCH : L -> L -> sw -> U x3 -> S -> M
        // w_M = 01
        // =========================================================
        $display("===== WATCH SCENARIO =====");
        CMD_L();
        CMD_L();
        sw = 1'b1;
        CMD_U();
        CMD_U();
        CMD_U();
        CMD_S();
        CMD_M();                 // w_M: 01 -> 10, DHT11
        #(10_000_000);

        // =========================================================
        // 3. DHT11 : w_T 00/01/10/11 전체 확인
        // w_M = 10
        //
        // w_T = 00 : NONE
        // w_T = 01 : temperature
        // w_T = 10 : humidity
        // w_T = 11 : humidity + temperature
        // =========================================================
        $display("===== DHT11 SCENARIO : ALL w_T MODES =====");
        sw = 1'b0;

        // -------------------------
        // w_T = 00 : NONE
        // -------------------------
        $display("[DHT11] w_T = 00 : NONE");
        CMD_S();
        #(5_000_000);

        // -------------------------
        // w_T = 01 : Temperature
        // -------------------------
        $display("[DHT11] w_T = 01 : TEMPERATURE");
        CMD_T();                 // w_T: 00 -> 01

        fork
            begin
                CMD_R();
            end
            begin
                dht11_response(8'd55, 8'd0, 8'd24, 8'd0);
            end
        join

        #(5_000_000);
        CMD_S();
        #(5_000_000);

        // -------------------------
        // w_T = 10 : Humidity
        // -------------------------
        $display("[DHT11] w_T = 10 : HUMIDITY");
        CMD_T();                 // w_T: 01 -> 10

        fork
            begin
                CMD_R();
            end
            begin
                dht11_response(8'd61, 8'd0, 8'd25, 8'd0);
            end
        join

        #(5_000_000);
        CMD_S();
        #(5_000_000);

        // -------------------------
        // w_T = 11 : Humidity + Temperature
        // -------------------------
        $display("[DHT11] w_T = 11 : HUMIDITY + TEMPERATURE");
        CMD_T();                 // w_T: 10 -> 11

        fork
            begin
                CMD_R();
            end
            begin
                dht11_response(8'd70, 8'd0, 8'd26, 8'd0);
            end
        join

        #(5_000_000);
        CMD_S();
        #(5_000_000);

        CMD_M();                 // w_M: 10 -> 11, SR04
        #(10_000_000);

        // =========================================================
        // 4. SR04 : R -> S -> R -> S(None)
        // w_M = 11
        // =========================================================
        $display("===== SR04 SCENARIO =====");

        fork
            begin
                CMD_R();
            end
            begin
                sr04_echo_response(20);
            end
        join

        #(5_000_000);
        CMD_S();

        CMD_R();                 // no echo response -> timeout
        #(35_000_000);
        CMD_S();

        #(50_000_000);
        $display("===== TEST DONE =====");
        $finish;
    end

endmodule