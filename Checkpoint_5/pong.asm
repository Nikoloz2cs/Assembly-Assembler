.data
    score: .word 0 0
    result: .asciiz "Player 0 won!"
    score_result: .asciiz "  0 : 0  "
    ball_color: .word 0
    ball_color_RGB: .word 0 16711680 65280 255 65535 16776960 16711935 16777215
.text
.globl main
main:
    # Initialize stack
    addi $sp, $0, -4096

    # Initialize game borders

    # Draw top border (x from 9 to 39, y=120)  
    addi $t0, $0, 9
    addi $t1, $0, 39
    addi $t2, $0, 120
    sw $t2, -220($0)   
    top_loop:
        addi $t0, $t0, 1    
        sw $t0, -224($0)   
        sw $0, -212($0)  
        slt $t5, $t1, $t0  
        beq $t5, $0, top_loop 

    # Draw bottom border (x from 9 to 39, y=136)
    addi $t0, $0, 9
    addi $t1, $0, 39
    addi $t2, $0, 136
    sw $t2, -220($0)
    bottom_loop:
        addi $t0, $t0, 1
        sw $t0, -224($0)
        sw $0, -212($0)  
        slt $t5, $t1, $t0  
        beq $t5, $0, bottom_loop 

    # Draw left border (y from 120 to 136, x=10)
    addi $t0, $0, 119
    addi $t1, $0, 135
    addi $t2, $0, 10
    sw $t2, -224($0)
    left_loop:
        addi $t0, $t0, 1  
        sw $t0, -220($0)
        sw $0, -212($0)  
        slt $t5, $t1, $t0  
        beq $t5, $0, left_loop 

    # Draw right border (y from 120 to 136, x=40)
    addi $t0, $0, 119
    addi $t1, $0, 135
    addi $t2, $0, 40
    sw $t2, -224($0)
    right_loop:
        addi $t0, $t0, 1
        sw $t0, -220($0)
        sw $0, -212($0)  
        slt $t5, $t1, $t0  
        beq $t5, $0, right_loop 


    # make yellow for "deleting" pixels
    addi $t0, $0, 255 # blue
    sll $t1, $t0, 8   # green
    sll $t2, $t0, 16  # red
    add $s8, $t2, $t1 # make yellow

next_round:
    addi $t9, $0, 87654321   # initial seed value

    # Initialize paddles
    addi $s0, $0, 126 # left y-cord
    addi $s1, $0, 12  # left x-cord
    addi $s2, $0, 126 # right y-coord
    addi $s3, $0, 38 # right x-cord

    # Draw left paddle
    addi $a0, $s1, 0   # Load x-pos
    addi $a1, $s0, 0   # Load y-pos
    jal draw_paddle
    
    # Draw right paddle
    addi $a0, $s3, 0   # Load x-pos
    addi $a1, $s2, 0   # Load y-pos
    jal draw_paddle 
    
    # Draw ball and give direction + movement
    addi $s4, $0, 128 # ball y-cord
    addi $s5, $0, 25  # ball x-cord
    addi $s6, $0, 0   # ball dy
    addi $s7, $0, 2   # ball dx
    sw $s5, -224($0)
    sw $s4, -220($0)
    sw $0, -212($0)

game_loop:
    # check for ball scoring
    addi $t1, $0, 12
    addi $t2, $0, 38
    slt  $t0, $s5, $t1    # $t0 = 1 if s5 < 10
    bne  $t0, $0, player_2_won       # Branch to b if ball is beyond the paddles
    slt  $t0, $t2, $s5    # $t0 = 1 if 39 < s5 
    bne  $t0, $0, player_1_won       # Branch to b if ball is beyond the paddles
    addi $v0, $0, 13
    syscall                         # change the ball color if requested
    beq $v0, $0, check_right_paddle

change_ball_color:
    la $t0, ball_color
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    addi $t2, $0, 8
    bne $t1, $t2, save_ball_color
    addi $t1, $t1, -8
save_ball_color:
    sw $t1, 0($t0)

check_right_paddle:
    addi $a0, $s3, 0        # Right paddle x
    addi $a1, $s2, 0        # Right paddle top y
    addi $a2, $s5, 0        # Ball x
    addi $a3, $s4, 0        # Ball y
    jal check_paddle_collision
    
    beq $v0, $0, check_left_paddle


check_left_paddle:
    addi $a0, $s1, 0        # Left paddle x 
    addi $a1, $s0, 0        # Left paddle top y
    addi $a2, $s5, 0        # Ball x
    addi $a3, $s4, 0        # Ball y
    jal check_paddle_collision
    
    beq $v0, $0, after_collisions
    

after_collisions:
    #check for keypress
    lw $t0, -240($0) #0xFFFFFF10 = keyboard ready
    beq $t0, $0, next_frame #if no keypress, jump to next iteration

    #if keypress, update paddles accordingly
    lw $t0, -236($0) #0xFFFFFF14 = read keyboard character

    addi $t1, $0, 119 #ascii w, move left up
    bne $t0, $t1, notw

    addi $t0, $0, 122
    beq $s0, $t0, hit_border_w 
    addi $a0, $s1, 0   # Load x-pos
    addi $a1, $s0, 0   # Load y-pos
    jal paddle_up
    addi $s0, $s0, -1   # update y "pointer"
    
    hit_border_w:
    j endkeypress
