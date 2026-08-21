`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/29 16:41:31
// Design Name: 
// Module Name: sr04_controller
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


module TOP_sr04_controller (
    input        clk,
    input        rst,
    input        btn_R,
    input        echo,
    input  [4:0] sw,        // btn 8,9
    input       uart_btn_R,
    output       trig,
    output [8:0] distance,
    output       timeout
);

    wire [8:0] w_distance;
    wire w_sr04_start, w_tick_us;
    wire w_timeout;


    button_debounce U_BD_SR04_START (
        .clk  (clk),
        .rst  (rst),
        .i_btn(sw[3] && sw[2] && btn_R),
        .o_btn(w_sr04_start)
    );

    tick_gen_us U_TICK_GEN_US (
        .clk(clk),
        .rst(rst),
        .tick_us(w_tick_us)
    );

    sr04_controller U_SR04_CTRL (

        .clk(clk),
        .rst(rst),
        .sr04_start(uart_btn_R || w_sr04_start),
        .tick_us(w_tick_us),
        .echo(echo),
        .sw(sw),
        .trig(trig),
        .distance(distance),
        .timeout(timeout)

    );

    // fnd_controller U_FND_CTRL (
    //     .clk(clk),
    //     .rst(rst),
    //     .fnd_in({5'b00000, w_distance}),
    //     .timeout(w_timeout),
    //     .fnd_com(fnd_com),
    //     .fnd_data(fnd_data)
    // );

endmodule







module tick_gen_us (
    input clk,
    input rst,
    output reg tick_us
);

    parameter F_COUNT = 100_000_000 / 1_000_000;  // us
    reg [$clog2(F_COUNT)-1:0] counter_reg;



    always @(posedge clk, posedge rst) begin

        if (rst) begin
            counter_reg <= 0;
            tick_us <= 1'b0;


        end else begin
            counter_reg <= counter_reg + 1;

            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_us <= 1'b1;
            end else begin
                tick_us <= 1'b0;
            end
        end

    end



endmodule





module sr04_controller (

    input        clk,
    input        rst,
    input        sr04_start,
    input        tick_us,
    input        echo,
    input  [4:0] sw,
    output       trig,
    output [8:0] distance,
    output       timeout
);


    parameter IDLE = 0, START = 1, WAIT = 2, RESPONSE = 3;

    reg [1:0] c_state, n_state;
    reg trig_reg, trig_next;
    reg [14:0] tick_us_cnt_reg, tick_us_cnt_next;
    reg [8:0] distance_reg, distance_next;
    reg timeout_reg, timeout_next;

    assign trig = trig_reg;
    assign distance = distance_reg;
    assign timeout = timeout_reg;

    always @(posedge clk, posedge rst) begin
        if (rst || !(sw[3] && sw[2])) begin
            c_state <= IDLE;
            trig_reg <= 1'b0;
            tick_us_cnt_reg <= 15'b0;
            distance_reg <= 0;
            timeout_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            trig_reg <= trig_next;
            tick_us_cnt_reg <= tick_us_cnt_next;
            distance_reg <= distance_next;
            timeout_reg <= timeout_next;

        end

    end


    always @(*) begin
        n_state = c_state;
        trig_next = trig_reg;
        tick_us_cnt_next = tick_us_cnt_reg;
        distance_next = distance_reg;
        timeout_next = timeout_reg;
        case (c_state)
            IDLE: begin
                trig_next = 1'b0;
                if (sr04_start) begin
                    n_state = START;
                    trig_next = 1'b1;
                    tick_us_cnt_next = 15'b0;
                    timeout_next = 1'b0;
                end
            end

            START: begin
                trig_next = 1'b1;
                if (tick_us) begin
                    if (tick_us_cnt_reg == 10) begin
                        tick_us_cnt_next = 0;
                        trig_next = 1'b0;
                        n_state = WAIT;

                    end else begin
                        tick_us_cnt_next = tick_us_cnt_reg + 1;
                    end
                end
            end

            WAIT: begin
                if (tick_us) begin
                    if (echo) begin
                        n_state = RESPONSE;
                        tick_us_cnt_next = 0;
                    end else if (tick_us_cnt_reg >= 30_000) begin  // timeout
                        n_state = IDLE;
                        tick_us_cnt_next = 0;
                        timeout_next = 1'b1;
                    end else begin
                        tick_us_cnt_next = tick_us_cnt_reg + 1;

                    end
                end
            end

            RESPONSE: begin
                if (tick_us) begin
                    if (!echo) begin
                        n_state = IDLE;
                        distance_next = (tick_us_cnt_reg >= 15'd23200) ? 9'd400 
                                                   : tick_us_cnt_reg / 58;
                        tick_us_cnt_next = 0;
                    end else begin
                        tick_us_cnt_next = tick_us_cnt_reg + 1;
                        if (tick_us_cnt_reg == 23199) begin
                            n_state = IDLE;
                            tick_us_cnt_next = 0;
                            timeout_next = 1'b1;
                        end
                    end
                end
            end

            // begin 
            //     if (echo) begin
            //     if(tick_us) begin
            //             tick_us_cnt_next = tick_us_cnt_reg + 1;
            //             distance_cnt_next = distance_cnt_reg + 1;   

            //     end
            //     end else begin 
            //             n_state = IDLE;
            //             tick_us_cnt_next = 0;
            //             distance_cnt_next = 0;
            //     end
            // end


            default: begin
                n_state = IDLE;
                trig_next = 1'b0;
                tick_us_cnt_next = 15'b0;
            end
        endcase
    end





endmodule



`timescale 1ns / 1ps

module button_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);
    // clock divider
    // 100MHz -> 100 KHz
    parameter F_COUNT = 100_000_000 / 100_000;
    reg [$clog2(F_COUNT)-1:0] r_counter;
    reg clk_100khz;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            clk_100khz <= 1'b0;
        end else begin
            r_counter <= r_counter + 1;
            if (r_counter == F_COUNT - 1) begin
                r_counter  <= 0;
                clk_100khz <= 1'b1;

            end else begin
                clk_100khz <= 1'b0;
            end
        end
    end

    // synchronizer
    reg [7:0] sync_reg, sync_next;
    reg  edge_reg;
    wire debounce;

    always @(posedge clk_100khz, posedge rst) begin
        if (rst) begin
            sync_reg <= 0;
        end else begin
            sync_reg <= sync_next;
        end
    end

    always @(*) begin
        sync_next = {i_btn, sync_reg[7:1]};  // << also okay
    end

    // 8input to 1 output and gate
    assign debounce = &sync_reg;

    // rising edge detect
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 1'b0;

        end else begin
            edge_reg <= debounce;
        end
    end

    assign o_btn = debounce & (~edge_reg);
endmodule
