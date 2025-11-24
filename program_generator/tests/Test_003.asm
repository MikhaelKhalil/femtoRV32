ecall
sll  x23, x0, x9
sh x23, -653(x9)
fence.tso
lw  x21, x2, -182
lui x30, 46734
fence.tso
sb x9, -579(x30)
pause
add  x27, x0, x23
