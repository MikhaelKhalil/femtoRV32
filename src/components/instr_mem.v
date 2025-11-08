`timescale 1ns / 1ps

module instr_mem(
    input [6:0] addr,  // Word address (PC[8:2])
    output [31:0] instruction
);

    reg [31:0] mem [0:127];  // 128 instructions (512 bytes)
    
    // Combinational read 
    assign instruction = mem[addr];
    
    // Initialize instruction memory with test programs
    initial begin
        // Initialize all to zero first
        integer i;
        for (i = 0; i < 128; i = i + 1) begin
            mem[i] = 32'b0;
        end
        
        // TODO: Add test programs her
        // mem[0] = 32'b000000000000_00000_010_00001_0000011; // lw x1, 0(x0)
        // mem[1] = 32'b000000000100_00000_010_00010_0000011; // lw x2, 4(x0)
    end
    
endmodule
