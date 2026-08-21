`timescale 1ns / 1ps


module rv32i_cpu (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instr_code,
    input  logic [31:0] drdata,
    output logic [31:0] instr_addr,
    output logic [2:0]  mem_mode,
    output logic        dwe,
    output logic [31:0] daddr,
    output logic [31:0] dwdata
);


logic rf_we, alusrc_sel, branch;
logic [3:0] alu_control;
logic [2:0] rfsrc_sel;
logic jal, jalr;


rv32i_datapath U_DATA_PATH(.*);

control_unit U_CTRL_UNIT( .*); //clk 없음, 1clk마다 자동으로 값이 계속 바껴서 들어옴.


endmodule
