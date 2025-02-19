.data
          barray: .word 4 f
          array: .word 3 4 5 #This comment must be ignored
.text
.globl main
main:
  #This comment must be ignored
  addi $s0, $zero, 100 #this comment needs to be ignored
loop:
  add $a0, $s0, $0 #call f with parameter i
  jal f
  addi $s0, $v0, 0 #i = f(i)
  bne $s0, $zero, loop
  addi $v0, $0, 10
  syscall
f:
  la $t0, array
  srl $v0, $a0, 1
  jr $ra