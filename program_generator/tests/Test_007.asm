auipc x3, 0
pause
bge x0, x0, 454
sb x20, 1806(x3)
bge x0, x7, 356
ecall
pause
jal x14, 32784
