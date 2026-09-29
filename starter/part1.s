.text
.globl part1

part1:

addi t1, x0, 1;
sll t1, t1, 2;
add t1, t1, t0; # index of 1
addi t2, x0, 3;
sll t2, t2, 2;
add t2, t2, t0; # index of 3
lw t1, 0(t1); # values[1]
lw t2, 0(t2); # values[3]
add t3, t1, t2; # their sum
addi t3, t3, 5; # add 5
