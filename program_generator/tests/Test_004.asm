auipc x7, 498980
sw x7, 948(x0)
jal x8, 288787
fence.tso
and  x14, x0, x8
jal x25, 275892
jal x28, -201120
bge x8, x25, 432
addi  x17, x10, -1669
and  x15, x28, x10
