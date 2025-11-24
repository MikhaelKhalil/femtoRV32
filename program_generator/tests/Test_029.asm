sw x0, -843(x0)
bgeu x0, x0, 976
andi  x9, x0, 0
ebreak
jal x14, 0
lui x9, 0
bgeu x9, x9, 576
jal x22, 0
srai  x6, x14, 0
fence
bgeu x22, x17, -394
auipc x5, 0
ecall
beq x6, x14, -426
sb x5, 828(x24)
jal x10, -8387588
lui x24, 0
lw x28, 195(x14)
sw x22, 3131(x21)
jal x20, -8387588
