`timescale 1ns / 1ps

module ALUControlUnit (
	input [1:0] ALUOp,
	input [2:0] funct3,
	input Inst_30,
	output reg [3:0] ALU_Selection
    );

always @(*) begin
	case (ALUOp)
		2'b00: begin // Load/Store & Jump instructions
			ALU_Selection = 4'b00_00; // ADD
		end
		2'b01: begin // Branch instructions: all use SUB, flags determine branch condition
			ALU_Selection = `ALU_SUB; 
		end
		2'b10: begin // R-format instructions
			case ({Inst_30, funct3})
				4'b0_000: ALU_Selection = `ALU_ADD; // ADD
				4'b1_000: ALU_Selection = `ALU_SUB; // SUB

				4'b0_001: ALU_Selection = `ALU_SLL; // SLL

				4'b0_010: ALU_Selection = `ALU_SLT; // SLT

				4'b0_011: ALU_Selection = `ALU_SLTU; // SLTU

				4'b0_100: ALU_Selection = `ALU_XOR; // XOR

				4'b0_101: ALU_Selection = `ALU_SRL; // SRL
				4'b1_101: ALU_Selection = `ALU_SRA; // SRA

				4'b0_110: ALU_Selection = `ALU_OR; // OR

				4'b0_111: ALU_Selection = `ALU_AND; // AND
				
				default: ALU_Selection = `ALU_PASS; // Default to PASS
			endcase
		end
		default: begin
			ALU_Selection = 4'b0000; // Default to AND
		end
	endcase
end

endmodule
