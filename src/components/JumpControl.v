`timescale 1ns / 1ps

module JumpControl(
    input jumpSignal,
    input branchSignal,
    input [`IR_funct3] funct3,
    input zf,
    input slt,
    output reg shouldJump
);

    always @(*) begin
        if (branchSignal) begin
            case (funct3)
                3'b000: shouldJump = zf == 1;   // BEQ
                3'b001: shouldJump = zf == 0;   // BNE
                3'b100: shouldJump = zf == 0 && slt == 1;  // BLT
                3'b101: shouldJump = zf == 0 && slt == 0;  // BGE
                3'b110: shouldJump = zf == 0 && slt == 1;  // BLTU 
                3'b111: shouldJump = zf == 0 && slt == 0;  // BGEU
            endcase
        end else if (jumpSignal) shouldJump = 1;
        else shouldJump = 0;
    end

endmodule
