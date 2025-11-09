`timescale 1ns / 1ps

`include "src/defines.v"

module cpu(
    input clk, rst
);

wire [31:0] current_pc;
wire [31:0] next_pc;
wire [31:0] instr;
wire [31:0] data1, data2;
wire [31:0] wb_data;
wire [31:0] imm;
wire [31:0] imm_shifted;
wire [31:0] alu_input_a;  // ALU input A (rs1 or PC for AUIPC)
wire [31:0] alu_input_b;  // ALU input B (rs2 or imm)
wire [31:0] alu_result;
wire [31:0] mem_data;
wire [31:0] pc_add_four;
wire [31:0] pc_branch_target;  // PC + imm (for branches/JAL)
wire [31:0] pc_jalr_target;    // rs1 + imm (for JALR)

wire branch, memread, memwrite, alusrc, regwrite, memtoreg;
wire jalr, jump;
wire [1:0] aluop;
wire [1:0] pc_sel;
wire [1:0] writeData_Sel;
wire auipc_sel;
wire endProgram;
wire [3:0] alu_selected;
wire cf, zf, vf, sf;

nbit_reg #(32) pc(.load(1'b1), .clk(clk), .rst(rst), .data(next_pc), .q(current_pc)); 

/*	IF => reading is combinational no need to define clock behavior
	Instruction Memory => combinational read
	Data Memory => (in case of reading) => combinational, (writing) => posedge clk */

// Instruction Memory - Read-only, addressed by PC
// PC is byte-addressed, convert to word address: PC[8:2]
wire [6:0] instr_addr;
assign instr_addr = current_pc[8:2];  // Word address (divide by 4)
instr_mem imem(
    .addr(instr_addr),
    .instruction(instr)
);

// Data Memory - Read-write, addressed by ALU result
// ALU result is byte-addressed, pass full byte address (9 bits: 8:0)
// This allows proper byte/halfword addressing within words
wire [8:0] data_byte_addr;
assign data_byte_addr = alu_result[8:0];  // Byte address (9 bits)
data_mem dmem(
    .clk(clk),
    .MemRead(memread),
    .MemWrite(memwrite),
    .funct3(instr[`IR_funct3]),  // For load/store size (byte/halfword/word)
    .byte_addr(data_byte_addr),
    .data_in(data2),
    .data_out(mem_data)
);

// Control Unit
ControlUnit control(
    .Opcode(instr[`IR_opcode]),
    .Funct3(instr[`IR_funct3]),
    .Jalr(jalr),
    .Jump(jump),
    .Branch(branch),
    .MemRead(memread),
    .MemtoReg(memtoreg),
    .ALUOp(aluop),
    .MemWrite(memwrite),
    .ALUSrc(alusrc),
    .RegWrite(regwrite),
    .PC_Sel(pc_sel),
    .writeData_Sel(writeData_Sel),
    .AUIPC_Sel(auipc_sel),
    .endProgram(endProgram)
);

/*	ID => combinational => no need to define clock behavior
	WB => posedge clk */
RegFile registers(
    .clk(clk),
    .rst(rst),
    .readReg1(instr[`IR_rs1]),
    .readReg2(instr[`IR_rs2]),
    .writeReg(instr[`IR_rd]),
    .writeData(wb_data),
    .regWrite(regwrite),
    .readData1(data1),
    .readData2(data2)
);

/* Combinational => no need to define clock behavior */
rv32_ImmGen immediate(.IR(instr), .Imm(imm));

// PC calculations
assign pc_add_four = current_pc + 32'd4;
// Note: rv32_ImmGen already shifts branch/JAL immediates (LSB=0), so use imm directly
assign pc_branch_target = current_pc + imm;  // For branches/JAL (imm already shifted by rv32_ImmGen)
// For JALR: rs1 + imm, then clear LSB (RISC-V spec)
wire [31:0] jalr_temp;
assign jalr_temp = data1 + imm;
assign pc_jalr_target = {jalr_temp[31:1], 1'b0};  // JALR: (rs1 + imm) & ~1

// Jump Control Unit - determines if branch should be taken
wire shouldjump;
JumpControl jumpcontrol(
    .jumpSignal(jump),
    .branchSignal(branch),
    .funct3(instr[`IR_funct3]),
    .zf(zf),
    .sf(sf),
    .vf(vf),
    .cf(cf),
    .shouldJump(shouldjump)
);

// PC selection mux (4-to-1)
// PC_Sel: 00=PC+4, 01=PC+imm (if shouldJump), 10=rs1+imm (JALR), 11=halt
wire [31:0] pc_selected_target;
assign pc_selected_target = shouldjump ? pc_branch_target : pc_add_four;
mux4x1 #(32) pc_mux(
    .a(pc_add_four),           // 00: PC+4 (normal)
    .b(pc_selected_target),    // 01: PC+imm (branch/JAL if shouldJump)
    .c(pc_jalr_target),        // 10: rs1+imm (JALR)
    .d(current_pc),            // 11: halt (stay at current PC)
    .sel(pc_sel),
    .out(next_pc)
);

/* Combinational => no need to define clock behavior */
// ALU Control Unit
ALUControlUnit alu_control(
    .ALUOp(aluop),
    .funct3(instr[`IR_funct3]),
    .Inst_30(instr[30]),
    .ALU_Selection(alu_selected)
);

// AUIPC mux: select PC or rs1 for ALU input A
mux2x1 #(32) auipc_mux(.a(data1), .b(current_pc), .sel(auipc_sel), .out(alu_input_a));

// ALU input B mux: select rs2 or immediate
mux2x1 #(32) alu_input_b_mux(.a(data2), .b(imm), .sel(alusrc), .out(alu_input_b));

// ALU
prv32_ALU alu(
    .a(alu_input_a),
    .b(alu_input_b),
    .shamt(instr[`IR_shamt]),
    .r(alu_result),
    .cf(cf),
    .zf(zf),
    .vf(vf),
    .sf(sf),
    .alufn(alu_selected)
);

// Write-back selection mux (4-to-1)
// writeData_Sel: 00=ALU, 01=Memory, 10=PC+4, 11=unused
wire [31:0] lui_auipc_imm;  // For LUI/AUIPC: imm << 12 (imm already has lower 12 bits zero)
assign lui_auipc_imm = imm;  // ImmGen should already have lower 12 bits zero for U-type
mux4x1 #(32) writeback_mux(
    .a(alu_result),    // 00: ALU result
    .b(mem_data),      // 01: Memory data (loads)
    .c(pc_add_four),   // 10: PC+4 (JAL/JALR return address)
    .d(lui_auipc_imm), // 11: Immediate (for LUI/AUIPC - shifted immediate)
    .sel(writeData_Sel),
    .out(wb_data)
);

endmodule
