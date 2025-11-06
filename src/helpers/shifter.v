`timescale 1ns / 1ps

module shifter(
    input [31:0] a,
    input [4:0] shamt,
    input [1:0] type,
    output [31:0] r
);
    
    assign r = (type == 2'b00) ? a >> shamt :
               (type == 2'b10) ? $signed(a) >>> shamt :
               (type == 2'b01) ? a << shamt :
               32'b0;
    
endmodule
