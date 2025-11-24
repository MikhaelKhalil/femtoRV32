sh x23, 0(x24)
bge x10, x0, 528
jal x9, -8387588
fence
or  x17, x10, x10
sll  x6, x0, x9
sh x23, 0(x29)
jalr  x8, x17, 0
beq x17, x17, 48
slli  x20, x10, 0
