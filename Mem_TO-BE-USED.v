`timescale 1ns / 1ps

module Mem (
    input clk,
    input MemRead,
    input MemWrite,
    input [6:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
);

    reg [31:0] mem [0:127];

    // assign data_out = (MemRead) ? mem[addr] : 32'b0;
    // Always output the data at addr regardless of MemRead because of the single-ported memory design
    assign data_out = mem[addr];

    always @(posedge clk) begin
        if (MemWrite)
            mem[addr] <= data_in;
    end
    
    // Program Provided in the Report (Lab 6)
    initial begin
        // Let the IMEM start from address 0
        
        // TODO: the program needs to be adjusted to match the new memory locations
        // mem[0]=32'b000000000000_00000_010_00001_0000011 ; //lw x1, 0(x0)  17
        // mem[1]=32'b000000000100_00000_010_00010_0000011 ; //lw x2, 4(x0)  9
        // mem[2]=32'b000000001000_00000_010_00011_0000011 ; //lw x3, 8(x0)    25
        // mem[3]=32'b0000000_00010_00001_110_00100_0110011 ; //or x4, x1, x2  25
        // mem[4]=32'b0_000000_00011_00100_000_0100_0_1100011; //beq x4, x3, 4     xx or 0
        // mem[5]=32'b0000000_00010_00001_000_00011_0110011 ; //add x3, x1, x2     skipped
        // mem[6]=32'b0000000_00010_00011_000_00101_0110011 ; //add x5, x3, x2     34
        // mem[7]=32'b0000000_00101_00000_010_01100_0100011; //sw x5, 12(x0)       xx or 0
        // mem[8]=32'b000000001100_00000_010_00110_0000011 ; //lw x6, 12(x0)       34
        // mem[9]=32'b0000000_00001_00110_111_00111_0110011 ; //and x7, x6, x1     0
        // mem[10]=32'b0100000_00010_00001_000_01000_0110011 ; //sub x8, x1, x2    8
        // mem[11]=32'b0000000_00010_00001_000_00000_0110011 ; //add x0, x1, x2    26, writte to reg x0 -> 0
        // mem[12]=32'b0000000_00001_00000_000_01001_0110011 ; //add x9, x0, x1    17

        // Let DateMem start from address 64
        mem[64]=32'd17;
        mem[65]=32'd9;
        mem[65]=32'd25;
    end
    
endmodule
