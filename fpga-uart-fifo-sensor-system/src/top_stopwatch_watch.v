`timescale 1ns / 1ps
`timescale 1ns / 1ps



module top_stopwatch_watch (
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
    output [1:0] led
);

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [MSEC_WIDTH - 1 : 0] w_msec;
    wire [ SEC_WIDTH - 1 : 0] w_sec;
    wire [ MIN_WIDTH - 1 : 0] w_min;
    wire [HOUR_WIDTH - 1 : 0] w_hour;

    wire w_runstop, w_clear, w_mode;
    wire w_btnR, w_btnL, w_btnD, w_btnU;
    wire w_moment_hold, w_moment_capture;

    // reg [MSEC_WIDTH - 1 : 0] r_moment_w_msec;
    // reg [ SEC_WIDTH - 1 : 0] r_moment_w_sec;
    // reg [ MIN_WIDTH - 1 : 0] r_moment_w_min;
    // reg [HOUR_WIDTH - 1 : 0] r_moment_w_hour;

    assign led[0] = sw[2]; 
    assign led[1] = sw[3];
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

    stopwatch_control_unit U_COUTROL_UNIT (
        .clk       (clk),
        .rst       (rst),
        .i_run_stop((!sw[3])&&(!sw[2])&&(uart_btn_R || w_btnR)),
        .i_clear   ((!sw[3])&&(!sw[2])&&(uart_btn_L || w_btnL)),
        .i_mode    ((!sw[3])&&(!sw[2])&&(uart_btn_D || w_btnD)),
        .i_moment    ((!sw[3])&&(!sw[2])&&(uart_btn_U || w_btnU)),
        .o_mode    (w_mode),
        .o_clear   (w_clear),
        .o_run_stop(w_runstop),
        .o_moment_hold(w_moment_hold),      // ++
        .o_moment_capture(w_moment_capture) 
    );

    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk             (clk),
        .rst             (rst),
        .i_runstop       (w_runstop),
        .i_clear         (w_clear),
        .i_mode          (w_mode),
        .i_moment_hold   (w_moment_hold),
        .i_moment_capture(w_moment_capture),
        .msec            (msec),
        .sec             (sec),
        .min             (min),
        .hour            (hour)
    );


endmodule



`timescale 1ns / 1ps

module stopwatch_datapath #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
) (
    input                       clk,
    input                       rst,
    input                       i_runstop,
    input                       i_clear,
    input                       i_mode,
    input                       i_moment_hold,
    input                       i_moment_capture,
    output [MSEC_WIDTH  -1 : 0] msec,
    output [ SEC_WIDTH - 1 : 0] sec,
    output [ MIN_WIDTH - 1 : 0] min,
    output [HOUR_WIDTH - 1 : 0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    // raw time
    wire [MSEC_WIDTH - 1 : 0] w_raw_msec;
    wire [ SEC_WIDTH - 1 : 0] w_raw_sec;
    wire [ MIN_WIDTH - 1 : 0] w_raw_min;
    wire [HOUR_WIDTH - 1 : 0] w_raw_hour;

    // hour
    tick_counter #(
        .TIMES(24),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_hour_tick),
        .i_clear     (i_clear),
        .i_mode      (i_mode),
        .time_counter(w_raw_hour),
        .o_tick      ()
    );

    // min
    tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_min_tick),
        .i_clear     (i_clear),
        .i_mode      (i_mode),
        .time_counter(w_raw_min),
        .o_tick      (w_hour_tick)
    );

    // sec
    tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_sec_tick),
        .i_clear     (i_clear),
        .i_mode      (i_mode),
        .time_counter(w_raw_sec),
        .o_tick      (w_min_tick)
    );

    // msec
    tick_counter #(
        .TIMES(100),
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER (
        .clk         (clk),
        .rst         (rst),
        .i_tick      (w_tick_100hz),
        .i_clear     (i_clear),
        .i_mode      (i_mode),
        .time_counter(w_raw_msec),
        .o_tick      (w_sec_tick)
    );

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk         (clk),
        .rst         (rst),
        .i_runstop   (i_runstop),
        .i_clear     (i_clear),
        .o_tick_100hz(w_tick_100hz)
    );

    // moment unit
    moment #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_MOMENT (
        .clk             (clk),
        .rst             (rst),
        .i_moment_hold   (i_moment_hold),
        .i_moment_capture(i_moment_capture),
        .i_msec          (w_raw_msec),
        .i_sec           (w_raw_sec),
        .i_min           (w_raw_min),
        .i_hour          (w_raw_hour),
        .o_msec          (msec),
        .o_sec           (sec),
        .o_min           (min),
        .o_hour          (hour)
    );

endmodule


module moment #(
        parameter   MSEC_WIDTH = 7,
        parameter   SEC_WIDTH =  6,
        parameter   MIN_WIDTH =  6,
        parameter   HOUR_WIDTH = 5
) (
    input clk,
    input rst,
    input i_moment_hold,
    input i_moment_capture,
    
    input [MSEC_WIDTH  -1 : 0] i_msec,
    input [ SEC_WIDTH - 1 : 0] i_sec,
    input [ MIN_WIDTH - 1 : 0] i_min,
    input [  HOUR_WIDTH - 1:0] i_hour,
 
    output [MSEC_WIDTH  -1 : 0] o_msec,
    output [ SEC_WIDTH - 1 : 0] o_sec,
    output [ MIN_WIDTH - 1 : 0] o_min,
    output [  HOUR_WIDTH - 1:0] o_hour
);

    reg [MSEC_WIDTH  -1 : 0] r_msec;
    reg [ SEC_WIDTH - 1 : 0] r_sec;
    reg [ MIN_WIDTH - 1 : 0] r_min;
    reg [  HOUR_WIDTH - 1:0] r_hour;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_msec  <= 0;
            r_sec   <= 0;
            r_min   <= 0;
            r_hour  <= 0;
        end else if (i_moment_capture == 1'b1) begin
            r_msec  <=  i_msec;
            r_sec   <=  i_sec;                 
            r_min   <=  i_min;
            r_hour  <=  i_hour;            
        end
    end

    assign  o_msec = i_moment_hold ? r_msec : i_msec;
    assign  o_sec = i_moment_hold  ? r_sec : i_sec;
    assign  o_min = i_moment_hold  ? r_min : i_min;
    assign  o_hour = i_moment_hold ? r_hour : i_hour;
    // assign out_mux = (sel) ? in1 : in0;  

endmodule




module tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
) (
    input                         clk,
    input                         rst,
    input                         i_tick,
    input                         i_clear,
    input                         i_mode,
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
        if (i_tick) begin
            // output : next, input : current 
            if (i_mode) begin
                counter_next = counter_reg - 1;
                if(counter_reg == 0) begin
                    o_tick = 1'b1;
                    counter_next = TIMES - 1;
                end else begin
                    o_tick = 1'b0;

                end
            end else begin
                counter_next = counter_reg + 1;
                if (counter_reg == TIMES - 1) begin
                    counter_next = 0;
                    o_tick = 1'b1;
            end else begin
                o_tick = 1'b0;
            end
            end
        end else if (i_clear) begin
            counter_next = 0;
            o_tick = 1'b0;
        end
    end

endmodule





module tick_gen_100hz (
    input      clk,
    input      rst,
    input      i_runstop,
    input      i_clear,
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
            if (i_runstop) begin
                counter_reg  <= counter_reg + 1;
                if (counter_reg == F_COUNT - 1) begin
                counter_reg  <= 0;
                o_tick_100hz <= 1'b1;
            end else begin
                o_tick_100hz <= 1'b0;
            end
        end else if (i_clear) begin
            counter_reg <= 0;
            o_tick_100hz <= 1'b0;
        end
        end
    end
endmodule

`timescale 1ns / 1ps


