sh x0, -1822(x0)
ecall
sw x9, -1507(x0)
fence
jal x26, 521215
srli  x6, x0, 0
srai  x19, x23, 0
jal x28, 520191
ebreak
bltu x9, x0, 4
