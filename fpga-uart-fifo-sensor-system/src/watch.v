
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/17 16:15:36
// Design Name: 
// Module Name: watch
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


module watch (
    input        clk,
    input        rst,
    input        btnR,
    input        btnL,
    input        btnU,
    input        btnD,
    input        uart_btn_R,
    input        uart_btn_L,
    input        uart_btn_U,
    input        uart_btn_D,
    input  [4:0] sw,
    output [4:0] hour,
    output [5:0] sec,
    output [5:0] min,
    output [6:0] msec,
    output [3:0] led
);

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [MSEC_WIDTH - 1 : 0] w_msec;
    wire [ SEC_WIDTH - 1 : 0] w_sec;
    wire [ MIN_WIDTH - 1 : 0] w_min;
    wire [HOUR_WIDTH - 1 : 0] w_hour;
    wire w_btnR, w_btnL, w_btnD, w_btnU;
    wire [1:0] w_mode;
    wire [1:0] w_led;


    parameter NORMAL = 0, SEC = 1, MIN = 2, HOUR = 3;

    assign led = !((!sw[3]) && sw[2]) ? 4'b0000 :
             (w_mode == NORMAL) ? 4'b0001 :
             (w_mode == SEC)    ? 4'b0010 :
             (w_mode == MIN)    ? 4'b0100 :
                                  4'b1000;
    wire btnU_sec = (((!sw[3]) && sw[2]) && (w_mode == SEC)) ?   (uart_btn_U || w_btnU) : 0;
    wire btnU_min = (((!sw[3]) && sw[2]) && (w_mode == MIN)) ?   (uart_btn_U || w_btnU) : 0;
    wire btnU_hour = (((!sw[3]) && sw[2]) && (w_mode == HOUR)) ? (uart_btn_U || w_btnU) : 0;

    wire btnD_sec = (((!sw[3]) && sw[2]) && (w_mode == SEC)) ?   (uart_btn_D || w_btnD) : 0;
    wire btnD_min = (((!sw[3]) && sw[2]) && (w_mode == MIN)) ?   (uart_btn_D || w_btnD) : 0;
    wire btnD_hour = (((!sw[3]) && sw[2]) && (w_mode == HOUR)) ? (uart_btn_D || w_btnD) : 0;

    button_debounce U_BTNR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );
    button_debounce U_BTNL (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );
    button_debounce U_BTNU (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),
        .o_btn(w_btnU)
    );
    button_debounce U_BTND (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );



    watch_control_unit U_COUTROL_UNIT (
        .clk   (clk),
        .rst   (rst),
        .i_btnR((!sw[3]) && sw[2] && (w_btnR || uart_btn_R)),  // right
        .i_btnL((!sw[3]) && sw[2] && (w_btnL || uart_btn_L)),  // left
        .o_led (w_led),
        .o_mode(w_mode)
    );




    watch_datapath U_STOPWATCH_DATAPATH (
        .clk        (clk),
        .rst        (rst),
        .i_btnU_sec (btnU_sec),
        .i_btnU_min (btnU_min),
        .i_btnU_hour(btnU_hour),

        .i_btnD_sec (btnD_sec),
        .i_btnD_min (btnD_min),
        .i_btnD_hour(btnD_hour),
        .msec       (msec),
        .sec        (sec),
        .min        (min),
        .hour       (hour)
    );


    //    fnd_controller U_FND_CTRL (
    //        .sw  (sw[0]),   // sw[0], 0 : msec_sec, 1 : min_hour




endmodule







