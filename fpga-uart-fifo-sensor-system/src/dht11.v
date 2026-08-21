`timescale 1ns / 1ps

module dht11 (
    input clk,
    input rst,
    input btn_R,
    input [4:0] sw,
    input uart_btn_R,
    output [7:0] humidity,
    output [7:0] humidity_dec,
    output [7:0] temperature,
    output [7:0] temperature_dec,
    output       valid,   
    inout dht11
);

    wire       w_tick_us;

    wire [7:0] w_humidity;
    wire [7:0] w_humidity_dec;
    wire [7:0] w_temperature;
    wire [7:0] w_temperature_dec;
    wire       w_valid;

    wire       w_btn_start;

    // dht11_fnd_controller U_DHT11_FND_CONTROLLER (
    //     .clk(clk),
    //     .rst(rst),
    //     .sw(sw),
    //     .humidity(w_humidity),
    //     .humidity_dec(w_humidity_dec),
    //     .temperature(w_temperature),
    //     .temperature_dec(w_temperature_dec),
    //     .fnd_com(fnd_com),
    //     .fnd_data(fnd_data)
    // );



    button_debounce U_BUTTON_DEBOUNCE (
        .clk  (clk),
        .rst  (rst),
        .i_btn(sw[3] && (!sw[2]) && btn_R),
        .o_btn(w_btn_start)
    );

    dht11_controller U_DHT11_CONTROLLER (
        .clk            (clk),
        .rst            (rst),
        .dht11_start    (uart_btn_R || w_btn_start),
        .tick_us        (w_tick_us),
        .sw             (sw),
        .humidity       (humidity),
        .humidity_dec   (humidity_dec),
        .temperature    (temperature),
        .temperature_dec(temperature_dec),
        .valid          (valid),            // for check sum
        .dht11          (dht11)
    );

    tick_gen_us U_TICK_GEN_US (
        .clk(clk),
        .rst(rst),
        .tick_us(w_tick_us)
    );

endmodule




module dht11_controller (
    input        clk,
    input        rst,
    input        dht11_start,
    input        tick_us,
    input  [4:0] sw,
    output [7:0] humidity,
    output [7:0] humidity_dec,
    output [7:0] temperature,
    output [7:0] temperature_dec,
    output       valid,            // for check sum
    inout        dht11
);

    parameter IDLE = 0, START = 1, WAIT = 2, SYNCH = 4, SYNCL = 3;
    parameter DATA_SYNC = 5, DATA_COUNT = 6, DATA_DECISION = 7;
    parameter STOP = 8;

    reg [3:0] c_state, n_state;
    reg [5:0] bit_cnt_reg, bit_cnt_next;  // receive bit counter
    reg [$clog2(19_000)-1:0]
        tick_cnt_reg, tick_cnt_next;  // geneal tick counter
    reg out_sel_reg, out_sel_next;  // dht11 io 3state control
    reg dht11_reg, dht11_next;  // dht11 output drive

    reg [39:0] data_reg, data_next;

    // dht11 output 3state control
    assign dht11 = (out_sel_reg) ? dht11_reg : 1'bz;

    assign valid = ((c_state == STOP) && (data_reg[7:0]==(data_reg[39:32] + data_reg[31:24] + data_reg [23:16] + data_reg[15:8]))) ? 1:0;

    assign humidity = data_reg[39:32];
    assign humidity_dec = data_reg[31:24];
    assign temperature = data_reg[23:16];
    assign temperature_dec = data_reg[15:8];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= IDLE;
            bit_cnt_reg  <= 0;
            tick_cnt_reg <= 0;
            out_sel_reg  <= 1'b1;
            dht11_reg    <= 1'b1;
            data_reg     <= 0;
        end else if (!(sw[3] && !sw[2])) begin
            c_state      <= IDLE;
            bit_cnt_reg  <= 0;
            tick_cnt_reg <= 0;
            out_sel_reg  <= 1'b1;
            dht11_reg    <= 1'b1;
            data_reg     <= data_reg;  // last value maintain
        end else begin
            c_state      <= n_state;
            bit_cnt_reg  <= bit_cnt_next;
            tick_cnt_reg <= tick_cnt_next;
            out_sel_reg  <= out_sel_next;
            dht11_reg    <= dht11_next;
            data_reg     <= data_next;
        end
    end

    always @(*) begin
        n_state       = c_state;
        bit_cnt_next  = bit_cnt_reg;
        tick_cnt_next = tick_cnt_reg;
        out_sel_next  = out_sel_reg;
        dht11_next    = dht11_reg;
        data_next     = data_reg;
        case (c_state)
            IDLE: begin
                dht11_next   = 1'b1;
                out_sel_next = 1'b1;
                if (dht11_start) begin
                    bit_cnt_next  = 0;
                    tick_cnt_next = 0;
                    n_state       = START;
                end
            end
            START: begin
                dht11_next = 1'b0;
                if (tick_us) begin
                    if (tick_cnt_reg >= 19_000) begin
                        tick_cnt_next = 0;
                        n_state = WAIT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            WAIT: begin
                dht11_next = 1'b1;
                if (tick_us) begin
                    if (tick_cnt_reg > 30) begin
                        tick_cnt_next = 0;
                        n_state = SYNCL;
                        //out_sel_next = 1'b0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            SYNCL: begin
                // output is high impedance "z"
                out_sel_next = 1'b0;
                if (tick_us) begin
                    if ((tick_cnt_reg > 40) && (dht11)) begin
                        tick_cnt_next = 0;
                        n_state = SYNCH;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            SYNCH: begin
                if (tick_us) begin
                    if ((tick_cnt_reg > 40) && (!dht11)) begin
                        tick_cnt_next = 0;
                        n_state = DATA_SYNC;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_SYNC: begin
                if (tick_us) begin
                    if (dht11) begin
                        tick_cnt_next = 0;
                        n_state = DATA_COUNT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_COUNT: begin
                if (tick_us) begin
                    if (!dht11) begin
                        //tick_cnt_next = 0;
                        n_state = DATA_DECISION;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end

            DATA_DECISION: begin
                if (tick_us) begin
                    if (tick_cnt_reg > 40) begin
                        data_next = {data_reg[38:0], 1'b1};
                    end else begin
                        data_next = {data_reg[38:0], 1'b0};
                    end

                    tick_cnt_next = 0;

                    if (bit_cnt_reg == 39) begin
                        n_state = STOP;
                        bit_cnt_next = 0;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        n_state = DATA_SYNC;
                    end

                end
            end

            STOP: begin
                if (tick_us) begin
                    if (tick_cnt_reg > 50) begin
                        tick_cnt_next = 0;
                        n_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end


endmodule
