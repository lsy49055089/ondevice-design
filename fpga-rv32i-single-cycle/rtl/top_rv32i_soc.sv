`timescale 1ns / 1ps


module top_rv32i_soc (
    input clk,
    input rst

);

    logic [31:0] instr_addr, instr_code, daddr, dwdata,drdata;
    logic [ 2:0] mem_mode;
    logic        dwe;
    
    rv32i_cpu U_RV32I_CPU (.*);
    instruction_mem U_INSTR_ROM (.*);
    data_mem U_DATA_RAM (.*);
    
endmodule
