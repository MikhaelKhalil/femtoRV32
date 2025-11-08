`timescale 1ns / 1ps

module ControlUnit (
	input [6:2] Opcode,
	input [`IR_funct3] Funct3,
	output reg Jalr,
	output reg Jump,
	output reg Branch,
	output reg MemRead,
	output reg MemtoReg,
	output reg [1:0] ALUOp,
	output reg MemWrite,
	output reg ALUSrc,
	output reg RegWrite
    );

// TODO: change MemToReg to serve AUIPC

always @(*) begin
	case (Opcode)
		5'b11_000: begin // OPCODE_Branch
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b1;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b01;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
		end
		5'b00_000: begin // OPCODE_Load
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b1;
			MemtoReg = 1'b1;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
		end
		5'b01_000: begin // OPCODE_Store
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'bx;
			ALUOp = 2'b00;
			MemWrite = 1'b1;
			ALUSrc = 1'b1;
			RegWrite = 1'b0;
		end
		5'b11_001: begin // OPCODE_JALR
			Jalr = 1'b1;
			Jump = 1'b1;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0; // TODO: neither 0 nor 1, should be the output of the PC + offset adder
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
		end
		5'b11_011: begin // OPCODE_JAL
			Jalr = 1'b0;
			Jump = 1'b1;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'bx;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
		end
		5'b00_100: begin // OPCODE_Arith_I
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
		end
		5'b01_100: begin // OPCODE_Arith_R
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
		end
		5'b00_101: begin // OPCODE_AUIPC
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0; // TODO: should add a mux in front of alusrc1 to select between readdata1 and the PC
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
		end
		5'b01_101: begin // OPCODE_LUI
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b10;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
		end
		5'b11_100: begin // OPCODE_SYSTEM TODO:
			Jalr = 1'bx; // TODO: 
			Jump = 1'bx; // TODO: 
			Branch = 1'b0;
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
			Branch = 1'b0;
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
