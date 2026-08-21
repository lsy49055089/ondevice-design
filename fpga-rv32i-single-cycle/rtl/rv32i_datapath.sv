`timescale 1ns / 1ps
`include "define.vh"

module rv32i_datapath (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instr_code,
    input  logic        rf_we,
    input  logic [ 2:0] rfsrc_sel,
    input  logic        branch,
    input  logic        jal,
    input  logic        jalr,
    input  logic        alusrc_sel,
    input  logic [31:0] drdata,
    input  logic [ 3:0] alu_control,
    output logic [31:0] instr_addr,
    output logic [31:0] daddr,
    output logic [31:0] dwdata
);

    logic [31:0] rs1, rs2, alu_result, alu_rs2_mux, imm_extend, wb_out;
    logic [31:0] pc_imm, pc_4;
    logic b_taken;

    assign daddr = alu_result;
    assign dwdata = rs2;

    mux_wb U_WB_MUX(
        .in0    (alu_result),
        .in1    (drdata),
        .in2    (imm_extend),
        .in3    (pc_imm),
        .in4    (pc_4),
        .sel    (rfsrc_sel),
        .wb_out (wb_out)
    );

    register_file U_REG_FILE (
        .clk    (clk),
        .rf_we  (rf_we),
        .wdata  (wb_out),
        .waddr  (instr_code[11:7]),
        .raddr1 (instr_code[19:15]),
        .raddr2 (instr_code[24:20]),
        .rdata1 (rs1),
        .rdata2 (rs2)
    );

    alu U_ALU (
        .alu_control(alu_control),
        .rs1        (rs1),
        .rs2        (alu_rs2_mux),
        .alu_result (alu_result),
        .b_taken    (b_taken)
    );

    mux_2x1 U_ALU_RS2_MUX(
        .in0    (rs2),
        .in1    (imm_extend),
        .sel    (alusrc_sel),
        .out_mux(alu_rs2_mux)
    );

    imm_extend U_IMM_EXTEND (
        .instr_code (instr_code),
        .imm_extend (imm_extend)
    );

    program_counter U_PC (
        .clk       (clk),
        .rst       (rst),
        .b_taken   (b_taken),
        .branch    (branch),
        .jal       (jal),
        .jalr      (jalr),
        .rs1       (rs1),
        .pc_in     (instr_addr),     //for next program count
        .imm_extend(imm_extend),    // current program count
        .pc_out    (instr_addr),
        .pc_imm    (pc_imm),
        .pc_4      (pc_4)
    );
endmodule



