`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/29 19:21:15
// Design Name: 
// Module Name: ascii_decoder
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


module ascii_decoder(
        input           clk,
        input           rst,
        input   [7:0]   ascii_text,
        output          R,
        output          L,
        output          U,
        output          D,
        output [1:0]    M,
        output [1:0]    T,
        output          S
    );
        reg       R_reg,R_next;
        reg       L_reg,L_next;
        reg       U_reg,U_next;
        reg       D_reg,D_next;
        reg [1:0] M_reg,M_next;
        reg [1:0] T_reg,T_next;
        reg       S_reg,S_next;

        assign R=R_reg;
        assign L=L_reg;
        assign U=U_reg;
        assign D=D_reg;
        assign M=M_reg;
        assign T=T_reg;
        assign S=S_reg;
    always @(posedge clk, posedge rst) begin
        if(rst)begin
            R_reg<=0;
            L_reg<=0;
            U_reg<=0;
            D_reg<=0;
            M_reg<=0;
            T_reg<=0;
            S_reg<=0; 
        end else begin
            R_reg<=R_next;
            L_reg<=L_next;
            U_reg<=U_next;
            D_reg<=D_next;
            M_reg<=M_next;
            T_reg<=T_next;
            S_reg<=S_next;
        end
    end

    always @(*) begin
        R_next=0;
        L_next=0;
        U_next=0;
        D_next=0;
        M_next=M_reg;
        T_next=T_reg;
        S_next=0;
        case (ascii_text)
            8'h52:begin
                R_next=1;
            end
            8'h4C:begin
                L_next=1;
            end
            8'h55:begin
                U_next=1;
            end
            8'h44:begin
                D_next=1;
            end
            8'h4D:begin
                M_next=M_reg+1; //0,1,2,3
            end
            8'h54:begin
                T_next=T_reg+1; //0,1,2,3
            end 
            8'h53:begin
                S_next=1;
            end 
        endcase
    end
endmodule
