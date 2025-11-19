`timescale 1ns / 1ps

module ForwardingUnit(
    input ex_mem_regwrite,
    input [4:0] ex_mem_rd, id_ex_rs1, id_ex_rs2,  
    input mem_wb_regwrite,
    input [4:0] mem_wb_rd,
    output reg [1:0] forwardA, forwardB
);
    always @(*) begin
        if(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) forwardA = 2'b10;
        else if(mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) forwardA = 2'b01;
        else forwardA = 2'b00; 
        
        if(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) forwardB = 2'b10;
        else if(mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) forwardB = 2'b01; 
        else forwardB = 2'b00;    
    end
    
endmodule
