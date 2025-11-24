lui x16, 0
xori  x14, x0, 0
xori  x14, x16, 0
fence
srl  x24, x0, x28
pause
sra  x12, x14, x0
xori  x19, x0, 0
and  x24, x28, x0
jal x13, -8387588
beq x24, x13, 480
sw x24, -315(x13)
sw x25, -58(x25)
blt x0, x1, 112
jal x18, -8387588
sw x25, 1776(x18)
ori  x2, x14, 0
beq x13, x1, -442
sltu  x2, x25, x18
srl  x13, x18, x25
