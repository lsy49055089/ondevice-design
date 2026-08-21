`timescale 1ns / 1ps

module fnd_ctrl_final #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input       clk,
    input       rst,
    input [4:0] sw,

    input [7:0] humidity,
    input [7:0] humidity_dec,
    input [7:0] temperature,
    input [7:0] temperature_dec,
    input [8:0] distance,
    input timeout,
    input [MSEC_WIDTH  -1 : 0] msec,
    input [SEC_WIDTH - 1 : 0] sec,
    input [MIN_WIDTH - 1 : 0] min,
    input [HOUR_WIDTH - 1 : 0] hour,

    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire       w_1khz;
    wire [1:0] w_digit_sel;
    wire [3:0] w_digit;
    wire [7:0] w_bcd_data;
    wire       w_dot_mode;
    wire       w_dot_on;

    clk_div_1khz U_CLK_DIV_1KHZ (
        .clk   (clk),
        .rst   (rst),
        .o_1khz(w_1khz)
    );

    counter_4 U_COUNTER_4 (
        .clk      (w_1khz),
        .rst      (rst),
        .digit_sel(w_digit_sel)
    );

    decoder_2x4 U_DECODER_2X4 (
        .decoder_in(w_digit_sel),
        .fnd_com   (fnd_com)
    );

    fnd_datapath U_FND_DATAPATH (
        .sw       (sw),
        .digit_sel(w_digit_sel),

        .humidity       (humidity),
        .humidity_dec   (humidity_dec),
        .temperature    (temperature),
        .temperature_dec(temperature_dec),
        .distance       (distance),
        .timeout        (timeout),
        .msec           (msec),
        .sec            (sec),
        .min            (min),
        .hour           (hour),

        .digit   (w_digit),
        .dot_mode(w_dot_mode)
    );

    BCD_decoder U_BCD_DECODER (
        .bin     (w_digit),
        .bcd_data(w_bcd_data)
    );


    assign w_dot_on = w_dot_mode && (w_digit_sel == 2'b10);

    assign fnd_data = w_dot_on ? (w_bcd_data & 8'b0111_1111) :
                                 (w_bcd_data | 8'b1000_0000);

endmodule


module fnd_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input [4:0] sw,
    input [1:0] digit_sel,

    input [7:0] humidity,
    input [7:0] humidity_dec,
    input [7:0] temperature,
    input [7:0] temperature_dec,
    input [8:0] distance,
    input timeout,
    input [MSEC_WIDTH  -1 : 0] msec,
    input [SEC_WIDTH - 1 : 0] sec,
    input [MIN_WIDTH - 1 : 0] min,
    input [HOUR_WIDTH - 1 : 0] hour,

    output reg [3:0] digit,
    output reg       dot_mode
);

    reg [3:0] digit_1;
    reg [3:0] digit_10;
    reg [3:0] digit_100;
    reg [3:0] digit_1000;






    always @(*) begin
        digit_1    = 4'd0;
        digit_10   = 4'd0;
        digit_100  = 4'd0;
        digit_1000 = 4'd0;
        dot_mode   = 1'b0;
        casez (sw)
            5'b?1000: begin //dht11 none
                digit_1000 = 4'hA;
                digit_100  = 4'hB;
                digit_10   = 4'hC;
                digit_1    = 4'hD;
                dot_mode   = 1'b0;
            end
            5'b?1001: begin //dht11 
                digit_1000 = temperature / 10;
                digit_100  = temperature % 10;
                digit_10   = temperature_dec / 10;
                digit_1    = temperature_dec % 10;
                dot_mode   = 1'b1;
            end

            5'b?1010: begin //dht11 
                digit_1000 = humidity / 10;
                digit_100  = humidity % 10;
                digit_10   = humidity_dec / 10;
                digit_1    = humidity_dec % 10;
                dot_mode   = 1'b1;
            end

            5'b?1011: begin //dht11 
                digit_1000 = humidity / 10;
                digit_100  = humidity % 10;
                digit_10   = temperature / 10;
                digit_1    = temperature % 10;
                dot_mode   = 1'b1;
            end
            5'b?11??: begin // sr04
                if (timeout) begin
                    digit_1000 = 4'hA;
                    digit_100  = 4'hB;
                    digit_10   = 4'hC;
                    digit_1    = 4'hD;
                    dot_mode   = 1'b0;
                end else begin // sr04
                    digit_1000 = distance / 1000;
                    digit_100  = (distance / 100) % 10;
                    digit_10   = (distance / 10) % 10;
                    digit_1    = distance % 10;
                    dot_mode   = 1'b0;
                end
            end
            5'b000??: begin //stopwatch s,ms
                    digit_1000 = sec / 10;
                    digit_100  = sec % 10;
                    digit_10   = msec / 10;
                    digit_1    = msec % 10;
                    dot_mode   = 1'b1;
            end
            5'b100??: begin //stopwatch hour,min
                    digit_1000 = hour / 10;
                    digit_100  = hour % 10;
                    digit_10   = min / 10;
                    digit_1    = min % 10;
                    dot_mode   = 1'b1;
            end
            5'b001??: begin //watch s,ms
                    digit_1000 = sec / 10;
                    digit_100  = sec % 10;
                    digit_10   = msec / 10;
                    digit_1    = msec % 10;
                    dot_mode   = 1'b1;
            end
            5'b101??: begin //watch hour,min
                    digit_1000 = hour / 10;
                    digit_100  = hour % 10;
                    digit_10   = min / 10;
                    digit_1    = min % 10;
                    dot_mode   = 1'b1;
            end

            default: begin
                digit_1000 = 4'hA;
                digit_100  = 4'hB;
                digit_10   = 4'hC;
                digit_1    = 4'hD;
                dot_mode   = 1'b0;
            end
        endcase
    end

    always @(*) begin
        case (digit_sel)
            2'b00:   digit = digit_1;
            2'b01:   digit = digit_10;
            2'b10:   digit = digit_100;
            2'b11:   digit = digit_1000;
            default: digit = 4'd0;
        endcase
    end

endmodule





module BCD_decoder (
    input      [3:0] bin,
    output reg [7:0] bcd_data
);

    always @(*) begin
        case (bin)

            4'd0: bcd_data = 8'hc0;
            4'd1: bcd_data = 8'hf9;
            4'd2: bcd_data = 8'ha4;
            4'd3: bcd_data = 8'hb0;
            4'd4: bcd_data = 8'h99;
            4'd5: bcd_data = 8'h92;
            4'd6: bcd_data = 8'h82;
            4'd7: bcd_data = 8'hf8;
            4'd8: bcd_data = 8'h80;
            4'd9: bcd_data = 8'h90;

            4'hA: bcd_data = 8'b1100_1000;  //N
            4'hB: bcd_data = 8'hc0;         //0
            4'hC: bcd_data = 8'b1100_1000;  //N
            4'hD: bcd_data = 8'b1000_0110;  //E

            4'hE: bcd_data = 8'b1011_1111;  //-
            4'hF: bcd_data = 8'hff;

            default: bcd_data = 8'hff;
        endcase
    end

endmodule





module clk_div_1khz (
    input  clk,
    input  rst,
    output o_1khz
);

    reg [15:0] counter_reg;
    reg        o_1khz_reg;

    assign o_1khz = o_1khz_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 16'd0;
            o_1khz_reg  <= 1'b0;
        end else begin
            if (counter_reg == 16'd49_999) begin
                counter_reg <= 16'd0;
                o_1khz_reg  <= ~o_1khz_reg;
            end else begin
                counter_reg <= counter_reg + 1'b1;
            end
        end
    end

endmodule




module counter_4 (
    input        clk,
    input        rst,
    output [1:0] digit_sel
);

    reg [1:0] counter_reg;

    assign digit_sel = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 2'b00;
        end else begin
            counter_reg <= counter_reg + 1'b1;
        end
    end

endmodule



module decoder_2x4 (
    input      [1:0] decoder_in,
    output reg [3:0] fnd_com
);

    always @(*) begin
        case (decoder_in)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule
