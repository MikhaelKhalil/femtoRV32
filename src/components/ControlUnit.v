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
	output reg RegWrite,
	output reg [1:0] PC_Sel,      // PC selection: 00=PC+4, 01=PC+imm (branch/JAL), 10=rs1+imm (JALR), 11=halt
	output reg [1:0] writeData_Sel, // Write-back selection: 00=ALU, 01=Memory, 10=PC+4, 11=unused
	output reg AUIPC_Sel,        // ALU input A selection: 0=rs1 (register), 1=PC (for AUIPC)
	output reg endProgram          // Halt signal: 0=continue, 1=halt (for ECALL, EBREAK, etc.)
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
			PC_Sel = 2'b01;        // PC+imm (if branch taken, handled by JumpControl)
			writeData_Sel = 2'b00;  // ALU (not used, RegWrite=0)
			AUIPC_Sel = 1'b0;      // Use rs1 (for comparison)
			endProgram = 1'b0;
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
			PC_Sel = 2'b00;        // PC+4
			writeData_Sel = 2'b01;  // Memory data
			AUIPC_Sel = 1'b0;      // Use rs1 (base address)
			endProgram = 1'b0;
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
			PC_Sel = 2'b00;        // PC+4
			writeData_Sel = 2'b00; // ALU (not used, RegWrite=0)
			AUIPC_Sel = 1'b0;      // Use rs1 (base address)
			endProgram = 1'b0;
		end
		5'b11_001: begin // OPCODE_JALR
			Jalr = 1'b1;
			Jump = 1'b1;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0; // TODO: neither 0 nor 1, should be the output of the PC + offset adder
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b1;        // Use immediate for address calculation
			RegWrite = 1'b1;
			PC_Sel = 2'b10;        // rs1+imm (JALR: PC = rs1 + imm, clear LSB)
			writeData_Sel = 2'b10; // PC+4 (return address)
			AUIPC_Sel = 1'b0;      // Use rs1 (for address calculation)
			endProgram = 1'b0;
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
			RegWrite = 1'b1;      // JAL writes PC+4 to rd
			PC_Sel = 2'b01;        // PC+imm (JAL: PC = PC + imm)
			writeData_Sel = 2'b10; // PC+4 (return address)
			AUIPC_Sel = 1'b0;      // Use rs1 (not used, but set to 0)
			endProgram = 1'b0;
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
			PC_Sel = 2'b00;        // PC+4
			writeData_Sel = 2'b00; // ALU result
			AUIPC_Sel = 1'b0;      // Use rs1
			endProgram = 1'b0;
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
			PC_Sel = 2'b00;        // PC+4
			writeData_Sel = 2'b00; // ALU result
			AUIPC_Sel = 1'b0;      // Use rs1
			endProgram = 1'b0;
		end
		5'b00_101: begin // OPCODE_AUIPC
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;         // ADD operation
			MemWrite = 1'b0;
			ALUSrc = 1'b1;          // Use immediate (already shifted by 12)
			RegWrite = 1'b1;
			PC_Sel = 2'b00;        // PC+4
			writeData_Sel = 2'b00; // ALU result (PC + imm)
			AUIPC_Sel = 1'b1;      // Select PC (not rs1) for ALU input A
			endProgram = 1'b0;
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
			PC_Sel = 2'b00;        // PC+4
			writeData_Sel = 2'b00; // ALU result (imm passed through ALU_PASS)
			AUIPC_Sel = 1'b0;      // Use rs1 (not used, but set to 0)
			endProgram = 1'b0;
		end
		5'b11_100: begin // OPCODE_SYSTEM (ECALL, EBREAK, PAUSE, FENCE, FENCE.TSO)
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;      // System instructions don't write registers
			PC_Sel = 2'b11;        // Halt (don't update PC)
			writeData_Sel = 2'b00; // ALU (not used, RegWrite=0)
			AUIPC_Sel = 1'b0;      // Use rs1 (not used)
			endProgram = 1'b1;     // Halt execution
		end
		5'b10_001: begin // OPCODE_Custom TODO:
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
			PC_Sel = 2'b00;        // PC+4 (default)
			writeData_Sel = 2'b00; // ALU (not used, RegWrite=0)
			AUIPC_Sel = 1'b0;      // Use rs1 (default)
			endProgram = 1'b0;
		end
		default: begin // Default to NOP
			Jalr = 1'b0;
			Jump = 1'b0;
			Branch = 1'b0;
			MemRead = 1'b0;
			MemtoReg = 1'b0;
			ALUOp = 2'b00;
			MemWrite = 1'b0;
			ALUSrc = 1'b0;
			RegWrite = 1'b0;
			PC_Sel = 2'b00;        // PC+4
			writeData_Sel = 2'b00; // ALU (not used, RegWrite=0)
			AUIPC_Sel = 1'b0;      // Use rs1 (default)
			endProgram = 1'b0;
		end
	endcase
end

endmodule
