.data
some_static: .word 1 2 3
.text
.align 2 
.globl main

main:
add_test:
  # write two integers separated by enter, print the sum
  # Tests syscalls 1 and 5
  addi $v0, $0, 5
  syscall #read one integer
  add $s0, $0, $v0
  #addi $v0, $0, 12
  #syscall #read extra character # TODO: Do I need to revise how the "enter" character is handled?
  addi $v0, $0, 5
  syscall #read another integer
  add $a0, $s0, $v0
  addi $v0, $0, 1
  syscall #print the sum

char_test:
  # Prints a newline, then
  # Reads a char from the keyboard and prints it to the terminal.
  # Tests syscalls 11 and 12

  # Print newline:
  addi $a0, $0, 10
  addi $v0, $0, 11
  syscall

  addi $v0, $0, 12 
  syscall # Reads a character
  add $a0, $0, $v0
  add $v0, $0, 11
  syscall # prints the character

heap_test:
# Allocates space on the heap. Verify that this does not overwrite static memory.
  addi $a0, $0, 8
  addi $v0, $0, 9
  syscall # Allocates space for two ints on the heap.
  addi $t0, $0, 301
  sw $t0, 0($v0)
  addi $t0, $0, 42
  sw $t0, 4($v0)
  # Manually inspect your memory to ensure that 301 and 42 have been stored on the heap.
  # Verify that the static memory still holds 1, 2, 3. 

end:
  # Syscall 10: in our project, this just loops forever.
  addi $v0, $0, 10
  syscall
