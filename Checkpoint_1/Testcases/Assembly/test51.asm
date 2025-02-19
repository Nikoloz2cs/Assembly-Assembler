.data
    methodtable: .word function2
    array1: .word 10 20 30
    .text
    .globl main
main:
    addi $a0, $0, 10
    jal function
    la $t0, array3
    lw $t0, 0($t0)
    add $s0, $v0, $t0
    addi $v0, $0, 10
    syscall
