jal x13, 512
auipc x15, 0
slt  x12, x13, x13
and  x14, x0, x15
fence.tso
or  x11, x13, x12
sb x12, 1726(x11)
xor  x23, x0, x11
auipc x7, 0
lui x5, 0
