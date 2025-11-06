`timescale 1ns / 1ps

module immgen(output reg [31:0] gen_out, input [31:0] inst);

always @(*) begin
    if (inst[6] == 1'b1) gen_out = {{20{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8]}; // beq, sb=type
    else if (inst[5] == 1'b0) gen_out = {{20{inst[31]}}, inst[31:20]}; // lw, i-type
    else if (inst[5] == 1'b1) gen_out = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // sw, s-type
    else gen_out = 32'b0;
end

endmodule
