.data
    functions: .word dot dash 
.text
.globl main
main:
    # Initialize stack pointer (if needed)
    addi $sp, $0, -4096
    addi $sp, $sp, -48
    
    # Morse code timing values (adjust these for visibility)
    addi $s3, $0, 1  # Short delay (dot)
    addi $s4, $0, 2   # Long delay (dash)
    addi $s5, $0, 1   # Gap between elements
    addi $s6, $0, 4   # Gap between letters
    addi $s7, $0, 5   # Gap between words
    
    # LED address 
    addi $t9, $0, -208

main_loop:
    # First 'S' (...)
    jal dot
    jal dot
    jal dot
    
    # Gap between letters
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0
    
    # 'O' (---)
    jal dash
    jal dash
    jal dash
    
    # Gap between letters
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0

    # Second 'S' (...)
    jal dot
    jal dot
    jal dot
    
    # Gap between words
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0
    add $a0, $0, $0

    j main_loop

dot:
    # Turn on LED
    sw $t0, 0($t9)
    jr $ra

dash:
    # Turn on LED
    sw $t0, 0($t9)
    sw $t0, 0($t9)
    sw $t0, 0($t9)
    sw $t0, 0($t9)
    
    jr $ra

