`timescale 1ns / 1ps

module DataMem (
    input clk,
    input MemRead,
    input MemWrite,
    input [`IR_funct3] funct3,
    input [7:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out
);

    reg [7:0] mem [0:255];

    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b010: data_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};  // LW
                3'b001: data_out = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};      // LH
                3'b000: data_out = {{24{mem[addr][7]}}, mem[addr]};                     // LB
                3'b100: data_out = {24'b0, mem[addr]};                                  // LBU
                3'b101: data_out = {16'b0, mem[addr+1], mem[addr]};                     // LHU
                default: data_out = 32'b0;
            endcase
        end else data_out = 32'b0;
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b010: begin                       // SW
                    mem[addr] <= data_in[7:0];
                    mem[addr+1] <= data_in[15:8];
                    mem[addr+2] <= data_in[23:16];
                    mem[addr+3] <= data_in[31:24];
                end
                3'b001: begin                       // SH
                    mem[addr] <= data_in[7:0];
                    mem[addr+1] <= data_in[15:8];
                end
                3'b000: begin                       // SB
                    mem[addr] <= data_in[7:0];
                end
            endcase
        end
    end
    
    initial begin
        mem[0] = 32'd12;
        mem[4] = 32'd34;
        mem[8] = 32'd56;
        mem[12] = 32'd67;
        mem[16] = 32'd78;
    end
    
endmodule