`timescale 1ns / 1ps

module watch_control_unit (
    input        clk,
    input        rst,
    input        i_btnR,  // right
    input        i_btnL,  // left
    output [1:0] o_led,
    output [1:0] o_mode  // NORMAL = 0, SEC = 1, MIN = 2, HOUR = 3;
);
    // state
    parameter [1:0] NORMAL = 0, SEC = 1, MIN = 2, HOUR = 3;
    reg [1:0] c_state, n_state;

    assign o_led  = c_state;  // you have to redifine
    assign o_mode = c_state;  // you have to redifine

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= NORMAL;
        end else begin
            c_state <= n_state;
        end
    end
    // next ,output CL
    always @(*) begin
        n_state = c_state;
        case (c_state)
            NORMAL: begin
                if (i_btnR) begin
                    n_state = HOUR;
                end else if (i_btnL) begin
                    n_state = SEC;
                end else n_state = c_state;
            end
            SEC: begin
                if (i_btnR) begin
                    n_state = NORMAL;
                end else if (i_btnL) begin
                    n_state = MIN;
                end else n_state = c_state;
            end
            MIN: begin
                if (i_btnR) begin
                    n_state = SEC;
                end else if (i_btnL) begin
                    n_state = HOUR;
                end else n_state = c_state;
            end
            HOUR: begin
                if (i_btnR) begin
                    n_state = MIN;
                end else if (i_btnL) begin
                    n_state = NORMAL;
                end else n_state = c_state;
            end
        endcase
    end

endmodule



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/17 11:35:19
// Design Name: 
// Module Name: watch_datapath
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



module watch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                       clk,
    input                       rst,
    input                       i_btnU_sec,
    input                       i_btnU_min,
    input                       i_btnU_hour,
    input                       i_btnD_sec,
    input                       i_btnD_min,
    input                       i_btnD_hour,
    output [MSEC_WIDTH  -1 : 0] msec,
    output [ SEC_WIDTH - 1 : 0] sec,
    output [ MIN_WIDTH - 1 : 0] min,
    output [  HOUR_WIDTH - 1:0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;


    // hour
    watch_tick_counter #(
        .TIMES(24),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_hour_tick),  // from min o_tick
        .i_btnU      (i_btnU_hour),
        .i_btnD      (i_btnD_hour),
        .time_counter(hour),
        .o_tick      ()
    );


    // min
    watch_tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_min_tick),  // from sec o_tick
        .i_btnU      (i_btnU_min),
        .i_btnD      (i_btnD_min),
        .time_counter(min),
        .o_tick      (w_hour_tick)  // to hour i_tick
    );



    // sec
    watch_tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_sec_tick),  // from msec o_tick
        .i_btnU      (i_btnU_sec),
        .i_btnD      (i_btnD_sec),
        .time_counter(sec),
        .o_tick      (w_min_tick)   // to min i_tick
    );



    // msec
    watch_tick_counter #(
        .TIMES(100),
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_tick_100hz),  // from msec o_tick
        .i_btnU      (1'b0),
        .i_btnD      (1'b0),
        .time_counter(msec),
        .o_tick      (w_sec_tick)     // to sec i_tick
    );


    watch_tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .o_tick_100hz(w_tick_100hz)
    );







endmodule







module watch_tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
) (
    input                         clk,
    input                         rst,
    input                         i_tick,
    input                         i_btnU,
    input                         i_btnD,
    output     [BIT_WIDTH -1 : 0] time_counter,
    output reg                    o_tick
);


    // counter register
    reg [BIT_WIDTH - 1 : 0] counter_reg, counter_next;

    assign time_counter = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;

        end
    end
    // next counter CL : blocking
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;

        // 1. DOWN (최우선)
        if (i_btnD) begin
            if (counter_reg == 0) begin
                counter_next = TIMES - 1;
                o_tick = 1'b1;
            end else begin
                counter_next = counter_reg - 1;
            end

            // 2. UP + TICK
        end else if (i_tick && i_btnU) begin
            if (counter_reg >= TIMES - 2) begin
                counter_next = (counter_reg + 2) % TIMES;
                o_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 2;
            end

            // 3. UP or TICK
        end else if (i_tick || i_btnU) begin
            if (counter_reg == TIMES - 1) begin
                counter_next = 0;
                o_tick = 1'b1;
            end else begin
                counter_next = counter_reg + 1;
            end
        end
    end
endmodule





module watch_tick_gen_100hz (
    input      clk,
    input      rst,
    output reg o_tick_100hz
);
    // 100 Hz counter number * 1000 for simulation
    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT)-1 : 0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg  <= 0;
            o_tick_100hz <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg  <= 0;
                o_tick_100hz <= 1'b1;
            end else begin
                o_tick_100hz <= 1'b0;
            end
        end
    end
endmodule


