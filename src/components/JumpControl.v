`timescale 1ns / 1ps

module JumpControl(
    input jumpSignal,
    input branchSignal,
    input [`IR_funct3] funct3,
    input zf,  // Zero flag (from SUB: rs1 - rs2 == 0)
    input sf,  // Sign flag (from SUB: result[31])
    input vf,  // Overflow flag (from SUB: signed overflow)
    input cf,  // Carry flag (from SUB: unsigned borrow)
    output reg shouldJump
);

    always @(*) begin
        if (branchSignal) begin
            case (funct3)
                3'b000: shouldJump = (zf == 1);              // BEQ: rs1 == rs2 (zero flag set)
                3'b001: shouldJump = (zf == 0);             // BNE: rs1 != rs2 (zero flag clear)
                3'b100: shouldJump = (sf != vf);            // BLT: rs1 < rs2 (signed) - sign != overflow
                3'b101: shouldJump = (sf == vf);            // BGE: rs1 >= rs2 (signed) - sign == overflow
                3'b110: shouldJump = (cf == 0);             // BLTU: rs1 < rs2 (unsigned) - no borrow
                3'b111: shouldJump = (cf == 1);             // BGEU: rs1 >= rs2 (unsigned) - borrow occurred
            endcase
        end else if (jumpSignal) shouldJump = 1;
        else shouldJump = 0;
    end

endmodule
