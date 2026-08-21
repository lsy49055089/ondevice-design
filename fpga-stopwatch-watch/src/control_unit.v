`timescale 1ns / 1ps


module control_unit (
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


