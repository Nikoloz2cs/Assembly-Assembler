#Setup#run this test once you have hooked up your RGBmonitor, keyboard, and memory
.data
.text
.globl main

addi $sp, $0, -4096 #Initialize stack pointer
addi $sp, $sp, -48

#address to load x (y is -172)
addi $s1, $0, -176
#address to rgb set x(y=-220)
addi $s2, $0, -224

addi $t7, $0, 255 #blue
sw $t7, 8($s2)

main:
#lw $t1, 0($s1)
    #loads X&Y value from controller
    lw $t4, 0($s1)
    lw $t5, 4($s1)
    #subtracts 8 to see if to move right/up(+) or left/down(-)
    addi $t4, $t4, -8
    addi $t5, $t5, -8
    #adjusts the x corrdinate in t1
    add $t1, $t1, $t4
    #adjusts the x corrdinate in t1
    add $t2, $t2, $t5
    #loads coordinates into RGB
    sw $t1, 0($s2)
    sw $t2, 4($s2)
    #writes to that pixel
    sw $0, 12($s2)

j main
