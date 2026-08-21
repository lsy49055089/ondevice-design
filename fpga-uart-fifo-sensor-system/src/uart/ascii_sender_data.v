`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/30 21:27:56
// Design Name: 
// Module Name: ascii_sender_data
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

module top_ascii_sender (
    input        clk,
    input        rst,
    input  [1:0] mode,
    input  [1:0] hum_or_temp_sel,
    input        start,
    input  [5:0] sec_clock,
    input  [5:0] sec_sw,
    input  [5:0] min_clock,
    input  [5:0] min_sw,
    input  [4:0] hour_clock,
    input  [4:0] hour_sw,
    input  [8:0] dist,
    input  [7:0] hum,
    input  [7:0] temp,
    output [7:0] pop_data,
    output       push
);
    wire w_tick_gen;
    wire [7:0] w_sec_1_ascii,w_sec_10_ascii,w_min_1_ascii,w_min_10_ascii,w_hour_1_ascii,w_hour_10_ascii;
    wire [7:0] w_hum_1_ascii,w_hum_10_ascii, w_temp_1_ascii,w_temp_10_ascii;
    wire [7:0] w_dist_1_ascii, w_dist_10_ascii, w_dist_100_ascii;
    tick_gen_byte U_TICK_TEN_BYTE(
    .clk(clk),
    .rst(rst),
    .o_b_tick(w_tick_gen)
);
    ascii_sender_data U_ASCII_SENDER_DATA (
        .sec_clock(sec_clock),
        .sec_sw(sec_sw),
        .min_clock(min_clock),
        .min_sw(min_sw),
        .hour_clock(hour_clock),
        .hour_sw(hour_sw),
        .dist(dist),
        .hum(hum),
        .temp(temp),
        .mode(mode),
        .sec_1_ascii(w_sec_1_ascii),
        .sec_10_ascii(w_sec_10_ascii),
        .min_1_ascii(w_min_1_ascii),
        .min_10_ascii(w_min_10_ascii),
        .hour_1_ascii(w_hour_1_ascii),
        .hour_10_ascii(w_hour_10_ascii),
        .dist_1_ascii(w_dist_1_ascii),
        .dist_10_ascii(w_dist_10_ascii),
        .dist_100_ascii(w_dist_100_ascii),
        .hum_1_ascii(w_hum_1_ascii),
        .hum_10_ascii(w_hum_10_ascii),
        .temp_1_ascii(w_temp_1_ascii),
        .temp_10_ascii(w_temp_10_ascii)
    );
    ascii_sender_data_pop U_ASCII_SENDER_POP (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .hum_or_temp_sel(hum_or_temp_sel),
        .start(start),
        .tick_gen(w_tick_gen),
        .sec_1_ascii(w_sec_1_ascii),
        .sec_10_ascii(w_sec_10_ascii),
        .min_1_ascii(w_min_1_ascii),
        .min_10_ascii(w_min_10_ascii),
        .hour_1_ascii(w_hour_1_ascii),
        .hour_10_ascii(w_hour_10_ascii),
        .dist_1_ascii(w_dist_1_ascii),
        .dist_10_ascii(w_dist_10_ascii),
        .dist_100_ascii(w_dist_100_ascii),
        .hum_1_ascii(w_hum_1_ascii),
        .hum_10_ascii(w_hum_10_ascii),
        .temp_1_ascii(w_temp_1_ascii),
        .temp_10_ascii(w_temp_10_ascii),
        .pop_data(pop_data),
        .push(push)
    );
endmodule

module ascii_sender_data_pop (
    input        clk,
    input        rst,
    input  [1:0] mode,
    input  [1:0] hum_or_temp_sel,
    input        start,
    input        tick_gen,
    input  [7:0] sec_1_ascii,
    input  [7:0] sec_10_ascii,
    input  [7:0] min_1_ascii,
    input  [7:0] min_10_ascii,
    input  [7:0] hour_1_ascii,
    input  [7:0] hour_10_ascii,
    input  [7:0] dist_1_ascii,
    input  [7:0] dist_10_ascii,
    input  [7:0] dist_100_ascii,  
    input  [7:0] hum_1_ascii,
    input  [7:0] hum_10_ascii,
    input  [7:0] temp_1_ascii,
    input  [7:0] temp_10_ascii,
    output [7:0] pop_data,
    output       push
);
    parameter IDLE = 0, START = 1, POP = 2, STOP = 3;
    reg [1:0] c_state, n_state;
    reg [4:0] data_cnt_reg, data_cnt_next;
    reg [7:0] ascii_data_reg[0:31];
    reg [7:0] pop_data_reg, pop_data_next;
    reg push_reg, push_next;

    assign pop_data = pop_data_reg;
    assign push = push_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            data_cnt_reg <= 0;
            pop_data_reg <= 0;
            push_reg <= 0;
        end else begin
            c_state <= n_state;
            data_cnt_reg <= data_cnt_next;
            pop_data_reg <= pop_data_next;
            push_reg <= push_next;
            if (mode==2'b01) begin //clock
                ascii_data_reg[0]  <= 8'h63;  //c
                ascii_data_reg[1]  <= 8'h6C;  //l
                ascii_data_reg[2]  <= 8'h6F;  //o
                ascii_data_reg[3]  <= 8'h63;  //c
                ascii_data_reg[4]  <= 8'h6B;  //k
                ascii_data_reg[5]  <= 8'h3A;  //:
                ascii_data_reg[6]  <= 8'h20;  //space
                ascii_data_reg[7]  <= 8'h20;  //space
                ascii_data_reg[8]  <= 8'h20;  //space
                ascii_data_reg[9]  <= 8'h20;  //space
                ascii_data_reg[10] <= hour_10_ascii;
                ascii_data_reg[11] <= hour_1_ascii;
                ascii_data_reg[12] <= 8'h68; //h
                ascii_data_reg[13] <= min_10_ascii;
                ascii_data_reg[14] <= min_1_ascii;
                ascii_data_reg[15] <= 8'h6D; //m
                ascii_data_reg[16] <= sec_10_ascii;
                ascii_data_reg[17] <= sec_1_ascii;
                ascii_data_reg[18] <= 8'h73; //s
                ascii_data_reg[19] <= 8'h20;  //space 
            end else if (mode==2'b00) begin //stopwatch
                ascii_data_reg[0]  <= 8'h73;  //s
                ascii_data_reg[1]  <= 8'h74;  //t
                ascii_data_reg[2]  <= 8'h6F;  //o
                ascii_data_reg[3]  <= 8'h70;  //p
                ascii_data_reg[4]  <= 8'h77;  //w
                ascii_data_reg[5]  <= 8'h61;  //a
                ascii_data_reg[6]  <= 8'h74;  //t
                ascii_data_reg[7]  <= 8'h63;  //c
                ascii_data_reg[8]  <= 8'h68;  //h
                ascii_data_reg[9]  <= 8'h3A;  //:
                ascii_data_reg[10] <= hour_10_ascii;
                ascii_data_reg[11] <= hour_1_ascii;
                ascii_data_reg[12] <= 8'h68;
                ascii_data_reg[13] <= min_10_ascii;
                ascii_data_reg[14] <= min_1_ascii;
                ascii_data_reg[15] <= 8'h6D;
                ascii_data_reg[16] <= sec_10_ascii;
                ascii_data_reg[17] <= sec_1_ascii;
                ascii_data_reg[18] <= 8'h73;    //s
                ascii_data_reg[19] <= 8'h20;  //space 
            end else if (mode==2'b11)begin
                ascii_data_reg[0]  <= 8'h64;  //d
                ascii_data_reg[1]  <= 8'h69;  //i
                ascii_data_reg[2]  <= 8'h73;  //s
                ascii_data_reg[3]   <= 8'h74;  //t
                ascii_data_reg[4]  <= 8'h61;  //a
                ascii_data_reg[5]  <= 8'h6E;  //n
                ascii_data_reg[6]  <= 8'h63;  //c
                ascii_data_reg[7]  <= 8'h65;  //e
                ascii_data_reg[8]   <= 8'h3A;  //:
                ascii_data_reg[9]  <= 8'h20;  //space
                ascii_data_reg[10] <= dist_100_ascii;
                ascii_data_reg[11] <= dist_10_ascii;
                ascii_data_reg[12] <= dist_1_ascii;
                ascii_data_reg[13] <= 8'h63;  //c
                ascii_data_reg[14] <= 8'h6D;  //m
                ascii_data_reg[15] <= 8'h20;  //space
                ascii_data_reg[16] <= 8'h20;  //space
                ascii_data_reg[17] <= 8'h20;  //space
                ascii_data_reg[18] <= 8'h20;  //space
                ascii_data_reg[19] <= 8'h20;  //space 
            end else if ((mode==2'b10)&&(hum_or_temp_sel==2'b00)) begin //humidity
                ascii_data_reg[0]  <= 8'h68;  //h
                ascii_data_reg[1]  <= 8'h75;  //u
                ascii_data_reg[2]  <= 8'h6D;  //m
                ascii_data_reg[3]  <= 8'h2C;  //,
                ascii_data_reg[4]  <= 8'h74;  //t
                ascii_data_reg[5]  <= 8'h65;  //e
                ascii_data_reg[6]  <= 8'h6D;  //m
                ascii_data_reg[7]  <= 8'h70;  //p
                ascii_data_reg[8]  <= 8'h3A;  //:
                ascii_data_reg[9]  <= 8'h20;  //space
                ascii_data_reg[10] <= 8'h6E;  //n
                ascii_data_reg[11] <= 8'h6F;  //o
                ascii_data_reg[12] <= 8'h6E;  //n
                ascii_data_reg[13] <= 8'h65;  //e
                ascii_data_reg[14] <= 8'h20;  //space
                ascii_data_reg[15] <= 8'h20;  //space
                ascii_data_reg[16] <= 8'h20;  //space
                ascii_data_reg[17] <= 8'h20;  //space
                ascii_data_reg[18] <= 8'h20;  //space
                ascii_data_reg[19] <= 8'h20;  //space 
            end else if ((mode==2'b10)&&(hum_or_temp_sel==2'b10)) begin //humidity
                ascii_data_reg[0]  <= 8'h68;  //h
                ascii_data_reg[1]  <= 8'h75;  //u
                ascii_data_reg[2]  <= 8'h6D;  //m
                ascii_data_reg[3]  <= 8'h69;  //i
                ascii_data_reg[4]  <= 8'h64;  //d
                ascii_data_reg[5]  <= 8'h69;  //i
                ascii_data_reg[6]  <= 8'h74;  //t
                ascii_data_reg[7]  <= 8'h79;  //y
                ascii_data_reg[8]  <= 8'h3A;  //:
                ascii_data_reg[9]  <= 8'h20;  //space
                ascii_data_reg[10] <= hum_10_ascii;
                ascii_data_reg[11] <= hum_1_ascii;
                ascii_data_reg[12] <= 8'h20;  //space
                ascii_data_reg[13] <= 8'h20;  //space
                ascii_data_reg[14] <= 8'h20;  //space
                ascii_data_reg[15] <= 8'h20;  //space
                ascii_data_reg[16] <= 8'h20;  //space
                ascii_data_reg[17] <= 8'h20;  //space
                ascii_data_reg[18] <= 8'h20;  //space
                ascii_data_reg[19] <= 8'h20;  //space 
            end else if ((mode==2'b10)&&(hum_or_temp_sel==2'b01)) begin //temperature
                ascii_data_reg[0]  <= 8'h74;  //t
                ascii_data_reg[1]  <= 8'h65;  //e
                ascii_data_reg[2]  <= 8'h6D;  //m
                ascii_data_reg[3]  <= 8'h70;  //p
                ascii_data_reg[4]  <= 8'h65;  //e
                ascii_data_reg[5]  <= 8'h72;  //r
                ascii_data_reg[6]  <= 8'h61;  //a
                ascii_data_reg[7]  <= 8'h74;  //t
                ascii_data_reg[8]  <= 8'h75;  //u
                ascii_data_reg[9]  <= 8'h72;  //r
                ascii_data_reg[10] <= 8'h65;  //e
                ascii_data_reg[11] <= 8'h3A;  //:
                ascii_data_reg[12] <= temp_10_ascii;//
                ascii_data_reg[13] <= temp_1_ascii;//
                ascii_data_reg[14] <= 8'h20;  //space
                ascii_data_reg[15] <= 8'h20;  //space
                ascii_data_reg[16] <= 8'h20;  //space
                ascii_data_reg[17] <= 8'h20;  //space
                ascii_data_reg[18] <= 8'h20;  //space
                ascii_data_reg[19] <= 8'h20;  //space 
            end else if ((mode==2'b10)&&(hum_or_temp_sel==2'b11)) begin //humidity
                ascii_data_reg[0]  <= 8'h68;  //h
                ascii_data_reg[1]  <= 8'h75;  //u
                ascii_data_reg[2]  <= 8'h6D;  //m
                ascii_data_reg[3]  <= 8'h2C;  //,
                ascii_data_reg[4]  <= 8'h74;  //t
                ascii_data_reg[5]  <= 8'h65;  //e
                ascii_data_reg[6]  <= 8'h6D;  //m
                ascii_data_reg[7]  <= 8'h70;  //p
                ascii_data_reg[8]  <= 8'h3A;  //:
                ascii_data_reg[9]  <= 8'h20;  //space
                ascii_data_reg[10] <= hum_10_ascii;
                ascii_data_reg[11] <= hum_1_ascii;
                ascii_data_reg[12] <= 8'h2C;  //,
                ascii_data_reg[13] <= temp_10_ascii;
                ascii_data_reg[14] <= temp_1_ascii;
                ascii_data_reg[15] <= 8'h20;  //space
                ascii_data_reg[16] <= 8'h20;  //space
                ascii_data_reg[17] <= 8'h20;  //space
                ascii_data_reg[18] <= 8'h20;  //space
                ascii_data_reg[19] <= 8'h20;  //space 
            end
        end
    end

    always @(*) begin
        n_state = c_state;
        data_cnt_next = data_cnt_reg;
        pop_data_next = pop_data_reg;
        push_next = push_reg;
        case (c_state)
            IDLE: begin
                push_next = 0;
                data_cnt_next = 0;
                if (start) begin
                    n_state = START;
                end
            end
            START: begin
                if (tick_gen) begin
                    n_state = POP;
                    data_cnt_next = 0;
                end
            end
            POP: begin
                push_next = 0;
                if (tick_gen) begin
                    pop_data_next = ascii_data_reg[data_cnt_reg];
                    push_next = 1;
                    if (data_cnt_reg == 18) begin
                        n_state = STOP;
                        data_cnt_next = 0;
                    end else begin
                        data_cnt_next = data_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                push_next = 0;
                if (tick_gen) begin
                    n_state = IDLE;
                end
            end
        endcase
    end
endmodule

module ascii_sender_data (
    input  [5:0] sec_clock,
    input  [5:0] sec_sw,
    input  [5:0] min_clock,
    input  [5:0] min_sw,
    input  [4:0] hour_clock,
    input  [4:0] hour_sw,
    input  [8:0] dist,
    input  [7:0] hum,
    input  [7:0] temp,
    input  [1:0] mode, //stopwatch, watch, distance, hum and temp sel
    output [7:0] sec_1_ascii,
    output [7:0] sec_10_ascii,
    output [7:0] min_1_ascii,
    output [7:0] min_10_ascii,
    output [7:0] hour_1_ascii,
    output [7:0] hour_10_ascii,
    output [7:0] dist_1_ascii,
    output [7:0] dist_10_ascii,
    output [7:0] dist_100_ascii,
    output [7:0] hum_1_ascii,
    output [7:0] hum_10_ascii,
    output [7:0] temp_1_ascii,
    output [7:0] temp_10_ascii
);
    parameter SEC = 6, MIN = 6, HOUR = 5, HUM = 8, TEMP = 8, DIST=9;
    wire [5:0] sec_data;
    wire [5:0] min_data;
    wire [4:0] hour_data;
    wire [3:0] w_sec_1, w_sec_10, w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] w_hum_1, w_hum_10, w_temp_1, w_temp_10;
    wire [3:0] w_dist_1, w_dist_10, w_dist_100;
    assign sec_data = (mode==2'b01)? sec_clock : (mode==2'b00) ? sec_sw: 0;
    assign min_data = (mode==2'b01) ? min_clock :(mode==2'b00) ? min_sw: 0;
    assign hour_data = (mode==2'b01) ? hour_clock :(mode==2'b00)? hour_sw: 0;
    assign sec_1_ascii = {4'd0, w_sec_1} + 8'h30;
    assign sec_10_ascii = {4'd0, w_sec_10} + 8'h30;
    assign min_1_ascii = {4'd0, w_min_1} + 8'h30;
    assign min_10_ascii = {4'd0, w_min_10} + 8'h30;
    assign hour_1_ascii = {4'd0, w_hour_1} + 8'h30;
    assign hour_10_ascii = {4'd0, w_hour_10} + 8'h30;
    assign dist_1_ascii = {4'd0, w_dist_1} + 8'h30;
    assign dist_10_ascii = {4'd0, w_dist_10} + 8'h30;
    assign dist_100_ascii = {4'd0, w_dist_100} + 8'h30;
    assign hum_1_ascii = {4'd0, w_hum_1} + 8'h30;
    assign hum_10_ascii = {4'd0, w_hum_10} + 8'h30;
    assign temp_1_ascii = {4'd0, w_temp_1} + 8'h30;
    assign temp_10_ascii = {4'd0, w_temp_10} + 8'h30;
    fnd_digit_splitter #(
        .BIT_WIDTH(SEC)
    ) U_DIGIT_SPLIT_SEC (
        .digit_in(sec_data),
        .digit_1 (w_sec_1),
        .digit_10(w_sec_10)
    );
    fnd_digit_splitter #(
        .BIT_WIDTH(MIN)
    ) U_DIGIT_SPLIT_MIN (
        .digit_in(min_data),
        .digit_1 (w_min_1),
        .digit_10(w_min_10)
    );
    fnd_digit_splitter #(
        .BIT_WIDTH(HOUR)
    ) U_DIGIT_SPLIT_HOUR (
        .digit_in(hour_data),
        .digit_1 (w_hour_1),
        .digit_10(w_hour_10)
    );
    fnd_digit_splitter #(
        .BIT_WIDTH(HUM)
    ) U_DIGIT_SPLIT_HUM (
        .digit_in(hum),
        .digit_1 (w_hum_1),
        .digit_10(w_hum_10)
    );
    fnd_digit_splitter #(
        .BIT_WIDTH(TEMP)
    ) U_DIGIT_SPLIT_TEMP (
        .digit_in(temp),
        .digit_1 (w_temp_1),
        .digit_10(w_temp_10)
    );

    fnd_digit_splitter_dist #(
    .BIT_WIDTH(DIST)
    ) U_DIGIT_SPLIT_DIST(
    .digit_in(dist),
    .digit_1(w_dist_1),
    .digit_10(w_dist_10),
    .digit_100(w_dist_100)
);
endmodule

module fnd_digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1 : 0] digit_in,
    output [3 : 0] digit_1,
    output [3 : 0] digit_10
);
    assign digit_1  = digit_in % 10;  // digit 1
    assign digit_10 = (digit_in / 10) % 10;  // digit 10
endmodule

module fnd_digit_splitter_dist #(
    parameter BIT_WIDTH = 8
) (
    input [BIT_WIDTH-1 : 0] digit_in,
    output [3 : 0] digit_1,
    output [3 : 0] digit_10,
    output [3 : 0] digit_100
);
    assign digit_1  = digit_in % 10;  // digit 1
    assign digit_10 = (digit_in / 10) % 10;  // digit 10
    assign digit_100= (digit_in/100) %10; //digit 100
endmodule

module tick_gen_byte (
    input clk,
    input rst,
    output reg o_b_tick
);
    parameter TIMES = (100_000_000 / (9600)*10);
    reg [$clog2(TIMES)-1:0] b_tick_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            b_tick_reg <= 0;
            o_b_tick   <= 1'b0;
        end else begin
            b_tick_reg <= b_tick_reg + 1;
            if (b_tick_reg == TIMES - 1) begin
                b_tick_reg <= 0;
                o_b_tick   <= 1'b1;
            end else begin
                o_b_tick <= 1'b0;
            end
        end
    end

endmodule

