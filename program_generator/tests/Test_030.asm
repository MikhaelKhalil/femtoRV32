bltu x0, x0, 384
auipc x17, 0
and  x7, x21, x21
jal x22, 0
auipc x26, 0
sb x26, 2946(x0)
xor  x7, x22, x22
jal x25, 0
and  x10, x21, x0
srl  x13, x10, x26
lhu x14, 156(x13)
jal x29, 0
xor  x21, x3, x17
ebreak
jal x20, -8387588
jal x28, 0
bge x21, x20, 480
ecall
lui x31, 0
sh x25, 3189(x21)
jal x22, -8387588
sh x14, 3598(x22)
lui x24, 0
srl  x19, x20, x28
xori  x2, x31, 0
sb x13, -1488(x19)
srl  x10, x13, x13
jal x19, -8387588
sh x31, 2100(x17)
lhu x23, 248(x22)
