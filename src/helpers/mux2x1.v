`timescale 1ns / 1ps

module mux2x1 #(parameter n = 8) (
    input [n-1:0]a, 
    input [n-1:0]b, 
    input sel, 
    output reg [n-1:0]out
    );
    
    always @(*) begin
        if (sel == 1'b0) out = a;
        else out = b; 
    end 
    
endmodule
