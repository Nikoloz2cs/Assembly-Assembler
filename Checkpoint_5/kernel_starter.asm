#This is starter code, so that you know the basic format of this file.
#Use _ in your system labels to decrease the chance that labels in the "main"
#program will conflict

# in the assembler, a label "_END_OF_STATIC_MEMORY_" is created internally to speicfy the address of the end of static memory (constant during runtime)

.data
.text
_syscallStart_:
    beq $v0, $0, _syscall0 #jump to syscall 0
    addi $k1, $0, 1
    beq $v0, $k1, _syscall1 #jump to syscall 1
    addi $k1, $0, 5
    beq $v0, $k1, _syscall5 #jump to syscall 5
    addi $k1, $0, 9
    beq $v0, $k1, _syscall9 #jump to syscall 9
    addi $k1, $0, 10
    beq $v0, $k1, _syscall10 #jump to syscall 10
    addi $k1, $0, 11
    beq $v0, $k1, _syscall11 #jump to syscall 11
    addi $k1, $0, 12
    beq $v0, $k1, _syscall12 #jump to syscall 12
    # Add branches to any syscalls required for your stars.

    #Error state - this should never happen - treat it like an end program
    j _syscall10

#Do init stuff
_syscall0:
    addi $sp, $0, -4096 #Initialize stack pointer
    la $t0, _END_OF_STATIC_MEMORY_ # initialize heap pointer
    sw $t0, 0(-4096)
    j _syscallEnd_

#Print Integer
# the integer is stored in $a0
_syscall1:
    bge $a0, $0, _syscall1Check0            # if $a0 >= 0, go to _syscall1Check0
    addi $t0, $0, 45
    sw $t0, -256($0)                        # if negative, print "-" first
    addi $t1, $0, 10                        # for a base of 10 (will print integer in decimal)
_syscall1Check0:
    bne $a0, $0, _syscall1Positive          # if $a0 != 0, go to _syscall1Loop
    addi $t0, $0, 0
    sw $t0, -256($0)                        # print 0
    j _syscall1Done
_syscall1Positive:
    # print out 10000th digit
    addi $t0, $0, 10000
    div $a0, $t0
    mfhi $t0
    sw $t0, -256($0)
    
    # print out 1000th digit
    addi $t0, $0, 1000
    div $a0, $t0
    mfhi $t0
    sw $t0, -256($0)
    
    # print out 100th digit
    addi $t0, $0, 100
    div $a0, $t0
    mfhi $t0
    sw $t0, -256($0)
    
    # print out 10th digit
    addi $t0, $0, 10
    div $a0, $t0
    mfhi $t0
    sw $t0, -256($0)

    # print out 1st digit
    addi $t0, $0, 10
    div $a0, $t0
    mflo $t0
    sw $t0, -256($0)

    jr $k0

#Read Integer
# load ASCII codes to $v0
# return the full integer in $
# note:
# $t0, $t1
_syscall5:
    lw $k1, -240($0)
    beq $k1, $0, _syscall5Done              # if no keypress, jump to _syscall5Done
    lw $k1, -236($0)                        # if keypress, read keyboard character
    addi $t0, $0, 45                        # $t0 = "-"
    seq $t0, $k1, $t0                       # $t2 = 1 if negative (since the first character is "-")
    addi $v0, $0, 0                         # initialize $v0
    addi $t1, $0, 10                        # "\n" => ASCII 10
    addi $v0, $k1, 0                        # the leftmost digit
_syscall5Loop:
    sw $0, -240($0)                         # clear the leftmost character that is already read
    lw $k1, -236($0)                        # load the next new digit
    beq $k1, $t1, _syscall5LoopEnd          # if encountered "\n", break the loop
    addi $k1, $k1, -48                      # convert ASCII to a digit (0 is ASCII 48)
    add $v0, $v0, $k1                       # $a0 += $t0
    j _syscall5Loop
_syscall5LoopEnd:
    beq $t0, $0, _syscall5Done              # if it was not negative, finish syscall
    addi $t0, $0, -1                        # if negative, reverse the sign by multiplying by -1
    mult $v0, $t0
    mflo $v0
_syscall5Done:
    jr $k0

#Heap allocation
_syscall9:
    # Heap allocation code goes here
    la $v0, 0(-4096)
    addi $t0, $0, 4
    mult $a0, $t0
    mflo $t1
    add $v0, $v0, $t1      # $v0 = _END_OF_STATIC_MEMORY_ + 4 * $a0
    jr $k0

#"End" the program
_syscall10:
    j _syscall10

#print character
_syscall11:
    # print character code goes here
    jr $k0

#read character
_syscall12:
    # read character code goes here
    jr $k0

#extra challenge syscalls go here?

_syscallEnd_: