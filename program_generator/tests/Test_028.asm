lui x5, 0
auipc x15, 0
jal x2, 0
blt x2, x2, 1056
jal x30, 0
jal x20, 0
ori  x9, x5, 0
bge x9, x30, -474
sh x20, 2097(x15)
fence
lbu x24, 83(x9)
srli  x8, x15, 0
lui x24, 0
sh x8, 2809(x15)
jal x18, -8387588
andi  x17, x9, 0
addi  x11, x30, 0
ecall
beq x20, x14, 16
ecall
