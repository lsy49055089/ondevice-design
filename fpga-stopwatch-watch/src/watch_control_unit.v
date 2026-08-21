`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/17 11:36:46
// Design Name: 
// Module Name: watch_control_unit
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

// mode

module watch_control_unit (
    input      clk,
    input      rst,
    input      i_btnR,      // right
    input      i_btnL,      // left
    input [1:0] sw,
    output [1:0] o_led,o_mode // NORMAL = 0, SEC = 1, MIN = 2, HOUR = 3;
);
    // state
    parameter [1:0] NORMAL = 0, SEC = 1, MIN = 2, HOUR = 3;
    reg [1:0] c_state, n_state;

    assign o_led = c_state;      // you have to redifine
    assign o_mode = c_state;      // you have to redifine

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state  <= NORMAL;
        end else begin
            c_state  <= n_state;
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
                    n_state = MIN;
                end else if (i_btnL) begin
                    n_state = NORMAL;
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
                    n_state = NORMAL;
                end else if (i_btnL) begin
                    n_state = MIN;
                end else n_state = c_state;
            end
        endcase
    end

endmodule
