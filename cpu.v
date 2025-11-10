`timescale 1ns / 1ps
`include "defines.v"

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
wire [31:0] operand1; 
wire [31:0] operand2; 
wire [31:0] alu_result;
wire [31:0] mem_data;
wire [31:0] pc_add_four;
wire [31:0] pc_shifted_flow;
wire [1:0] PC_Sel;
wire [1:0] writeData_Sel;
wire AUIPC_Sel;
wire endProgram;

wire jalr, jump, branch, memread, memwrite, alusrc, regwrite, memtoreg;
wire [1:0] aluop;
wire [3:0] alu_selected;
wire cf, zf, vf, sf;
wire shouldJump;

//for fpga
//wire [13:0] control_signals;
//assign control_signals = {2'b00, aluop, alu_selected, cf, zf, vf, sf, shouldJump, branch, memread, memtoreg, memwrite, alusrc, regwrite};

nbit_reg #(32) pc(.load(1'b1), .clk(clk), .rst(rst), .data(next_pc), .q(current_pc)); 

/*	IF => reading is combinational no need to define clock behavior
	Mem => (in case of reading) => posedge clk */
// According to MemRead of the control unit, we will decide the source of the address to read from
InstMem instruction_mem (.addr(current_pc[6:0]), .data_out(instr));

/* Combinational => no need to define clock behavior */
ControlUnit control(
    .Opcode(instr[`IR_opcode]),
	.Funct3(instr[`IR_funct3]),
	.Jalr(jalr),
	.Jump(jump),
	.Branch(branch),
	.MemRead(memread),
	.ALUOp(aluop),
	.MemWrite(memwrite),
	.ALUSrc(alusrc),
	.RegWrite(regwrite),
	.PC_Sel(PC_Sel),
	.writeData_Sel(writeData_Sel),
	.AUIPC_Sel(AUIPC_Sel),
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
rv32_ImmGen immediate(.gen_out(imm), .inst(instr));

assign pc_shifted_flow = current_pc + imm;
assign pc_add_four = current_pc + 32'd4;

wire [31:0] temppc;

mux2x1 #(32) pcmux1(.a(pc_add_four), .b(pc_shifted_flow), .sel(shouldJump), .out(temppc));
mux4x1 #(32) pcmux2(.a(temppc), .b(temppc), .c(alu_result), .d(current_pc), .sel(PC_Sel), .out(next_pc));

/* EX => Combinational: no need to define clock behavior */
// alu control unit selections
ALUControlUnit alu_control(
    .ALUOp(aluop),
	.funct3(instr[`IR_funct3]),
	.Inst_30(instr[30]),
	.ALU_Selection(alu_selected)
	);
	
// alu operands
mux2x1 #(32) data1_pick(.a(data1), .b(current_pc), .sel(alusrc), .out(operand1));
mux2x1 #(32) data2_pick(.a(data2), .b(imm), .sel(alusrc), .out(operand2));

prv32_ALU alu(
	.a(operand1),
	.b(operand2),
	.shamt(instr[`IR_shamt]),
	.r(alu_result),
	.cf(cf),
	.zf(zf),
	.vf(vf),
	.sf(sf),
	.alufn(alu_selected)	
);

// jump control unit -- decides if we should jump based on flags
JumpControl jumpcontrol(
    .jumpSignal(jump | jalr),
    .branchSignal(branch),
	.funct3(instr[`IR_funct3]),
    .zf(zf),
    .slt(alu_result[0]),
    .shouldJump(shouldjump)
);

// mem
DataMem data_mem(
    .clk(clk),
    .MemRead(memread),
    .MemWrite(memwrite),
    .addr(alu_result[6:0]),
    .data_in(data2),
    .data_out(mem_data)
);

// write back
mux4x1 #(32) select_wb (.a(alu_result), .b(mem_data), .c(pc_add_four), .d(32'bx), .sel(writeData_Sel), .out(wb_data));

endmodule