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
    addi $k1, $0, 13
    beq $v0, $k1, _syscall13 #jump to syscall 12
    # Add branches to any syscalls required for your stars.

    #Error state - this should never happen - treat it like an end program
    j _syscall10

#Do init stuff
_syscall0:
    addi $sp, $0, -4096 #Initialize stack pointer
    la $k1, _END_OF_STATIC_MEMORY_ # initialize heap pointer
    sw $k1, -4096($0)
    j _syscallEnd_

#Print Integer
# the integer is stored in $a0
_syscall1:
    addi $sp, $sp, -4                       # save $ra
    sw $ra, 0($sp)
    bge $a0, $0, _syscall1Check0            # if $a0 > 0, go to _syscall1Check0
    addi $k1, $0, 45
    sw $k1, -256($0)                        # if negative, print "-" first
    abs $a0, $a0
    j _syscall1CheckLeftmost
_syscall1Check0:
    bne $a0, $0, _syscall1CheckLeftmost     # if $a0 is positive, go to _syscall1CheckLeftmost
    sw $a0, -256($0)                        # print 0
    j _syscall1Done
_syscall1CheckLeftmost:
    addi $k1, $0, 10000
    bge $a0, $k1, _syscall1TenThou
    addi $k1, $0, 1000
    bge $a0, $k1, _syscall1Thou
    addi $k1, $0, 100
    bge $a0, $k1, _syscall1Hund
    addi $k1, $0, 10
    bge $a0, $k1, _syscall1Ten
    addi $k1, $0, 1
    j _syscall1First
_syscall1TenThou: # print out 10000th digit
    addi $k1, $0, 10000
    div $a0, $k1
    mflo $k1
    addi $k1, $k1, 48
    sw $k1, -256($0)
    mfhi $a0
_syscall1Thou: # print out 1000th digit
    addi $k1, $0, 1000
    div $a0, $k1
    mflo $k1
    addi $k1, $k1, 48
    sw $k1, -256($0)
    mfhi $a0
_syscall1Hund: # print out 100th digit
    addi $k1, $0, 100
    div $a0, $k1
    mflo $k1
    addi $k1, $k1, 48
    sw $k1, -256($0)
    mfhi $a0
_syscall1Ten: # print out 10th digit
    addi $k1, $0, 10
    div $a0, $k1
    mflo $k1
    addi $k1, $k1, 48
    sw $k1, -256($0)
    mfhi $a0
_syscall1First: # print out 1st digit
    addi $a0, $a0, 48
    sw $a0, -256($0)
_syscall1Done:
    addi $k1, $0, 10
    sw $a0, -256($0)
    lw $ra, 0($sp)
    addi $sp, $sp, 4                        # load $ra
    jr $k0

#Read Integer
# load ASCII codes to $k1
# return the full integer in $v0
# note: $at, $t0
# NEED to save the registers in the heap memory
_syscall5:
    addi $sp, $sp, -4                       # save $ra
    sw $ra, 0($sp)
    lw $k1, -240($0)
    beq $k1, $0, _syscall5Done              # if no keypress, jump to _syscall5Done
    lw $k1, -236($0)                        # if keypress, read keyboard character
    addi $at, $0, 45                        # $at = "-"
    seq $at, $k1, $at                       # $at = 1 if negative (since the first character is "-")
    addi $v0, $0, 0                         # initialize $v0
    addi $t0, $0, 10                        # "\n" => ASCII 10
    addi $k1, $k1, -48  
    blt $k1, $0, _syscall5Loop
    addi $v0, $k1, 0                        # the leftmost digit
_syscall5Loop:
    sw $0, -240($0)                         # clear the leftmost character that is already read
    lw $k1, -236($0)                        # load the next new digit
    beq $k1, $t0, _syscall5LoopEnd          # if encountered "\n", break the loop
    addi $k1, $k1, -48                      # convert ASCII to a digit (0 is ASCII 48)
    mult $v0, $t0
    mflo $v0                                # $a0 *= 10
    add $v0, $v0, $k1                       # $v0 += $k1
    j _syscall5Loop
_syscall5LoopEnd:
    sw $0, -240($0)                         # clear the new line
    beq $at, $0, _syscall5Done              # if it was not negative, finish syscall
    addi $at, $0, -1                        # if negative, reverse the sign by multiplying by -1
    mult $v0, $at
    mflo $v0
_syscall5Done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4                        # load $ra
    jr $k0

#Heap allocation
# input: $a0 (number of bytes requested) 
# output: $v0 (pointer to / address of requested heap memory)
_syscall9:
    # Heap allocation code goes here
    lw $v0, -4096($0)
    add $k1, $v0, $a0      # $v0 = _END_OF_STATIC_MEMORY_ + $a0
    sw $k1, -4096($0)
    jr $k0

#"End" the program
_syscall10:
    j _syscall10

#print character
_syscall11:
    sw $a0, -256($0)                        # print the char
    jr $k0

#read character
_syscall12:

    addi $v0, $0, 0                 #sets v0 to 0

    keyboard_read:                                      
        bne $0, $v0, charFound      #loops until a keys been pressed
            lw $v0, -236($0)        #loads 1 to V0 if keyboard is ready
            j keyboard_read         #loops to check again

    charFound:
    lw $v0, -236($0)                #loads char into v0
    sw $0, -240($0)                 #clearn obtained char
    jr $k0                          #returns

#extra challenge syscalls go here?

# read button press
# output: $v0 <- 1 if pressed otherwise 0
# turns on the LED if pressed
_syscall13:
    addi $v0, $0, 0
    lw $v0, -192($0)                    # load button press
    sw $v0, -208($0)                    # turn on the LED if pressed
    jr $k0

_syscallEnd_: