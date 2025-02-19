          .data 
          .text 
          .globl main
# Simple test - basic arithmetic, one negative immediate
main:
    addi $t0, $0, 10
    addi $t1, $0, 98
    sll $t2, $t1, 5
    srl $t8, $t1, 3
    mult $t1, $t1
    mflo $t3
    div $t2, $t0
    mfhi $s6
    slt $s2, $t1, $t0
    addi $s3, $s6, -3
    addi $v0, $zero, 10
    syscall #End the program
