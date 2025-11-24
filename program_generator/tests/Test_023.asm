srli  x2, x0, 0
sw x0, -1338(x0)
auipc x8, 0
sltu  x22, x11, x0
bne x11, x11, -7
sh x22, 931(x22)
sra  x9, x11, x22
ecall
sb x8, 515(x12)
jal x11, 0
ebreak
bgeu x18, x8, -11
bge x12, x8, -9
ecall
sub  x21, x20, x4
sh x0, 266(x11)
sltiu  x27, x28, 0
fence.tso
jal x24, 518401
bltu x11, x20, -57
