`timescale 1ns / 1ps

module HazardDetectionUnit(
    input [4:0] if_id_rs1, if_id_rs2, id_ex_rd,
    input id_ex_memread, 
    output reg stall
);

    always @(*) begin
        if((if_id_rs1 == id_ex_rd || if_id_rs2 == id_ex_rd) && (id_ex_memread && (id_ex_rd != 5'b0))) stall = 1;
        else stall = 0;
    end
endmodule
