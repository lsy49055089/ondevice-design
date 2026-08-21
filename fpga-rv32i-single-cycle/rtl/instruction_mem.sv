`timescale 1ns / 1ps

module instruction_mem (
    input  logic [31:0] instr_addr,
    output logic [31:0] instr_code
);

    logic [31:0] instr_rom [0:127];      //word address 1씩 증가

initial begin

    // =========================
    // LUI
    // x1 = 0x12345000
    // =========================
    instr_rom[0] = 32'h123450b7; // LUI x1, 0x12345

    // =========================
    // AUIPC
    // x2 = PC + 0x1000
    // =========================
    instr_rom[1] = 32'h00001117; // AUIPC x2, 0x1

    // =========================
    // AUIPC
    // x3 = PC + 0x2000
    // =========================
    instr_rom[2] = 32'h00002197; // AUIPC x3, 0x2

    // NOP
    instr_rom[3] = 32'h00000013;
    instr_rom[4] = 32'h00000013;

end
    assign instr_code = instr_rom[instr_addr[31:2]];        //byte address 4씩 증가


endmodule