notw:
    addi $t1, $0, 115 #ascii s, move left down
    bne $t0, $t1, nots

    addi $t0, $0, 135
    addi $t1, $s0, 4
    beq $t1, $t0, hit_border_s
    addi $a0, $s1, 0   # Load x-pos
    addi $a1, $s0, 0   # Load y-pos
    jal paddle_down
    addi $s0, $s0, 1   # update y "pointer"

    hit_border_s:
    j endkeypress
nots:
    addi $t1, $0, 105  # ascii i, move right up
    bne $t0, $t1, noti

    addi $t0, $0, 122
    beq $s2, $t0, hit_border_i
    addi $a0, $s3, 0   # Load x-pos
    addi $a1, $s2, 0   # Load y-pos
    jal paddle_up
    addi $s2, $s2, -1   # update y "pointer"

    hit_border_i:
    j endkeypress
noti:
    addi $t1, $0, 107 # ascii k, move right down
    bne $t0, $t1, endkeypress

    addi $t0, $0, 135
    addi $t1, $s2, 4
    beq $t1, $t0, endkeypress
    addi $a0, $s3, 0   # Load x-pos
    addi $a1, $s2, 0   # Load y-pos
    jal paddle_down
    addi $s2, $s2, 1   # update y "pointer"

endkeypress:
    sw $0, -240($0) # set keyboard ready to 0 to get next character

next_frame:
    jal move_ball
    j game_loop


# Draws a paddle at given (x, y) position
# Input: $a0 = x-coord, $a1 = y-coord (top pixel)
draw_paddle:
    sw $0, -216($0)      # set to black
    addi $t0, $a1, 0      # Current y = start y 
    addi $t1, $a1, 5      # End y = start y + 4
    sw $a0, -224($0)  # Set X-coord
    paddle_loop:
        sw $t0, -220($0)  # Set Y-coord
        sw $0, -212($0)   # Draw black pixel (0xFFFFFF2C)
        
        addi $t0, $t0, 1  # Move to next y-position
        slt $t2, $t0, $t1  # $t2 = ($t0 < $t1) ? 1 : 0
        bne $t2, $0, paddle_loop  # Branch if still less
    
    jr $ra

# Erase a paddle at given (x, y) position
# Input: $a0 = x-coord, $a1 = y-coord (top pixel)
erase_paddle:
    sw $s8, -216($0)      # set to yellow
    addi $t0, $a1, 0      # Current y = start y 
    addi $t1, $a1, 5      # End y = start y + 4
    sw $a0, -224($0)  # Set X-coord
    paddle_loop:
        sw $t0, -220($0)  # Set Y-coord
        sw $0, -212($0)   # Draw yellow pixel (0xFFFFFF2C)
        
        addi $t0, $t0, 1  # Move to next y-position
        slt $t2, $t0, $t1  # $t2 = ($t0 < $t1) ? 1 : 0
        bne $t2, $0, paddle_loop  # Branch if still less
    
    jr $ra


# Moves a paddle up 1 pixel
# Input: $a0 = x-coord, $a1 = y-coord (top pixel)
paddle_up:
    sw $a0, -224($0)  # Set X-coord

    addi $t0, $a1, 4    
    sw $t0, -220($0)
    sw $s8, -216($0)
    sw $0, -212($0)   # draw yellow pixel
    
    addi $t0, $a1, -1     
    sw $t0, -220($0)  
    sw $0, -216($0)
    sw $0, -212($0)  # draw black pixel
    
    jr $ra

paddle_down:
    sw $a0, -224($0)  # Set X-coord

    addi $t0, $a1, 4   
    sw $t0, -220($0)
    sw $0, -216($0)
    sw $0, -212($0)   # draw black pixel
    
    addi $t0, $a1, -1     
    sw $t0, -220($0)  
    sw $s8, -216($0)
    sw $0, -212($0)  # draw yellow pixel
    hit_border_down:
    jr $ra

move_ball:
    # Clear last location
    sw $s5, -224($0)
    sw $s4, -220($0)
    sw $s8, -216($0)
    sw $0, -212($0)

    # Update position
    add $s4, $s4, $s6 # new y coordinate
    add $s5, $s5, $s7 # new x coordinate

    # Check for top/bottom border collisions
    addi $t0, $0, 121    # Top border Y
    slt $t1, $s4, $t0     # ball_y < top_border?
    beq $t1, $0, check_bottom
    sub $s6, $0, $s6      # Invert y-velocity (hit top)
    addi $s4, $t0, 1      # Move ball below border to prevent sticking

check_bottom:
    addi $t0, $0, 135     # Bottom border Y
    slt $t1, $t0, $s4     # bottom_border < ball_y?
    beq $t1, $0, draw_ball
    sub $s6, $0, $s6      # Invert y-velocity (hit bottom)
    addi $s4, $t0, -1     # Move ball above border

