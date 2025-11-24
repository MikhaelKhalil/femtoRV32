sb x0, -1746(x0)
auipc x4, 0
sb x0, 1335(x4)
sh x10, 929(x10)
lh x21, 0(x0)
lui x26, 0
bgeu x10, x10, 16
ebreak
slt  x30, x12, x4
jalr  x24, x7, 0
