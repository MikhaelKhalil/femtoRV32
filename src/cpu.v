`timescale 1ns / 1ps
`include "../defines.v"

module cpu(
    input clk, rst,
    // FPGA input ports
    input [1:0] ledSel, // LED selection (2 switches)
    input [3:0] ssdSel, // SSD selection (4 switches)
    // FPGA output ports
    output [15:0] leds, // 16 LEDs output
    output [12:0] ssd // 13-bit SSD output
);
    /* Brnach Predictor */
    wire bp_prediction;
    wire bp_update_en;
    wire bp_actual_taken;
    wire [31:0] bp_update_pc;

    BranchPredictor predictor (
        .clk(clk),
        .rst(rst),
        .pc(current_pc),
        .update_pc(bp_update_pc),
        .actual_taken(bp_actual_taken),
        .update_enable(bp_update_en),
        .prediction(bp_prediction)
    );

    /* Hazard Detection Unit */
    // Stalling for one cycle in case of encountring a Load-Use Hazard
    // In case of stalling: 1) Write Disable PC register 2) Write Disable IF/ID register 3) Replace Control Signals in the ID stage with zeros
    wire stall;
    HazardDetectionUnit hazard_detection(
        .if_id_rs1(if_id_instr[`IR_rs1]), .if_id_rs2(if_id_instr[`IR_rs2]), .id_ex_rd(id_ex_rd),
        .id_ex_memread(id_ex_mem_signals[0]),
        .stall(stall)
    );

    /* Misprediction Detection*/
    // Branch resolved in MEM stage
    wire is_resolved_branch = ex_mem_mem_signals[2]; // branch signal
    assign bp_update_en     = is_resolved_branch;
    assign bp_actual_taken  = shouldJump;
    assign bp_update_pc     = ex_mem_pc;

    wire mispredict = is_resolved_branch && (bp_actual_taken != ex_mem_predicted_taken);


    /* Instruction Flushing */
    // Flushing instructions in case of a wrong branch. i.e., according to the (shouldJump) signal, shouldJump is the actual result, we will use mispredict now
    // In case of the need to flush:
    // 1) Provide a NOP instruction to the IF/ID register instead of the upcoming instruction
    // 2) Replace Control Signals in the ID stage with zeros
    // 3) Replace the MEM & WB Signals going to the EX/MEM register with zeros
    wire [31:0] instr_to_use;
    assign instr_to_use = mispredict ? 32'b0000000_00000_00000_000_00000_0110011 : instr;       // add x0, x0, x0   # [NOP]
    
    /* Stalling in case of a Structural Hazard */
    // If EX/MEM.MemRead == 1 or EX/MEM.MemWrite == 1,
    // 1) Keep the PC unchanged for the next cycle
    // 2) Provide a NOP instruction to the IF/ID register instead of the instruction to be stalled
    // NOTE: This type of stalling is different from that issued by the Hazard Detection Unit, because in this type we let the rest of the pipeline to work freely except for the new instruction being fetched.
    wire structural_hazard_stall;
    assign structural_hazard_stall = ex_mem_mem_signals[0] /* EX/MEM.MemRead */ | ex_mem_mem_signals[1] /* EX/MEM.MemWrite */;
    
    /* START: STAGE 1 - IF */
    wire [31:0] current_pc, next_pc;
    nbit_reg #(32) pc(
        .load(!stall && !structural_hazard_stall),
        .clk(clk),
        .rst(rst),
        .data(next_pc),
        .q(current_pc)
    );
    
    // Mem module instantiated below with the MEM stage below
    wire [31:0] instr;
    /* END: STAGE 1 - IF */

    /* IF/ID Register */
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instr;
    nbit_reg #(64) if_id(
        .load(!stall),
        .clk(clk),
        .rst(rst),
        .data({ current_pc, instr_to_use}), // instr_to_use instead of instr for instruction flushing and structural hazard handling
        .q({    if_id_pc,   if_id_instr}));

    /* START: STAGE 2 - ID */
    wire jalr, jump, branch, memread, memwrite, alusrc, regwrite;
    wire [1:0] aluop, PC_Sel, writeData_Sel;
    wire AUIPC_Sel, endProgram;

    wire [14:0] control_unit_outputs;    // {jalr, jump, branch, memread, aluop [1:0], memwrite, alusrc, regwrite, PC_Sel [1:0], writeData_Sel [1:0], AUIPC_Sel, endProgram}
    ControlUnit control(
        .Opcode(if_id_instr[`IR_opcode]),
        .Funct3(if_id_instr[`IR_funct3]),
        .Jalr(control_unit_outputs[14]),
        .Jump(control_unit_outputs[13]),
        .Branch(control_unit_outputs[12]),
        .MemRead(control_unit_outputs[11]),
        .ALUOp(control_unit_outputs[10:9]),
        .MemWrite(control_unit_outputs[8]),
        .ALUSrc(control_unit_outputs[7]),
        .RegWrite(control_unit_outputs[6]),
        .PC_Sel(control_unit_outputs[5:4]),
        .writeData_Sel(control_unit_outputs[3:2]),
        .AUIPC_Sel(control_unit_outputs[1]),
        .endProgram(control_unit_outputs[0])
    );

    // added mispredict
    // For Stalling (from the Hazard Detection Unit)    => stall signal
    // and Instruction Flushing                         => shouldJump signal (because the currently used branch predictor is an implicit always-not-taken predictor)
    assign {jalr, jump, branch, memread, aluop [1:0], memwrite, alusrc, regwrite, PC_Sel [1:0], writeData_Sel [1:0], AUIPC_Sel, endProgram} = (stall | mispredict) ? 8'b0 : control_unit_outputs;
    
    /* WB => negedge clk */
    wire [31:0] data1, data2;
    wire [31:0] wb_data;
    RegFile registers(
        .clk(clk),
        .rst(rst),
        .readReg1(if_id_instr[`IR_rs1]),
        .readReg2(if_id_instr[`IR_rs2]),
        .writeReg(mem_wb_rd),
        .writeData(wb_data),                // Belongs to the WB Stage
        .regWrite(mem_wb_wb_signals[2]),    // Belongs to the WB Stage
        .readData1(data1),
        .readData2(data2)
    );
    
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
    wire [4:0] id_ex_rd, id_ex_rs1, id_ex_rs2;
    nbit_reg #(166) id_ex(
        .load(1'b1),
        .clk(clk),
        .rst(rst),
        .data({ regwrite, writeData_Sel,     jump, jalr, PC_Sel, branch, memwrite, memread, AUIPC_Sel, alusrc, aluop,   if_id_instr[`IR_shamt],  data1,      data2,      if_id_pc,   imm,          if_id_instr[30],  if_id_instr[14:12],    if_id_instr[`IR_rd],  if_id_instr[`IR_rs1], if_id_instr[`IR_rs2]}),
        .q({    id_ex_wb_signals,            id_ex_mem_signals,                             id_ex_exc_signals,          id_ex_instr_shamt,       id_ex_d1,   id_ex_d2,   id_ex_pc,   id_ex_imm,    id_ex_instr_30,   id_ex_instr_funct3,     id_ex_rd,            id_ex_rs1,          id_ex_rs2})
    );
    
    /* Forwarding Unit */
    // Forwarding values from the last EX or the second-to-last MEM stages to the upcoming EX stage
    // Plus, choosing ALU Operands for the upcoming EX stage
    wire [1:0] forwardA, forwardB;
    ForwardingUnit forwarding(
        .ex_mem_regwrite(ex_mem_wb_signals[2]),
        .ex_mem_rd(ex_mem_rd),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),  
        .mem_wb_regwrite(mem_wb_wb_signals[2]),
        .mem_wb_rd(mem_wb_rd),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    reg [31:0] operand1_layer1, operand2_layer1;
    wire [31:0] operand1, operand2;
    wire [31:0] alu_shamt;
    // First layer of Muxes (Big Muxes)
    always @(*) begin
        case (forwardA)
            2'b10: operand1_layer1 = ex_mem_alu_result;    // Forward from last EX
            2'b01: operand1_layer1 = wb_data;              // Forward from second-to-last MEM
            default: operand1_layer1 = id_ex_d1;           // Take the read value from the RegFile
        endcase
        
        case (forwardB)
            2'b10: operand2_layer1 = ex_mem_alu_result;    // Forward from last EX
            2'b01: operand2_layer1 = wb_data;              // Forward from second-to-last MEM
            default: operand2_layer1 = id_ex_d2;           // Take the read value from the RegFile
        endcase
    end

    // Second layer of Muxes (Small Muxes)
    mux2x1 #(32) data1_pick(.a(operand1_layer1), .b(id_ex_pc), .sel(id_ex_exc_signals[3] /* AUIPC_Sel */), .out(operand1));
    mux2x1 #(32) data2_pick(.a(operand2_layer1), .b(id_ex_imm), .sel(id_ex_exc_signals[2] /* alusrc */), .out(operand2));
    mux2x1 #(32) shamt_pick(.a(operand2_layer1), .b({27'b0, id_ex_instr_shamt}), .sel(id_ex_exc_signals[2] /* alusrc */), .out(alu_shamt));
        
    /* START: STAGE 3 - EX */
    wire [31:0] pc_shifted_flow;
    assign pc_shifted_flow = id_ex_pc + id_ex_imm;
    
    wire [3:0] alu_function;
    ALUControlUnit alu_control(
        .ALUOp(id_ex_exc_signals[1:0]),
        .funct3(id_ex_instr_funct3),
        .Inst_30(id_ex_instr_30),
        .ALU_Selection(alu_function)
    );

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
    
    // For Instruction Flushing
    wire [2:0] id_ex_wb_signals_to_use;
    wire [6:0] id_ex_mem_signals_to_use;
    assign id_ex_wb_signals_to_use = shouldJump ? 3'b0 : id_ex_wb_signals;
    assign id_ex_mem_signals_to_use = shouldJump ? 7'b0 : id_ex_mem_signals;

    /* EX/MEM Register */
    wire [2:0] ex_mem_wb_signals; //{regwrite, writeData_Sel}
    wire [6:0] ex_mem_mem_signals; // {jump 1'b, jalr 1'b, PC_Sel 2'b, branch, memwrite, memread}
    wire [31:0] ex_mem_pc_shifted_flow, ex_mem_alu_result, ex_mem_d2, ex_mem_pc;
    wire [2:0] ex_mem_instr_funct3; //not the full instruction, just bits 14-12 (funct3)
    wire [3:0] ex_mem_alu_flags; // {cf, zf, vf, sf}
    wire [4:0] ex_mem_rd;
    wire ex_mem_predicted_taken;
    nbit_reg #(150) ex_mem(
        .load(1'b1),
        .clk(clk),
        .rst(rst),
        .data({ id_ex_wb_signals_to_use,    id_ex_mem_signals_to_use,   pc_shifted_flow,        alu_result,         id_ex_d2,   cf, zf, vf, sf,     id_ex_rd,   id_ex_pc,   id_ex_instr_funct3, bp_prediction}),
        .q({    ex_mem_wb_signals,          ex_mem_mem_signals,         ex_mem_pc_shifted_flow, ex_mem_alu_result,  ex_mem_d2,  ex_mem_alu_flags,   ex_mem_rd,  ex_mem_pc,  ex_mem_instr_funct3, ex_mem_predicted_taken})
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
    mux2x1 #(32) pcmux1(.a(pc_add_four), .b(ex_mem_pc_shifted_flow), .sel(shouldJump), .out(temppc));
    mux4x1 #(32) pcmux2(.a(temppc), .b(temppc), .c(ex_mem_alu_result), .d(current_pc), .sel(ex_mem_mem_signals[4:3] /* PC_Sel */), .out(next_pc));

    wire [31:0] mem_data;

    wire [31:0] addr_to_use;
    assign addr_to_use = structural_hazard_stall /* i.e., reading/writing to data memory */ ? ex_mem_alu_result[7:0] : current_pc[7:0];
    wire [31:0] mem_output;
    Mem memory(
        .clk(clk),
        .MemRead(ex_mem_mem_signals[0]),
        .MemWrite(ex_mem_mem_signals[1]),
        .funct3(ex_mem_instr_funct3),       // TODO: check if this is the correct method to differentiate between LW, LH, LB
        .addr(addr_to_use),
        .data_in(ex_mem_d2),
        .data_out(mem_output)
    );
    assign mem_data = structural_hazard_stall ? mem_output : 32'b0;
    assign instr = structural_hazard_stall ? 32'b0000000_00000_00000_000_00000_0110011 : mem_output;    // add x0, x0, x0   # [NOP]
    /* END: STAGE 4 - MEM */
    
    /* MEM/WB Register */
    wire [2:0] mem_wb_wb_signals; //{regwrite, writeData_Sel}
    wire [31:0] mem_wb_mem_data, mem_wb_alu_result, mem_wb_pc;
    wire [4:0] mem_wb_rd;
    nbit_reg #(104) mem_wb(
        .load(1'b1),
        .clk(clk),
        .rst(rst),
        .data({ ex_mem_wb_signals,  mem_data,           ex_mem_alu_result,  ex_mem_rd,  ex_mem_pc}),
        .q({    mem_wb_wb_signals,  mem_wb_mem_data,    mem_wb_alu_result,  mem_wb_rd,  mem_wb_pc})
    );

    /* START: STAGE 5 - WB */
    wire [31:0] wb_pc_add_four;
    // FIXME: (works for now) recall the jal/jalr instructions and where their values come from because this is not the correct stage to place that adder
    assign wb_pc_add_four = mem_wb_pc + 32'd4;

    mux4x1 #(32) select_wb (.a(mem_wb_alu_result), .b(mem_wb_mem_data), .c(wb_pc_add_four), .d(32'bx), .sel(mem_wb_wb_signals[1:0]), .out(wb_data));
    /* END: STAGE 5 - WB */
    
    
    
//    /* FOR FPGA IMPLEMENTATION */
//    wire [13:0] control_signals;
//    assign control_signals = {2'b00, aluop, alu_function, zf, pcsrc, branch, memread, memtoreg, memwrite, alusrc, regwrite};


    // LED output multiplexing
    reg [15:0] led_output;
    always @(*) begin
//        case(ledSel)
//            2'b00: led_output = instr[15:0]; // Instruction[15:0]
//            2'b01: led_output = instr[31:16]; // Instruction[31:16]
//            2'b10: led_output = {2'b00, control_signals}; // Control signals (14 bits)
//            default: led_output = 16'b0;
//        endcase
        case(ledSel)
            2'b00: led_output = if_id_instr[15:0];
            2'b01: led_output = id_ex_pc[15:0];
            2'b10: led_output = ex_mem_mem_signals;
            2'b11: led_output = mem_wb_wb_signals;
            default: led_output = 16'b0;
        endcase
    end
    assign leds = led_output;
    
    // SSD output multiplexing
    reg [12:0] ssd_output;
    always @(*) begin
//        case(ssdSel)
//            4'b0000: ssd_output = current_pc[12:0]; // PC output
//            4'b0001: ssd_output = pc_add_four[12:0]; // PC+4 adder output
//            4'b0010: ssd_output = pc_shifted_flow[12:0]; // Branch target adder output
//            4'b0011: ssd_output = next_pc[12:0]; // PC input
//            4'b0100: ssd_output = data1[12:0]; // RS1 data
//            4'b0101: ssd_output = data2[12:0]; // RS2 data
//            4'b0110: ssd_output = wb_data[12:0]; // Register file input data
//            4'b0111: ssd_output = imm[12:0]; // Immediate generator output
//            4'b1000: ssd_output = imm_shifted[12:0]; // Shift left 1 output
//            4'b1001: ssd_output = operand2[12:0]; // ALU 2nd source mux output
//            4'b1010: ssd_output = alu_result[12:0]; // ALU output
//            4'b1011: ssd_output = mem_data[12:0]; // Memory output
//            default: ssd_output = 13'b0;
//        endcase
        case(ssdSel)
            4'b0000: ssd_output = current_pc[12:0];
            4'b0001: ssd_output = next_pc[12:0];
            4'b0010: ssd_output = pc_shifted_flow[12:0];
            4'b0011: ssd_output = id_ex_pc[12:0];
            4'b0100: ssd_output = data1[12:0];
            4'b0101: ssd_output = data2[12:0];
            4'b0110: ssd_output = wb_data[12:0];
            4'b0111: ssd_output = imm[12:0];
            4'b1000: ssd_output = operand2[12:0];
            4'b1001: ssd_output = alu_result[12:0];
            4'b1010: ssd_output = mem_output[12:0];
            default: ssd_output = 13'b0;
        endcase
    end
    assign ssd = ssd_output;
endmodule
