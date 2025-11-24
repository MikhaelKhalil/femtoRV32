beq x0, x0, 1028
sh x0, 393(x0)
auipc x12, 0
sw x12, 593(x0)
slt  x2, x14, x0
sll  x13, x2, x12
ecall
ecall
lui x12, 0
lui x10, 0
