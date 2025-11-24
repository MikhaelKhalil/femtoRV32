beq x0, x0, None
or  x6, x4, x4
jal x12, None
ebreak
sh x4, None(x6)
sw x19, None(x4)
sb x6, None(x4)
auipc x10, 0
ori  x3, x18, 0
lui x20, 0
