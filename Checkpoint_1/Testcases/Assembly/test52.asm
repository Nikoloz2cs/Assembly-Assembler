.data
.text
function:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    la $t0, methodtable
    lw $t0, 0($t0) #address of methodtable[0]
    jalr $t0 #jump to that method
    la $t0, array1
    lw $t0, 4($t0)
    add $v0, $v0, $t0

    lw $ra, 0($sp)
    addi $sp, $sp, 4