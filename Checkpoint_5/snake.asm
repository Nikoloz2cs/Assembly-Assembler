.data
.text
.align 2 
.globl main
main:
    addi $sp, $sp, -48
    # Store RGB values in stack allocated array
    # Mixing palette
    addi $t0, $0, 255 # blue
    sll $t1, $t0, 8  # green
    sll $t2, $t0, 16 # red
    addi $t3, $0, 127 # less blue
    sll $t4, $t3, 8 # less green
    sll $t5, $t3, 16 # less red
    # red - 0
    sw $t2, 0($sp)
    # red-orange - 1
    add $t8, $t2, $t4
    sw $t8, 4($sp)
    # yellow - 2
    add $t8, $t2, $t1
    sw $t8, 8($sp)
    # green-yellow - 3
    add $t8, $t5, $t1
    sw $t8, 12($sp)
    # green - 4
    sw $t1, 16($sp)
    # cyan-green - 5
    add $t8, $t3, $t1
    sw $t8, 20($sp)
    # cyan-6
    add $t8, $t0, $t1
    sw $t8, 24($sp)
    # cyan-blue
    add $t8, $t0, $t4
    sw $t8, 28($sp)
    # blue - 8
    sw $t0, 32($sp)
    # blue-magenta - 9
    add $t8, $t0, $t5
    sw $t8, 36($sp)
    # magenta - 10
    add $t8, $t0, $t2
    sw $t8, 40($sp)
    # red-magenta - 11
    add $t8, $t3, $t2
    sw $t8, 44($sp)

    

    # store variables in saved registers
    addi $s0, $zero, 128            # s0 - screenw = 128
    addi $s1, $zero, 126            # s1 - screenh = 126

    addi $s2, $zero, 64             # s2 - snakex = 64
    addi $s3, $zero, 63             # s3 - snakey = 63

    addi $s4, $zero, 1              # s4 -  xdirection=1
    addi $s5, $zero, 0              # s5 - ydirection=0

    # allocate memory for the 2d array board
    mult $s0, $s1                   # multiply to get num elements in array
    mflo $t0 
    sll $t0, $t0, 2                 # t0 = number of bytes need to allocate for the board

    add $a0, $zero, $t0             # allocate memory for the board
    addi $v0, $zero, 9              # syscall code to allocate memory
    syscall
    add $s6, $v0, $zero             # s6 - board = new int[126][128]

    addi $s7, $zero, 0              # s7 = color

# game loop
addi $t8, $zero, 97 # snake will always start going left

play:
    lw $t0, -240($0)                #keyboard status
    beq $t0, $0, nokey
    addi $v0, $zero, 12                # syscall12 to get keypress
    syscall 
    add $t7, $v0, $zero                # save keypress value in t7

    sw $0, -240($0)                # reset 0xff80 to prepare for the next keypress

    nokey:
    # pressed a
    addi $t1, $zero, 97                # ascii a 
    bne $t7, $t1, nota              
    beq $s2, $zero, endkeypress        # if snakex coord = 0, do nothing (maybe the game actually ends here bc it hit a wall, or... ??)
    addi $s4, $zero, -1                # xcoordinate = -1
    addi $s5, $zero, 0                 # ycoordinate = 0
    j endkeypress

    nota: # pressed d
        addi $t1, $zero, 100           # ascii d
        bne $t7, $t1, notd              
        beq $s2, $s0, endkeypress      # if snakex coord = screenw, do nothing
        addi $s4, $zero, 1             # xcoordinate = 1
        addi $s5, $zero, 0             # ycoordinate = 0
        j endkeypress

    notd: # pressed s 
        addi $t1, $zero, 115           # ascii s
        bne $t7, $t1, nots              
        beq $s3, $s1, endkeypress      # if snakey coord = screenh, do nothing
        addi $s4, $zero, 0             # xcoordinate = 0
        addi $s5, $zero, 1             # ycoordinate = 1
        j endkeypress

    nots: # then it's w
        addi $t1, $zero, 119           # ascii w
        bne $t7, $t1, endkeypress              
        beq $s3, $zero, endkeypress    # if snakey coord = 0, do nothing
        addi $s4, $zero, 0             # xcoordinate = 0
        addi $s5, $zero, -1            # ycoordinate = -1
        j endkeypress

    endkeypress:
        add $s2, $s2, $s4           # snakex += xcoordinate
        add $s3, $s3, $s5           # snakey += ycoordinate

        # if_(board[snakex][snakey] == 1)
        mult $s3, $s0               
        mflo $t0                    # t0 = snakey * screenw
        add $t0, $t0, $s2           # t0 += snakex
        sll $t0, $t0, 2             # t0*4 
        add $t0, $t0, $s6           # t0 = address of board[snakex][snakey]
        lw $t1, 0($t0)              # t1 = value of board[snakex][snakey]
        addi $t2, $zero, 1          # t2 = 1
        beq $t1, $t2, endgame       # break loop and end game snake has already been here
        
        # set board[snakex][snakey] = 1
        sw $t2, 0($t0)

        # snakex < 0
        slt $t0, $s2, $zero
        bne $t0, $zero, endgame     # break loop and end game if snakex is < 0 - out of bounds on the left

        # snakex > screenw
        slt $t0, $s0, $s2           # t0 = screenw < snakex
        bne $t0, $zero, endgame     # break loop and end game if screenw < snakex - out of bounds on the right

        # snakey < 0 
        slt $t0, $s3, $zero
        bne $t0, $zero, endgame     # break loop and end game if snakey is < 0 - out of bounds on the top

        # snakey > screenh
        slt $t0, $s1, $s3           # t0 = screenh < snakey
        bne $t0, $zero, endgame     # break loop and end game if screenh < snakey - out of bounds on the bottom
        
        colorchange:
            # change color
            addi $s7, $s7, 1
            addi $t1, $zero, 12
            div $s7, $t1
            mfhi $s7 # s7 = (s7 + 1) % 12
            sll $t1, $s7, 2
            add $t1, $t1, $sp # get address of color
            lw $t1, 0($t1) # t1 = load rgb color from memory
            # display pixel
            sw $s2, -224($0)           # 0xFF90 = monitor x coordinate
            sw $s3, -220($0)           # 0xFF94 = monitor y coordinate
            sw $t1, -216($0)           # 0xFF98 = monitor color
            sw $zero, -212($0)         # 0xFF9c = write pixel

    j play

endgame:
    # write to terminal - "YOU LOSE <3"
    addi $v0, $zero, 11                 # syscall 11 to print character
    addi $a0, $zero, 89 # Y
    syscall
    addi $a0, $zero, 79 # O
    syscall
    addi $a0, $zero, 85 # U
    syscall
    addi $a0, $zero, 32 # space
    syscall
    addi $a0, $zero, 76 # L
    syscall
    addi $a0, $zero, 79 # O
    syscall
    addi $a0, $zero, 83 # S
    syscall
    addi $a0, $zero, 69 # E
    syscall
    addi $a0, $zero, 32 # space
    syscall
    addi $a0, $zero, 60 # <
    syscall
    addi $a0, $zero, 51 # 3
    syscall

    addi $v0, $zero, 10                 # syscall 10 to end the program
    syscall
