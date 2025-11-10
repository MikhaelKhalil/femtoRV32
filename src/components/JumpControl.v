`timescale 1ns / 1ps

module JumpControl(
    input jumpSignal,
    input branchSignal,
    input [`IR_funct3] funct3,
    input zf,  // Zero flag (from SUB: rs1 - rs2 == 0)
    input slt,
    output reg shouldJump
);

    always @(*) begin
        if (branchSignal) begin
            case (funct3)
                3'b000: shouldJump = (zf == 1);              // BEQ: rs1 == rs2 (zero flag set)
                3'b001: shouldJump = (zf == 0);             // BNE: rs1 != rs2 (zero flag clear)
                3'b100: shouldJump = (slt == 1);            // BLT: rs1 < rs2 (signed) - sign != overflow
                3'b101: shouldJump = (slt == 0);            // BGE: rs1 >= rs2 (signed) - sign == overflow
                3'b110: shouldJump = (slt == 1);             // BLTU: rs1 < rs2 (unsigned) - no borrow
                3'b111: shouldJump = (slt == 0);             // BGEU: rs1 >= rs2 (unsigned) - borrow occurred
            endcase
        end else if (jumpSignal) shouldJump = 1;
        else shouldJump = 0;
    end

endmodule