module program_counter (
    input         clk,
    input         rst,
    input         b_taken,
    input         branch,
    input         jal,
    input         jalr,
    input  [31:0] rs1,
    input  [31:0] imm_extend,
    input  [31:0] pc_in,
    output [31:0] pc_out,
    output [31:0] pc_imm,
    output [31:0] pc_4
);

    logic [31:0] pc_reg, pc_next, pc_jalr;


    assign pc_out = pc_reg;
    assign pc_4 = pc_in + 32'd4;
    assign pc_imm = jalr ? ((rs1 + imm_extend) & 32'hFFFF_FFFE) : (pc_jalr + imm_extend); 
            // PC를 rs1 + imm 위치로 점프시키고 현재 PC+4를 rd에 저장

    mux_2x1 U_PC_JALR_MUX(
        .in0    (pc_in),
        .in1    (rs1),
        .sel    (jalr),
        .out_mux(pc_jalr)
    );


    mux_2x1 U_PC_SRC_MUX(
        .in0    (pc_4),
        .in1    (pc_imm),
        .sel    (jalr | jal | (branch & b_taken)),
        .out_mux(pc_next)
    );

    //register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 0;
        end else begin
            pc_reg <= pc_next;
        end
    end
endmodule




module mux_wb(
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  logic [31:0] in3,
    input  logic [31:0] in4,
    input  logic [ 2:0] sel,
    output logic [31:0] wb_out
);

    always_comb begin
        wb_out = 32'd0;
        case (sel) 
            3'b000: begin       //load alu
                wb_out = in0;
            end

            3'b001: begin       //load data mem
                wb_out = in1;
            end

            3'b010: begin       // load LUI
                wb_out = in2;
            end

            3'b011: begin       // load add upper imm to pc
                wb_out = in3;
            end

            3'b100: begin       // load JAL_JARL: PC + 4
                wb_out = in4;
            end    
        endcase
    end
endmodule








module mux_2x1(
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic        sel,
    output logic [31:0] out_mux
);

assign out_mux = (sel) ? in1 : in0;
endmodule







module imm_extend (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_extend
);

// logic [11:0] imm = {instr_code[31:25], instr_code[11:7]}

    always_comb begin
        imm_extend = 32'd0;
        case(instr_code[6:0])
            `S_TYPE :           imm_extend = {{20{instr_code[31]}},instr_code[31:25],instr_code[11:7]};
            `IL_TYPE, `I_TYPE : imm_extend = {{20{instr_code[31]}},instr_code[31:20]};
            `B_TYPE :           imm_extend = {{20{instr_code[31]}},instr_code[7],instr_code[30:25],instr_code[11:8],1'b0};
            `UL_TYPE, `UA_TYPE: imm_extend = {instr_code[31:12],12'h000};
            `J_TYPE :           imm_extend = {{12{instr_code[31]}},instr_code[19:12],instr_code[20],instr_code[30:21],1'b0};
            `JL_TYPE:           imm_extend = {{20{instr_code[31]}}, instr_code[31:20]};
        endcase
    end
endmodule







module alu (
    input  logic [ 3:0] alu_control,
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    output logic [31:0] alu_result,
    output logic b_taken
);

    always_comb begin
        alu_result = 32'd0;
        case (alu_control)
            //R-type  RD = RS1 + RS2
            //I-type  
            `ADD:  alu_result = rs1 + rs2;
            `SUB:  alu_result = rs1 - rs2;
            `SLL:  alu_result = rs1 << rs2[4:0];
            `SLT:  alu_result = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
            `SLTU: alu_result = (rs1 < rs2) ? 1 : 0;  
            `XOR:  alu_result = rs1 ^ rs2;  //cap
            `SRL:  alu_result = rs1 >> rs2[4:0];
            `SRA:  alu_result = $signed(rs1) >>> rs2[4:0];
            `OR:   alu_result = rs1 | rs2;
            `AND:  alu_result = rs1 & rs2;
        endcase
    end
    
    //assign b_taken = (rs1 == rs2) ? 1: 0;

    always_comb begin
        b_taken = 0;
        case (alu_control[2:0])  //삼항연사자에서 x떠서 if로 바꿈. 
            `BEQ: begin
                if (rs1 == rs2) b_taken = 1;
                else b_taken = 0;
            end
            `BNE: begin
                if (rs1 != rs2) b_taken = 1;
                else b_taken = 0;
            end

            `BLTU: begin
                if ((rs1) < (rs2)) b_taken = 1;
                else b_taken = 0;
            end
  
            `BGE: begin  
                if ($signed(rs1) >= $signed (rs2)) b_taken = 1;
                else b_taken = 0;
            end

            `BGEU: begin
                if ((rs1) >= (rs2)) b_taken = 1;
                else b_taken = 0;
            end

            `BLT: begin
                if ($signed(rs1) < $signed (rs2)) b_taken = 1;
                else b_taken = 0;
            end
        endcase
    end
endmodule





// module register_file (
//     input  logic        clk,
//     input  logic        rf_we,   //register file write enable
//     input  logic [ 4:0] waddr,
//     input  logic [31:0] wdata,
//     input  logic [ 4:0] raddr1,
//     input  logic [ 4:0] raddr2,
//     output logic [31:0] rdata1,
//     output logic [31:0] rdata2
// );


//     logic [31:0] register_file[1:31];
// `ifdef TEST_SIMULATION
//     int i = 0;
//     initial begin
//         for (i = 1; i < 32; i++) register_file[i] = i;
//     end
// `endif 
//     always @(posedge clk) begin
//         if (rf_we) begin
//             register_file[waddr] <= wdata;
//         end
//     end
//     assign rdata1 = (raddr1 != 0) ? register_file [raddr1] :32'd0; // 조합으로 해야 1cycle 내에 처리됨. 순차로 하면 1cycle내에 처리가 안됨.
//     assign rdata2 = (raddr2 != 0) ? register_file [raddr2] : 32'd0;
// endmodule


module register_file (
    input  logic        clk,
    input  logic        rf_we,
    input  logic [ 4:0] waddr,
    input  logic [31:0] wdata,
    input  logic [ 4:0] raddr1,
    input  logic [ 4:0] raddr2,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);

    logic [31:0] register_file[1:31];

    integer i;

    initial begin
        for (i = 1; i < 32; i = i + 1) begin
            register_file[i] = 32'd0;
        end

        register_file[1] = 32'd1;
        register_file[2] = 32'd2;
    end

    always @(posedge clk) begin
        if (rf_we && waddr != 0) begin
            register_file[waddr] <= wdata;
        end
    end

    assign rdata1 = (raddr1 != 0) ? register_file[raddr1] : 32'd0;
    assign rdata2 = (raddr2 != 0) ? register_file[raddr2] : 32'd0;

endmodule