sltiu  x14, x0, 0
sb x14, -2058(x14)
sh x21, -1101(x0)
slt  x7, x21, x21
ecall
lui x7, 0
lh x6, 161(x0)
lui x16, 0
sub  x15, x16, x16
lui x1, 0
fence
lbu x3, 215(x1)
bltu x16, x21, 32
lw x25, 14(x7)
fence.tso
and  x8, x29, x15
ecall
jal x14, -8387588
sw x25, 3251(x7)
bgeu x7, x15, -426
