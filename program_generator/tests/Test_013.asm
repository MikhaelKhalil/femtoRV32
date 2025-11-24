sra  x21, x0, x0
ebreak
bne x21, x19, 8
bge x21, x19, 4
jal x20, -1
jal x31, 327680
lb x16, 784(x19)
bgeu x17, x0, -9
sb x19, 759(x20)
slt  x19, x17, x14
