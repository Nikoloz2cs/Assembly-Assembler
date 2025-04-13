#This is starter code, so that you know the basic format of this file.
#Use _ in your system labels to decrease the chance that labels in the "main"
#program will conflict

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
    # Initialization goes here
    j _syscallEnd_

#Print Integer
_syscall1:
    # Print Integer code goes here
    jr $k0

#Read Integer
_syscall5:
    # Read Integer code goes here
    jr $k0

#Heap allocation
_syscall9:
    # Heap allocation code goes here
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