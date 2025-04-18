.data
.text
.globl main

addi $sp, $0, -4096     # initailize the stack pointer
addi $sp, $sp, -48

addi $s0, $0, -192      # initialize the address to the button
addi $s1, $0, -208      # initialize the address to the LED

main:
    lw $t0, 0($s0)      # load button
    sw $t0, 0($s1)      # turn on the LED if pressed
    j main