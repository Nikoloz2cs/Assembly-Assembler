          .data #memoized DP calculation of f(x) = f(x-1) + f(x//2) + x^2
          .text #f(0) = 0
          .globl main
          #More advanced test - labels needed for jumps, branches
main:
  addi $a0, $zero, 10 #a0 = n
  addi $t0, $a0, 1
  sll $t0, $t0, 2
  sub $sp, $sp, $t0 #create an array of size n+1
  srl $a1, $sp, 0 #a1 is the array pointer
  sw $zero, 0($a1) #a1[0] = 0
  add $t0, $a0, $zero #number of times to iterate
  addi $t1, $a1, 4 #pointer to iterate through array
  addi $t8, $zero, -1
initloop:
  sw $t8, 0($t1)
  addi $t1, $t1, 4
  addi $t0, $t0, -1
  bne $t0, $zero, initloop #init array to -1
endinit:
  jal f
  j end
f:
  addi $sp, $sp, -16
  sw $s0, 0($sp)
  sw $s1, 4($sp)
  sw $s2, 8($sp)
  sw $ra, 12($sp)
  addi $s0, $a0, 0
  addi $t0, $s0, -1
  sll $t1, $t0, 2
  add $t1, $a1, $t1
  lw $s1, 0($t1)
  slt $t2, $s1, $zero
  beq $t2, $zero, firstcalldone
  addi $a0, $t0, 0
  jal f
  addi $s1, $v0, 0
firstcalldone:
  srl $t0, $s0, 1
  sll $t1, $t0, 2
  add $t1, $a1, $t1
  lw $s2, 0($t1)
  slt $t2, $s2, $zero
  beq $t2, $zero, secondcalldone
  addi $a0, $t0, 0
  jal f
  addi $s2, $v0, 0
secondcalldone:
  mult $s0, $s0
  mflo $v0
  add $v0, $v0, $s1
  add $v0, $v0, $s2
  sll $t0, $s0, 2
  add $t0, $a1, $t0
  sw $v0, 0($t0)
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $ra, 12($sp)
  addi $sp, $sp, 16
  jr $ra
end:
  addi $v0, $zero, 10
  syscall #End the program in QTSPIM
