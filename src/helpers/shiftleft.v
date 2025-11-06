`timescale 1ns / 1ps

module shiftleft #(parameter n = 8)(
    input [n-1:0] a,
    output [n-1:0] out
    );
    
    assign out = {a[n-2:0], 1'b0};
endmodule
