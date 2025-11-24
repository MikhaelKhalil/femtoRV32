sub  x9, x0, x0
bge x9, x0, -3
auipc x12, 0
srl  x4, x9, x9
and  x13, x12, x17
beq x12, x13, 12
pause
ebreak
srai  x23, x0, 0
jal x7, -4097
