`timescale 1ns / 1ps

module ControlUnit (
	input [6:2] Inst,
	output reg Jalr,
	output reg Jump,
	output reg BranchNotZero,
	output reg BranchZero,
	output reg MemRead,
	output reg MemtoReg,
	output reg [1:0] ALUOp,
	output reg MemWrite,
	output reg ALUSrc,
	output reg RegWrite
    );

always @(*) begin
	case (Inst)
		5'b11_000: begin // OPCODE_BranchZero
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b1;
			MemRead = 1'b0;
			MemtoReg = 1'bx;
			ALUOp = 2'b01;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
		end
		5'b00_000: begin // OPCODE_Load
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b1;
			MemtoReg = 1'b1;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
		end
		5'b01_000: begin // OPCODE_Store
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'bx;
			ALUOp = 2'b00;
			MemWrite = 1'b1;
			ALUSrc = 1'b1;
			RegWrite = 1'b0;
		end
		5'b11_001: begin // OPCODE_JALR TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
		end
		5'b11_011: begin // OPCODE_JAL TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
		end
		5'b00_100: begin // OPCODE_Arith_I TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
		end
		5'b01_100: begin // OPCODE_Arith_R
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
		end
		5'b00_101: begin // OPCODE_AUIPC TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
		end
		5'b01_101: begin // OPCODE_LUI TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
		end
		5'b11_100: begin // OPCODE_SYSTEM TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
		end
		5'b10_001: begin // OPCODE_Custom TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			BranchNotZero = 1'bx; // TODO: 
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
		end
		default: begin // Default to NOP
			Jalr = 1'b0;
			Jump = 1'b0;
			BranchNotZero = 1'b0;
			BranchZero = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
		end
	endcase
end

endmodule
