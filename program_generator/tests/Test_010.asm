sub  x29, x0, x0
bge x29, x29, 974
fence
auipc x21, 0
sub  x30, x0, x29
fence
auipc x19, 0
auipc x11, 0
srl  x14, x11, x19
bgeu x25, x19, 96
