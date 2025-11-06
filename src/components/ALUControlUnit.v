`timescale 1ns / 1ps

module ALUControlUnit (
	input [1:0] ALUOp,
	input [2:0] Inst_14_12,
	input Inst_30,
	output reg [3:0] ALU_Selection
    );

always @(*) begin
	case (ALUOp)
		2'b00: begin // Load/Store instructions
			ALU_Selection = 4'b0010; // ADD
		end
		2'b01: begin // Branch instructions
			ALU_Selection = 4'b0110; // SUB
		end
		2'b10: begin // R-format instructions
			case ({Inst_30, Inst_14_12})
				4'b0000: ALU_Selection = 4'b0010; // ADD
				4'b1000: ALU_Selection = 4'b0110; // SUB
				4'b0111: ALU_Selection = 4'b0000; // AND
				4'b0110: ALU_Selection = 4'b0001; // OR
				default: ALU_Selection = 4'b0000; // Default to AND
			endcase
		end
		default: begin
			ALU_Selection = 4'b0000; // Default to AND
		end
	endcase
end

endmodule
