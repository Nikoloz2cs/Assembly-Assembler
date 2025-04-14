.data
.text
.globl main
main:
    # Initialize stack pointer (if needed)
    addi $sp, $0, -4096
    addi $sp, $sp, -48
    
    # Morse code timing values (adjust these for visibility)
    addi $s3, $0, 1000000   # Short delay (dot)
    addi $s4, $0, 3000000   # Long delay (dash)
    addi $s5, $0, 1000000   # Gap between elements
    addi $s6, $0, 3000000   # Gap between letters
    addi $s7, $0, 7000000   # Gap between words
    
    # LED address 
    addi $t9, $0, -208

main_loop:
    # First 'S' (...)
    jal dot
    jal dot
    jal dot
    
    # Gap between letters
    add $a0, $0, $s6
    jal delay
    
    # 'O' (---)
    jal dash
    jal dash
    jal dash
    
    # Gap between letters
    add $a0, $0, $s6
    jal delay
    
    # Second 'S' (...)
    jal dot
    jal dot
    jal dot
    
    # Gap between words
    add $a0, $0, $s7
    jal delay
    
    j main_loop

dot:
    # Turn on LED
    addi $t0, $0, 1
    sw $t0, 0($t9)
    
    # Short delay
    add $a0, $0, $s3
    jal delay
    
    # Turn off LED
    sw $0, 0($t9)
    
    # Gap between elements
    add $a0, $0, $s5
    jal delay
    
    jr $ra

dash:
    # Turn on LED
    addi $t0, $0, 1
    sw $t0, 0($t9)
    
    # Long delay
    add $a0, $0, $s4
    jal delay
    
    # Turn off LED
    sw $0, 0($t9)
    
    # Gap between elements
    add $a0, $0, $s5
    jal delay
    
    jr $ra

delay:
    # Simple delay loop
    addi $a0, $a0, -1
    bne $a0, $0, delay
    jr $ra