sw x0, -1603(x0)
auipc x3, 0
sw x0, -598(x14)
jal x26, 0
auipc x25, 0
jal x11, 0
ecall
auipc x30, 0
addi  x21, x27, 0
jal x14, -1048066
ecall
bne x21, x6, 24
sb x0, 323(x25)
jal x10, -1048066
blt x21, x12, 44
ebreak
sw x12, -799(x30)
ecall
slt  x5, x15, x27
fence