draw_ball:
    la $t0, ball_color
    lw $t0, 0($t0)          # load ball color index

    addi $t1, $0, 4
    mult $t0, $t1
    mflo $t0
    
    la $t1, ball_color_RGB
    add $t1, $t1, $t0
    lw $t0, 0($t1)          # load ball color RGB

    sw $s5, -224($0)
    sw $s4, -220($0)
    sw $t0, -216($0)
    sw $0, -212($0)
    jr $ra

# Collision detection with physics - call for EACH paddle
# Inputs: $a0=paddle_x, $a1=paddle_top_y, $a2=ball_x, $a3=ball_y
# Returns: $v0=1 if collision, 0 otherwise
check_paddle_collision:
    # For RIGHT paddle: check ball_x >= paddle_x - 1 AND ball_x <= paddle_x + 1
    # For LEFT paddle: check ball_x <= paddle_x + 1 AND ball_x >= paddle_x - 1
    
    # First check x proximity (2 pixel wide collision zone)
    addi $t0, $a0, 1       # paddle_x + 1
    slt $t1, $t0, $a2      # $t1=1 if paddle_x+1 < ball_x (too far right)
    bne $t1, $0, no_coll
    
    addi $t0, $a0, -1      # paddle_x - 1
    slt $t1, $a2, $t0      # $t1=1 if ball_x < paddle_x-1 (too far left)
    bne $t1, $0, no_coll
    
    # Now check y collision (ball between paddle top and bottom)
    addi $t1, $a1, -1
    slt $t0, $a3, $t1      # $t0=1 if ball_y < paddle_top (above)
    bne $t0, $0, no_coll
    
    addi $t2, $a1, 4       # paddle_bottom = top + 4
    slt $t0, $t2, $a3      # $t0=1 if paddle_bottom < ball_y (below)
    bne $t0, $0, no_coll
    
    # COLLISION DETECTED

    # use LCG algorithm to get a random y-velocity
    addi    $t0, $0, 1103515245   # LCG multiplier
    addi    $t1, $0, 12345        # LCG increment
    addi    $t2, $0, 5            # range (5 possible values: 0, 1, 2, 3, 4)

    # Calculate next seed value using LCG formula
    mult    $t9, $t0          # Hi, Lo = $t3 * $t0
    mflo    $t9               # $t3 = Lo (lower 32 bits)
    add     $t9, $t9, $t1     # $t3 = $t3 + $t1

    # Generate value between 0 and 4
    div     $t9, $t2          # Lo = $t3 / $t2, Hi = $t3 % $t2
    mfhi    $t4               # $t4 = Hi (remainder, 0 to 4)

    # change y-velocity to range from 0-4 to -2 to 2 
    addi    $s6, $t4, -2      # $t4 = $t4 - 2

    sub $s7, $0, $s7       # Reverse x-direction
    addi $v0, $0, 1
    jr $ra

no_coll:
    addi $v0, $0, 0
    jr $ra

player_1_won:
    la $t1, score
    lw $t2, 0($t1)
    addi $t2, $t2, 1
    sw $t2, 0($t1)                      # update the score

    addi $t0, $0, 1
    j end_game

player_2_won:
    la $t1, score
    lw $t2, 4($t1)
    addi $t2, $t2, 1
    sw $t2, 4($t1)                      # update the score

    addi $t0, $0, 2
    j end_game

end_game:
    # print "Player {n} won!"
    addi $v0, $zero, 11                 # syscall 11 to print character

    la $t1, result
    lw $t2, 28($t1)
    addi $t2, $t0, 48
    sw $t2, 28($t1)                     # update the winner (1 or 2)

    addi $t3, $0, 10                    # "\n"
    print_result:
        lw $a0, 0($t1)
        syscall
        beq $a0, $t3, end_print_result
        addi $t1, $t1, 4
        j print_result
    end_print_result:

    # print "  {P1 score} : {P2 score}  "
    la $t1, score_result
    la $t2, score
    lw $t4, 0($t2)
    addi $t4, $t4, 48
    sw $t4, 8($t1)                     # update player 1 score result
    lw $t4, 4($t2)
    addi $t4, $t4, 48
    sw $t4, 24($t1)                     # update player 2 score result 

    print_score:
        lw $a0, 0($t1)
        syscall
        beq $a0, $t3, end_print_score
        addi $t1, $t1, 4
        j print_score
    end_print_score:
    syscall

    j next_round_init

    addi $v0, $zero, 10                 # syscall 10 to end the program
    syscall

next_round_init:
    # erase left paddle
    addi $a0, $s1, 0   # Load x-pos
    addi $a1, $s0, 0   # Load y-pos
    jal erase_paddle
    
    # erase right paddle
    addi $a0, $s3, 0   # Load x-pos
    addi $a1, $s2, 0   # Load y-pos
    jal erase_paddle

    # erase ball
    sw $s5, -224($0)
    sw $s4, -220($0)
    sw $s8, -216($0)
    sw $0, -212($0)

    j next_round
