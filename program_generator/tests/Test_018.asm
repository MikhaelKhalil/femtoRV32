beq x0, x0, 10
jal x6, -1
sll  x10, x0, x0
auipc x16, 0
pause
bne x0, x6, -17
lui x12, 0
fence.tso
add  x8, x6, x1
beq x13, x0, 0
