`timescale 1ns / 1ps

module singlecycle_tb();
    localparam clk_period = 10;

    reg clk;
    reg rst;
    
    initial begin
        clk = 0;
        forever #(clk_period/2) clk = ~clk;
    end
    
    cpu test_cpu(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        rst = 1;
        #(clk_period * 2);
        
        rst = 0;
        #(clk_period * 51);
        $finish();
    end
endmodule
