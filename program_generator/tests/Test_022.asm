beq x0, x0, 72
jal x16, 0
sra  x8, x16, x16
jal x21, 0
ecall
ori  x24, x29, 0
bge x16, x29, 48
lui x26, 0
sw x21, -1052(x24)
pause
