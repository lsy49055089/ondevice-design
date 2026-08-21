`timescale 1ns / 1ps

`include "define.vh"

module data_mem (
    input  logic clk,
    input  logic [31:0] daddr,
    input  logic dwe,
    input  logic [2:0] mem_mode,
    input  logic [31:0] dwdata,
    output logic [31:0] drdata
);


    logic [31:0] data_ram [0:63]  ;            //32bit = word 선언(SW) / 8bit = byte 선언(Riscv)(SB)


    always @(posedge clk) begin
        if (dwe) begin
            case (mem_mode)
                `SW: data_ram[(daddr[31:2])] <= dwdata;

                `SH: begin
                    if (daddr[1] == 1'b0) begin
                        data_ram[daddr[31:2]][15:0]  <= dwdata [15:0];
                    end else begin
                        data_ram[daddr[31:2]][31:16] <=  dwdata[15:0];
                    end
                end

                `SB:begin
                    case ({daddr[1],daddr[0]})
                        2'b11:begin
                            data_ram[daddr[31:2]][31:24] <= dwdata[7:0];
                        end 

                        2'b10:begin
                            data_ram[daddr[31:2]][23:16] <= dwdata[7:0];
                        end
                        
                        2'b01:begin
                            data_ram[daddr[31:2]][15:8] <= dwdata[7:0];
                        end

                        2'b00:begin
                            data_ram[daddr[31:2]][7:0]  <= dwdata[7:0];
                        end
                    endcase
                end
            endcase
        end
    end

    always_comb begin
        drdata = 32'd0;
        case (mem_mode) 
            `LB: begin  //sign 8bit
                case ({daddr[1],daddr[0]})
                    2'b11:begin
                        drdata = {{24{data_ram[daddr[31:2]][31]}},data_ram[daddr[31:2]][31:24]};
                    end 

                    2'b10:begin
                        drdata = {{24{data_ram[daddr[31:2]][23]}},data_ram[daddr[31:2]][23:16]};
                    end
                
                    2'b01:begin
                        drdata = {{24{data_ram[daddr[31:2]][15]}},data_ram[daddr[31:2]][15:8]};
                    end

                    2'b00:begin
                        drdata = {{24{data_ram[daddr[31:2]][7]}},data_ram[daddr[31:2]][7:0]};
                    end
                endcase
            end
            
            
            `LH: begin //sign 16
                case ({daddr[1]})
                    1'b0:begin
                        drdata = {{16{data_ram[daddr[31:2]][15]}},data_ram[daddr[31:2]][15:0]};
                    end

                    1'b1:begin
                        drdata = {{16{data_ram[daddr[31:2]][31]}},data_ram[daddr[31:2]][31:16]};
                    end
                endcase
            end
            

            `LW: begin
                drdata = data_ram[daddr[31:2]];
            end
            

            `LBU: begin //8bits
                case ({daddr[1],daddr[0]})
                    2'b11:begin
                        drdata = {{24{1'b0}},data_ram[daddr[31:2]][31:24]};
                    end 

                    2'b10:begin
                        drdata = {{24{1'b0}},data_ram[daddr[31:2]][23:16]};
                    end
                
                    2'b01:begin
                        drdata = {{24{1'b0}},data_ram[daddr[31:2]][15:8]};
                    end

                    2'b00:begin
                        drdata = {{24{1'b0}},data_ram[daddr[31:2]][7:0]};
                    end
                endcase
            end


            `LHU: begin //16bits
                case ({daddr[1]})
                    1'b0:begin
                        drdata = {{16{1'b0}},data_ram[daddr[31:2]][15:0]};
                    end

                    1'b1:begin
                        drdata = {{16{1'b0}},data_ram[daddr[31:2]][31:16]};
                    end
                endcase
            end
        endcase
    end

endmodule

