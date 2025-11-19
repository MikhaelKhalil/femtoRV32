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
    reg [7:0] mem [0:255];

    // Load
    assign data_out = mem[addr];
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
        {mem[56], mem[54], mem[53], mem[52]}    = 32'b0000000_00001_00000_000_01001_0110011;    // add x9, x0, x1    # 17

        /* Let DateMem start from address 64 */
        mem[64]=32'd17;
        mem[65]=32'd9;
        mem[65]=32'd25;
    end
    
endmodule
