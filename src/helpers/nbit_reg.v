`timescale 1ns / 1ps

module nbit_reg #(parameter n = 8)(
    input load, clk, rst, 
    input [n-1:0] data,
    output [n-1:0] q
    );
    
    
    genvar i;
    generate 
        for(i=0; i<n; i=i+1) begin: loop 
            wire out;
            mux2x1  #(1) mx (q[i], data[i], load, out);
            dflipflop generating (clk, rst, out, q[i]);
        end
    endgenerate
endmodule
