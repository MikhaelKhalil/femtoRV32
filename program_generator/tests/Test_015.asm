bge x0, x0, 8
auipc x3, 0
slti  x12, x3, 0
auipc x10, 0
sub  x3, x3, x3
jal x10, 2560
srli  x29, x0, 0
fence
lui x5, 0
jal x12, -4609
