`timescale 1ns / 1ps

module Mem(
    input clk,
    input MemRead,
    input MemWrite,
    input [`IR_funct3] funct3,
    input [7:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out
);
    reg [7:0] mem [0:255];  // 256 bytes

    // Load
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b010: data_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};  // LW
                3'b001: data_out = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};      // LH
                3'b000: data_out = {{24{mem[addr][7]}}, mem[addr]};                     // LB
                3'b100: data_out = {24'b0, mem[addr]};                                  // LBU
                3'b101: data_out = {16'b0, mem[addr+1], mem[addr]};                     // LHU
                default: data_out = 32'b0;
            endcase
        end else data_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};         // Reading an instruction
    end

    // Store
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b010: begin                       // SW
                    mem[addr] <= data_in[7:0];
                    mem[addr+1] <= data_in[15:8];
                    mem[addr+2] <= data_in[23:16];
                    mem[addr+3] <= data_in[31:24];
                end
                3'b001: begin                       // SH
                    mem[addr] <= data_in[7:0];
                    mem[addr+1] <= data_in[15:8];
                end
                3'b000: begin                       // SB
                    mem[addr] <= data_in[7:0];
                end
            endcase
        end
    end
    
    // Program Provided in the Report (Lab 8) with some adjustments in offsets
    initial begin
        /* Let the IMEM start from address 0 */
        /* Test Program from Lab 08 */
        /*
        {mem[3], mem[2], mem[1], mem[0]}        = 32'b0000000_00000_00000_000_00000_0110011;    // add x0, x0, x0    # [NOP]
        //added to be skipped since PC starts with 4 after reset
        {mem[7], mem[6], mem[5], mem[4]}        = 32'b00000100000000000010000010000011;         // lw x1, 64(x0)     # 17
        {mem[11], mem[10], mem[9], mem[8]}      = 32'b00000100010000000010000100000011;         // lw x2, 68(x0)     # 9 
        {mem[15], mem[14], mem[13], mem[12]}    = 32'b00000100100000000010000110000011;         // lw x3, 72(x0)     # 25
        {mem[19], mem[18], mem[17], mem[16]}    = 32'b0000000_00010_00001_110_00100_0110011;    // or x4, x1, x2     # 25
        {mem[23], mem[22], mem[21], mem[20]}    = 32'b00000000001100100000010001100011;         // beq x4, x3, 8     # pc+8
        {mem[27], mem[26], mem[25], mem[24]}    = 32'b0000000_00010_00001_000_00011_0110011;    // add x3, x1, x2    # should be skipped
        {mem[31], mem[30], mem[29], mem[28]}    = 32'b0000000_00010_00011_000_00101_0110011;    // add x5, x3, x2    # 34
        {mem[35], mem[34], mem[33], mem[32]}    = 32'b00000100010100000010011000100011;         // sw x5, 76(x0)     # 
        {mem[39], mem[38], mem[37], mem[36]}    = 32'b00000100110000000010001100000011;         // lw x6, 76(x0)     # 34    // Load-Use Hazard => will stall automatically using the Hazard Detection Unit
        {mem[43], mem[42], mem[41], mem[40]}    = 32'b0000000_00001_00110_111_00111_0110011;    // and x7, x6, x1    # 0
        {mem[47], mem[46], mem[45], mem[44]}    = 32'b0100000_00010_00001_000_01000_0110011;    // sub x8, x1, x2    # 8
        {mem[51], mem[50], mem[49], mem[48]}    = 32'b0000000_00010_00001_000_00000_0110011;    // add x0, x1, x2    # 26, write to reg x0 -> 0
        {mem[55], mem[54], mem[53], mem[52]}    = 32'b0000000_00001_00000_000_01001_0110011;    // add x9, x0, x1    # 17
        // Data
        {mem[67], mem[66], mem[65], mem[64]}=32'd17;
        {mem[71], mem[70], mem[69], mem[68]}=32'd9;
        {mem[75], mem[74], mem[73], mem[72]}=32'd25;
        */

        /* Comprehensive Test Program */
        {mem[3], mem[2], mem[1], mem[0]} = 32'b00010010001101000101000010110111;      // LUI   x1, 0x12345    # 0x12345000
        {mem[7], mem[6], mem[5], mem[4]} = 32'b00000000000000010000000100010111;      // AUIPC x2, 0x10       # 0x10004
        {mem[11], mem[10], mem[9], mem[8]} = 32'b00000000010100001000000110010011;      // ADDI  x3, x1, 5      # 305418245
        {mem[15], mem[14], mem[13], mem[12]} = 32'b00000000101000011010001000010011;      // SLTI  x4, x3, 10    # 0
        {mem[19], mem[18], mem[17], mem[16]} = 32'b00000000100100011011001010010011;      // SLTIU x5, x3, 9     # 0
        {mem[23], mem[22], mem[21], mem[20]} = 32'b00000000100000011100001100010011;      // XORI  x6, x3, 8     # 305418253
        {mem[27], mem[26], mem[25], mem[24]} = 32'b00000000011100011110001110010011;      // ORI   x7, x3, 7     # 305418247
        {mem[31], mem[30], mem[29], mem[28]} = 32'b00000000001100011111010000010011;      // ANDI  x8, x3, 3     # 1
        {mem[35], mem[34], mem[33], mem[32]} = 32'b00000000001000011001010010010011;      // SLLI  x9, x3, 2     # 1221672980
        {mem[39], mem[38], mem[37], mem[36]} = 32'b00000000000100011101010100010011;      // SRLI  x10, x3, 1    # 152709122
        {mem[43], mem[42], mem[41], mem[40]} = 32'b01000000000100011101010110010011;     // SRAI  x11, x3, 1     # 152709122
        {mem[47], mem[46], mem[45], mem[44]} = 32'b00000000000100011000011000110011;     // ADD   x12, x3, x1    # 610836485
        {mem[51], mem[50], mem[49], mem[48]} = 32'b01000000000100011000011010110011;     // SUB   x13, x3, x1    # 5
        {mem[55], mem[54], mem[53], mem[52]} = 32'b00000000110100011001011100110011;     // SLL   x14, x3, x13   # 9773383840 => clipped into => 1183449248
        {mem[59], mem[58], mem[57], mem[56]} = 32'b00000000001100001010011110110011;     // SLT   x15, x1, x3    # 1
        {mem[63], mem[62], mem[61], mem[60]} = 32'b00000000000100011011100000110011;     // SLTU  x16, x3, x1    # 0
        {mem[67], mem[66], mem[65], mem[64]} = 32'b00000000000100011100100010110011;     // XOR   x17, x3, x1    # 5
        {mem[71], mem[70], mem[69], mem[68]} = 32'b00000000110100011101100100110011;     // SRL   x18, x3, x13   # 9544320
        {mem[75], mem[74], mem[73], mem[72]} = 32'b01000000110100011101100110110011;     // SRA   x19, x3, x13   # 9544320
        {mem[79], mem[78], mem[77], mem[76]} = 32'b00000000000100011110101000110011;     // OR    x20, x3, x1    # 305418245
        {mem[83], mem[82], mem[81], mem[80]} = 32'b00000000000100011111101010110011;     // AND   x21, x3, x1    # 305418240
        {mem[87], mem[86], mem[85], mem[84]} = 32'b00000000001100000010000000100011;     // SW    x3, 0(x0)      # mem[3:0] changed
        {mem[91], mem[90], mem[89], mem[88]} = 32'b00000000001100000001001000100011;     // SH    x3, 4(x0)      # mem[5:4] changed 
        {mem[95], mem[94], mem[93], mem[92]} = 32'b00000000001100000000001100100011;     // SB    x3, 6(x0)      # mem[6] changed
        {mem[99], mem[98], mem[97], mem[96]} = 32'b00000000000000000010101100000011;     // LW    x22, 0(x0)     # 305418245
        {mem[103], mem[102], mem[101], mem[100]} = 32'b00000000010000000001101110000011;     // LH    x23, 4(x0)    # 
        {mem[107], mem[106], mem[105], mem[104]} = 32'b00000000011000000000110000000011;     // LB    x24, 6(x0)    # 5
        {mem[111], mem[110], mem[109], mem[108]} = 32'b00000000010000000101110010000011;     // LHU   x25, 4(x0)    # 
        {mem[115], mem[114], mem[113], mem[112]} = 32'b00000000011000000100110100000011;     // LBU   x26, 6(x0)    # 5
        {mem[119], mem[118], mem[117], mem[116]} = 32'b00000000010100000000110110010011;     // ADDI  x27, x0, 5    # 5
        {mem[123], mem[122], mem[121], mem[120]} = 32'b00000000101000000000111000010011;     // ADDI  x28, x0, 10   # 10
        {mem[127], mem[126], mem[125], mem[124]} = 32'b00000001110011011000010001100011;     // BEQ   x27, x28, skip_beq                # not taken
        {mem[131], mem[130], mem[129], mem[128]} = 32'b00000000000100000000111010010011;     // ADDI  x29, x0, 1                        # 1
        {mem[135], mem[134], mem[133], mem[132]} = 32'b00000001110011011001010001100011;     // skip_beq: BNE   x27, x28, after_bne     # taken => 140
        {mem[139], mem[138], mem[137], mem[136]} = 32'b00000000001000000000111010010011;     // ADDI  x29, x0, 2
        {mem[143], mem[142], mem[141], mem[140]} = 32'b00000001110011011100010001100011;     // after_bne: BLT   x27, x28, after_blt    # 5 < 10 => taken => 148
        {mem[147], mem[146], mem[145], mem[144]} = 32'b00000000001100000000111100010011;     // ADDI  x30, x0, 3
        {mem[151], mem[150], mem[149], mem[148]} = 32'b00000001101111100101010001100011;     // after_blt: BGE   x28, x27, after_bge    # 10 > 5 => taken => 156
        {mem[155], mem[154], mem[153], mem[152]} = 32'b00000000010000000000111100010011;     // ADDI  x30, x0, 4
        {mem[159], mem[158], mem[157], mem[156]} = 32'b00000001101111100110010001100011;     // after_bge: BLTU  x28, x27, after_bltu   # 10 !< 5 => not taken
        {mem[163], mem[162], mem[161], mem[160]} = 32'b00000000010100000000111100010011;     // ADDI  x30, x0, 5                        # 5
        {mem[167], mem[166], mem[165], mem[164]} = 32'b00000001110011011111010001100011;     // after_bltu: BGEU  x27, x28, after_bgeu  # 5 !> 10 => not taken
        {mem[171], mem[170], mem[169], mem[168]} = 32'b00000000011000000000111100010011;     // ADDI  x30, x0, 6                        # 6
        {mem[175], mem[174], mem[173], mem[172]} = 32'b00000000100000000000111111101111;     // after_bgeu: JAL   x31, jal_target       # PC => 180, x31 => 176
        {mem[179], mem[178], mem[177], mem[176]} = 32'b00000110001100000000001010010011;     // ADDI  x5, x0, 99
        {mem[183], mem[182], mem[181], mem[180]} = 32'b00000010101000000000001100010011;     // jal_target: ADDI  x6, x0, 42            # 42
        // {mem[187], mem[186], mem[185], mem[184]} = 32'b00000000000011111000010101100111;     // JALR  x10, x31, 0                       # PC => 176, x10 => 188
        // {mem[187], mem[186], mem[185], mem[184]} = 32'b00000000000000000001000000001111;     // FENCE.I
        {mem[187], mem[186], mem[185], mem[184]} = 32'b00000000000000000000000001110011;     // ECALL => should halt - PC = PC (184 or 188)
        // {mem[187], mem[186], mem[185], mem[184]} = 32'b00000000000100000000000001110011;     // EBREAK
        {mem[191], mem[190], mem[189], mem[188]} = 32'b00000000000011111000010101100111;        // JALR  x10, x31, 0                       # PC => 176, x10 => 188
        // Data
        {mem[203], mem[202], mem[201], mem[200]} = 32'd12;
        {mem[207], mem[206], mem[205], mem[204]} = 32'd34;
        {mem[211], mem[210], mem[209], mem[208]} = 32'd56;
        {mem[215], mem[214], mem[213], mem[212]} = 32'd67;
        {mem[219], mem[218], mem[217], mem[216]} = 32'd78;

        /* Simple Loop Test Program */
        /*
        {mem[3], mem[2], mem[1], mem[0]}        = 32'b0000000_00000_00000_000_00000_0110011;    // add x0, x0, x0    # [NOP]
        {mem[7], mem[6], mem[5], mem[4]}        = 32'b00000000000000000010000010000011;         // lw x1, 0(x0)
        {mem[11], mem[10], mem[9], mem[8]}      = 32'b00000000010000000010000100000011;         // lw x2, 4(x0)
        {mem[15], mem[14], mem[13], mem[12]}    = 32'b00000000000000000000000110110011;         // add x3, x0, x0
        {mem[19], mem[18], mem[17], mem[16]}    = 32'b00000000000100011000011001100011;         // Condition: beq x3, x1, Exit
        {mem[23], mem[22], mem[21], mem[20]}    = 32'b00000000001000011000000110110011;         // add x3, x3, x2
        {mem[27], mem[26], mem[25], mem[24]}    = 32'b11111110000000000000110011100011;         // beq x0, x0, Condition
                                                                                                // Exit: 
        // Data
        {mem[203], mem[202], mem[201], mem[200]} = 32'd4;
        {mem[207], mem[206], mem[205], mem[204]} = 32'd1;
        */
    end
    
endmodule
