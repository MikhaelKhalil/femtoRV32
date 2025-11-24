slli  x24, x0, 0
lui x21, 0
slt  x29, x0, x21
sra  x17, x29, x0
addi  x20, x24, 0
beq x20, x21, -26
jal x29, 0
sh x29, 2553(x0)
jal x10, 0
sb x13, 1271(x17)
srai  x10, x20, 0
ebreak
lui x29, 0
bgeu x24, x13, -426
beq x10, x29, -586
bne x21, x13, -74
or  x3, x24, x0
ecall
slt  x30, x18, x4
auipc x18, 0
