`timescale 1ns / 1ps
`include "../defines.v"

module cpu(
    input clk, rst
);
    /* START: STAGE 1 - IF */
    /*	IF => reading is combinational no need to define clock behavior
        Mem => (in case of reading) => posedge clk */
    wire [31:0] current_pc;
    wire [31:0] next_pc;
    nbit_reg #(32) pc(.load(1'b1), .clk(clk), .rst(rst), .data(next_pc), .q(current_pc)); 
    
    // TODO: In order to combine the memories, according to VALUE of the clk, we will decide the source of the address to read from
    wire [31:0] instr;
    InstMem instruction_mem (.addr(current_pc[7:0]), .data_out(instr));
    /* END: STAGE 1 - IF */

    /* IF/ID Register */
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instr;
    nbit_reg #(64) if_id(
        .load(1'b1),
        .clk(clk),
        .rst(rst),
        .data({ current_pc, instr}),
        .q({    if_id_pc,   if_id_instr}));

    /* START: STAGE 2 - ID */
    /* Combinational => no need to define clock behavior */
    wire jalr, jump, branch, memread, memwrite, alusrc, regwrite;
    wire [1:0] aluop, PC_Sel, writeData_Sel;
    wire AUIPC_Sel, endProgram;
    ControlUnit control(
        .Opcode(if_id_instr[`IR_opcode]),
        .Funct3(if_id_instr[`IR_funct3]),
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
    wire [31:0] data1, data2;
    wire [31:0] wb_data;
    RegFile registers(
        .clk(clk),
        .rst(rst),
        .readReg1(if_id_instr[`IR_rs1]),
        .readReg2(if_id_instr[`IR_rs2]),
        .writeReg(if_id_instr[`IR_rd]),
        .writeData(wb_data),                // Belongs to the WB Stage
        .regWrite(mem_wb_wb_signals[1]),    // Belongs to the WB Stage
        .readData1(data1),
        .readData2(data2)
        );
    
    /* Combinational => no need to define clock behavior */
    wire [31:0] imm;
    rv32_ImmGen immediate(
        .IR(if_id_instr),
        .Imm(imm)
    );
    /* END: STAGE 2 - ID */

    /* ID/EX Register */
    wire [2:0] id_ex_wb_signals; //{regwrite, writeData_Sel}
    wire [6:0] id_ex_mem_signals; // {jump 1'b, jalr 1'b, PC_Sel 2'b, branch, memwrite, memread}
    wire [3:0] id_ex_exc_signals; //{AUIPC_Sel 1'b, alusrc 1'b, aluop 2'b}
    wire [4:0] id_ex_instr_shamt;
    wire [31:0] id_ex_d1, id_ex_d2, id_ex_pc, id_ex_imm; 
    wire id_ex_instr_30; //not the full instruction, just bit 30
    wire [2:0] id_ex_instr_funct3; //not the full instruction, just bits 14-12 (funct3)
    wire [4:0] id_ex_rd;
    nbit_reg #(156) id_ex(
        .load(1'b1),
        .clk(clk),
        .rst(rst),
        .data({ regwrite, writeData_Sel,     jump, jalr, PC_Sel, branch, memwrite, memread, AUIPC_Sel, alusrc, aluop,   if_id_instr[`IR_shamt],  data1,      data2,      if_id_pc,   imm,          if_id_instr[30],  if_id_instr[14:12],    if_id_instr[11:7]}),
        .q({    id_ex_wb_signals,            id_ex_mem_signals,                             id_ex_exc_signals,          id_ex_instr_shamt,       id_ex_d1,   id_ex_d2,   id_ex_pc,   id_ex_imm,    id_ex_instr_30,   id_ex_instr_funct3,     id_ex_rd})
        );

    /* START: STAGE 3 - EX */
    wire [31:0] pc_shifted_flow;
    assign pc_shifted_flow = id_ex_pc + id_ex_imm;
    
    /* EX => Combinational: no need to define clock behavior */
    wire [3:0] alu_function;
    ALUControlUnit alu_control(
        .ALUOp(id_ex_exc_signals[1:0]),
        .funct3(id_ex_instr_funct3),
        .Inst_30(id_ex_instr_30),
        .ALU_Selection(alu_function)
        );

    // alu operands
    wire [31:0] operand1; 
    wire [31:0] operand2;
    wire [31:0] alu_shamt;
    mux2x1 #(32) data1_pick(.a(id_ex_d1), .b(id_ex_pc), .sel(id_ex_exc_signals[3] /* AUIPC_Sel */), .out(operand1));
    mux2x1 #(32) data2_pick(.a(id_ex_d2), .b(id_ex_imm), .sel(id_ex_exc_signals[2] /* alusrc */), .out(operand2));
    mux2x1 #(32) shamt_pick(.a(id_ex_d2), .b(id_ex_instr_shamt), .sel(id_ex_exc_signals[2] /* alusrc */), .out(alu_shamt));
    
    wire cf, zf, vf, sf;
    wire [31:0] alu_result;
    prv32_ALU alu(
        .a(operand1),
        .b(operand2),
        .shamt(alu_shamt[4:0]),
        .r(alu_result),
        .cf(cf),
        .zf(zf),
        .vf(vf),
        .sf(sf),
        .alufn(alu_function)
    );
    /* END: STAGE 3 - EX */
    
    /* EX/MEM Register */
    wire [2:0] ex_mem_wb_signals; //{regwrite, writeData_Sel}
    wire [6:0] ex_mem_mem_signals; // {jump 1'b, jalr 1'b, PC_Sel 2'b, branch, memwrite, memread}
    wire [31:0] ex_mem_pc_shifted_flow, ex_mem_alu_result, ex_mem_d2, ex_mem_pc;
    wire [2:0] ex_mem_instr_funct3; //not the full instruction, just bits 14-12 (funct3)
    wire [3:0] ex_mem_alu_flags; // {cf, zf, vf, sf}
    wire [4:0] ex_mem_rd;
    nbit_reg #(150) ex_mem(
        .load(1'b1),
        .clk(clk),
        .rst(rst),
        .data({ id_ex_wb_signals,   id_ex_mem_signals,  pc_shifted_flow,        alu_result,         id_ex_d2,   cf, zf, vf, sf,     id_ex_rd,   id_ex_pc,   id_ex_instr_funct3}),
        .q({    ex_mem_wb_signals,  ex_mem_mem_signals, ex_mem_pc_shifted_flow, ex_mem_alu_result,  ex_mem_d2,  ex_mem_alu_flags,   ex_mem_rd,  ex_mem_pc,  ex_mem_instr_funct3})
        );

    /* START: STAGE 4 - MEM */
    // jump control unit -- decides if we should jump based on ALU flags
    wire shouldJump;
    JumpControl jumpcontrol(
        .jumpSignal(ex_mem_mem_signals[6] /* jump */ | ex_mem_mem_signals[5] /* jalr */),
        .branchSignal(ex_mem_mem_signals[2] /* branch */),
        .funct3(ex_mem_instr_funct3),
        .cf(ex_mem_alu_flags[3]),
        .zf(ex_mem_alu_flags[2]),
        .vf(ex_mem_alu_flags[1]),
        .sf(ex_mem_alu_flags[0]),
        .shouldJump(shouldJump)
    );

    wire [31:0] pc_add_four;
    assign pc_add_four = current_pc + 32'd4;
    wire [31:0] temppc;
    mux2x1 #(32) pcmux1(.a(pc_add_four), .b(pc_shifted_flow), .sel(shouldJump), .out(temppc));
    mux4x1 #(32) pcmux2(.a(temppc), .b(temppc), .c(ex_mem_alu_result), .d(current_pc), .sel(ex_mem_mem_signals[4:3] /* PC_Sel */), .out(next_pc));

    wire [31:0] mem_data;
    DataMem data_mem(
        .clk(clk),
        .MemRead(ex_mem_mem_signals[0]),
        .MemWrite(ex_mem_mem_signals[1]),
        .funct3(ex_mem_instr_funct3),
        .addr(ex_mem_alu_result[7:0]),
        .data_in(ex_mem_d2),
        .data_out(mem_data)
    );
    /* END: STAGE 4 - MEM */
    
    /* MEM/WB Register */
    wire [2:0] mem_wb_wb_signals; //{regwrite, writeData_Sel}
    wire [31:0] mem_wb_mem_data, mem_wb_alu_result, mem_wb_pc;
    wire [4:0] mem_wb_rd;
    nbit_reg #(71) mem_wb(
        .load(1'b1),
        .clk(clk),
        .rst(rst),
        .data({ ex_mem_wb_signals,  mem_data,           ex_mem_alu_result,  ex_mem_rd,  ex_mem_pc}),
        .q({    mem_wb_wb_signals,  mem_wb_mem_data,    mem_wb_alu_result,  mem_wb_rd,  mem_wb_pc})
        );

    /* START: STAGE 5 - WB */
    wire [31:0] wb_pc_add_four;
    // FIXME: (works for now) recall the jal/jalr instructions and where their values come from because this is not the correct stage to place that adder
    assign wb_pc_add_four = mem_wb_pc + 32'b4;

    mux4x1 #(32) select_wb (.a(mem_wb_alu_result), .b(mem_wb_mem_data), .c(wb_pc_add_four), .d(32'bx), .sel(mem_wb_wb_signals[1:0]), .out(wb_data));
    /* END: STAGE 5 - WB */
    
endmodule
