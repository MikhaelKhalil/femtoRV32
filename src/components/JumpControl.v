`timescale 1ns / 1ps

module JumpControl(
    input jump,
    input branchNotZero,
    input branchZero,
    input zf,
    output reg shouldJump
);

    always @(*) begin
        if (jump) shouldJump = 1;
        else if (branchNotZero && zf == 0) shouldJump = 1;
        else if (branchZero && zf) shouldJump = 1;
        else shouldJump = 0;
    end

endmodule