module stopwatch_control_unit (
    input       clk,
    input       rst,
    input       i_run_stop,
    input       i_clear,
    input       i_mode,
    input       i_moment,      // MOMENT ++
    //input      [2:0]sw,
    output      o_mode,
    output reg  o_clear,
    output reg  o_run_stop,
    output reg  o_moment_hold,      // ++
    output reg  o_moment_capture    // ++
);
    // state
    parameter [2:0] STOP = 0, RUN = 1, CLEAR = 2, MODE = 3, MOMENT = 4;
    
    reg     [2:0] c_state, n_state;
    reg     mode_reg, mode_next;
    reg     moment_hold_next;

    assign o_mode = mode_reg;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state         <= STOP;
            mode_reg        <= 1'b0;  // up_count
            o_moment_hold   <= 1'b0;
        end else begin
            c_state       <= n_state;
            mode_reg      <= mode_next;
            o_moment_hold <= moment_hold_next;
        end
    end
    // next ,output CL
    always @(*) begin
        n_state          = c_state;
        mode_next        = mode_reg;
        moment_hold_next = o_moment_hold;

        o_clear          = 1'b0;
        o_run_stop       = 1'b0;
        o_moment_capture = 1'b0;
        case (c_state)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear    = 1'b0;
                if (i_run_stop) begin
                    n_state = RUN;
                end else if (i_clear) begin
                    n_state = CLEAR;
                end else if (i_mode) begin
                    n_state = MODE;
                end else n_state = c_state;

            end
            RUN: begin
                o_run_stop = 1'b1;
                if (i_run_stop) begin
                    n_state = STOP;
                end else if (i_moment) begin
                    n_state = MOMENT;
                end else begin
                    n_state = c_state;
                end
            end
            CLEAR: begin
                o_clear = 1'b1;
                n_state = STOP;
            end
            MODE: begin
                mode_next = ~mode_reg;
                n_state   = STOP;
            end
            MOMENT: begin
                n_state = RUN;
                if (o_moment_hold == 1'b0) begin
                    moment_hold_next = 1'b1;
                    o_moment_capture = 1'b1;
                end else begin
                    moment_hold_next = 1'b0;
                end
            end

            default: begin
                n_state = STOP;
            end

        endcase
    end

endmodule


