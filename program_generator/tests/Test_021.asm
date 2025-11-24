sra  x11, x0, x0
bne x0, x0, 36
jal x5, 0
srl  x9, x5, x5
bge x9, x5, 20
lh x20, 160(x9)
sub  x19, x20, x0
auipc x10, 0
fence
jal x28, 518401
