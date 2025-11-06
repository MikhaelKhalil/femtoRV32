`timescale 1ns / 1ps

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
wire [31:0] used; 
wire [31:0] alu_result;
wire [31:0] mem_data;
wire [31:0] pc_add_four;
wire [31:0] pc_shifted_flow;

wire branch, memread, memwrite, alusrc, regwrite, memtoreg;
wire [1:0] aluop;
wire [3:0] alu_selected;
wire zf;
wire arewebranching;

wire [13:0] control_signals;
assign control_signals = {2'b00, aluop, alu_selected, cf, zf, vf, sf, arewebranching, branch, memread, memtoreg, memwrite, alusrc, regwrite};

nbit_reg #(32) pc(.load(1'b1), .clk(clk), .rst(rst), .data(next_pc), .q(current_pc)); 

/*	IF => reading is combinational no need to define clock behavior
	Mem => (in case of reading) => posedge clk */
// According to MemRead of the control unit, we will decide the source of the address to read from
wire [6:0] read_address;
assign read_address = memread ? alu_result[6:0] : current_pc[6:0];
Mem memory (
    .clk(clk),
    .MemRead(memread),
    .MemWrite(memwrite),
    .addr(read_address),
    .data_in(data2),
    .data_out(mem_data)
    );

/* Combinational => no need to define clock behavior */
ControlUnit control(
    .Inst(instr[6:2]),
	.Branch(branch),
	.MemRead(memread),
	.MemtoReg(memtoreg),
	.ALUOp(aluop),
	.MemWrite(memwrite),
	.ALUSrc(alusrc),
	.RegWrite(regwrite)
);

/*	ID => combinational => no need to define clock behavior
	WB => posedge clk */
RegFile registers(
	.clk(clk),
	.rst(rst),
	.readReg1(instr[19:15]),
	.readReg2(instr[24:20]),
	.writeReg(instr[11:7]),
	.writeData(wb_data),
	.regWrite(regwrite),
	.readData1(data1),
	.readData2(data2)
	);

/* Combinational => no need to define clock behavior */
immgen immediate(.gen_out(imm), .inst(instr));

// for pc, shifted imm calc
assign arewebranching = zf & branch;

shiftleft #(32) shift(.a(imm), .out(imm_shifted));

assign pc_shifted_flow = current_pc + imm_shifted;
assign pc_add_four = current_pc + 32'd4;

mux2x1 #(32) pc_mux(.a(pc_add_four), .b(pc_shifted_flow), .sel(arewebranching), .out(next_pc));

/* Combinational => no need to define clock behavior */
// alu control unit selections
ALUControlUnit alu_control(
    .ALUOp(aluop),
	.Inst_14_12(instr[14:12]),
	.Inst_30(instr[30]),
	.ALU_Selection(alu_selected)
	);

prv32_ALU alu(
	.a(data1),
	.b(used),
	.shamt(), // TODO: connect shift amount if needed
	.r(alu_result),
	.cf(cf),
	.zf(zf),
	.vf(vf),
	.sf(sf),
	.alufn(alu_selected)	
);

// alu operations
mux2x1 #(32) data2_pick(.a(data2), .b(imm), .sel(alusrc), .out(used));

/* EX => Combinational => no need to define clock behavior */
ALU #(32) alu(
	.A(data1),
	.B(used),
	.sel(alu_selected),
	.result(alu_result),
	.zf(zf)
	);

// write back
mux2x1 #(32) select_wb (.a(alu_result), .b(mem_data), .sel(memtoreg), .out(wb_data));

endmodule
