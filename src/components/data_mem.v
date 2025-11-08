`timescale 1ns / 1ps

module data_mem(
    input clk,
    input MemRead,
    input MemWrite,
    input [2:0] funct3,  // Load/store size: 000=LB, 001=LH, 010=LW, 100=LBU, 101=LHU
    input [8:0] byte_addr,  // Byte address (9 bits: 8:2 for word, 1:0 for byte offset)
    input [31:0] data_in,
    output reg [31:0] data_out
);

    reg [31:0] mem [0:127];  // 128 words (512 bytes)
    wire [6:0] word_addr;
    wire [1:0] byte_offset;
    
    assign word_addr = byte_addr[8:2];  // Word address
    assign byte_offset = byte_addr[1:0];  // Byte offset within word
    
    // Combinational read (for single-cycle CPU)
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: begin // LB - Load byte (signed)
                    case (byte_offset)
                        2'b00: data_out = {{24{mem[word_addr][7]}}, mem[word_addr][7:0]};
                        2'b01: data_out = {{24{mem[word_addr][15]}}, mem[word_addr][15:8]};
                        2'b10: data_out = {{24{mem[word_addr][23]}}, mem[word_addr][23:16]};
                        2'b11: data_out = {{24{mem[word_addr][31]}}, mem[word_addr][31:24]};
                    endcase
                end
                3'b001: begin // LH - Load halfword (signed)
                    case (byte_offset[1])
                        1'b0: data_out = {{16{mem[word_addr][15]}}, mem[word_addr][15:0]};
                        1'b1: data_out = {{16{mem[word_addr][31]}}, mem[word_addr][31:16]};
                    endcase
                end
                3'b010: begin // LW - Load word
                    data_out = mem[word_addr];
                end
                3'b100: begin // LBU - Load byte unsigned
                    case (byte_offset)
                        2'b00: data_out = {24'b0, mem[word_addr][7:0]};
                        2'b01: data_out = {24'b0, mem[word_addr][15:8]};
                        2'b10: data_out = {24'b0, mem[word_addr][23:16]};
                        2'b11: data_out = {24'b0, mem[word_addr][31:24]};
                    endcase
                end
                3'b101: begin // LHU - Load halfword unsigned
                    case (byte_offset[1])
                        1'b0: data_out = {16'b0, mem[word_addr][15:0]};
                        1'b1: data_out = {16'b0, mem[word_addr][31:16]};
                    endcase
                end
                default: data_out = mem[word_addr];  // Default to word
            endcase
        end else begin
            data_out = 32'b0;
        end
    end
    
    // Clocked write
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: begin // SB - Store byte
                    case (byte_offset)
                        2'b00: mem[word_addr][7:0] <= data_in[7:0];
                        2'b01: mem[word_addr][15:8] <= data_in[7:0];
                        2'b10: mem[word_addr][23:16] <= data_in[7:0];
                        2'b11: mem[word_addr][31:24] <= data_in[7:0];
                    endcase
                end
                3'b001: begin // SH - Store halfword
                    case (byte_offset[1])
                        1'b0: mem[word_addr][15:0] <= data_in[15:0];
                        1'b1: mem[word_addr][31:16] <= data_in[15:0];
                    endcase
                end
                3'b010: begin // SW - Store word
                    mem[word_addr] <= data_in;
                end
                default: mem[word_addr] <= data_in;  // Default to word
            endcase
        end
    end
    
    // Initialize data memory
    initial begin
        integer i;
        for (i = 0; i < 128; i = i + 1) begin
            mem[i] = 32'b0;
        end
        
        // Byte address 256 = word address 64
        mem[64] = 32'd17;
        mem[65] = 32'd9;
        mem[66] = 32'd25; 
    end
    
endmodule
