lui x16, 0
jal x25, 1536
slt  x7, x0, x25
lui x13, 0
beq x7, x13, -13
sh x7, -1511(x17)
or  x23, x0, x7
fence.tso
beq x23, x0, -1
fence.tso
