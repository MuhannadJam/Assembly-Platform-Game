#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Muhannad Al-Jamali, 1008017263, jamalim5, muhannad.aljamali@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
groundColor:	.word	0x7CFC00
playerFace:	.word 	0xECBCB4
playerBody:	.word	0x5579C6
black:		.word	0x000000
djColor:	.word	0xB200ED

keyboardInput:	.word	0xFFFF0000

gameRunning:	.word	1
onSurface:	.word 	1
jumped:		.word 	0
doubleJump:	.word 	0

groundPos:	.word	30720
playerPos:	.word	18688
playerX:	.word	0
playerY:	.word	110

djX:		.word	30
djY:		.word	118

str:		.asciiz	"Test\n"

.eqv BASE_ADDRESS 0x10008000

.globl main
.text

main:
	
start:	
	li $t1, 1		# #t1 = 1
	sw $t1, onSurface	# onSurface = 1
	sw $t1, gameRunning	# gameRunning = 1
	li $t1, 0		# t1 = 0
	sw $t1, jumped		# jumped = 0
	sw $t1, doubleJump	# doubleJump = 0
	sw $t1, playerX		# playerX = 0
	li $t1, 110		# $t1 = 110
	sw $t1, playerY		# playerY = 110
	jal clear_screen	# Clear the screen
	jal draw_map		# Draw the map
	jal draw_character	# Draw the character

	# Start of game loop
game_loop:
	li $v0, 32
	li $a0, 40
	syscall			# Make the program sleep for 40 ms
	jal keyboard		# Check keyboard inputs
	jal ground_collision	# Check player collision with ground
	jal dj_collision
	jal gravity		# Check if gravity needs to be applied
	lw $t1, gameRunning	
	bnez $t1, game_loop	# If gameRunning continue loop else jump to End
	j end
		
clear_screen: 
	li $t0, BASE_ADDRESS	# Store base address in $t0
	lw $t1, black		# Store black in $t1
	add $t4, $t0, $zero	
	li $t5, 1
clear:	sw $t1, 0($t4)  	# Clear the entire screen
	addi $t4, $t4, 4
	addi $t5, $t5, 1
	ble $t5, 8192, clear	# IF we didnt reach end of screen, branch to clear
	jr $ra

	
	
draw_map:
	li $t0, BASE_ADDRESS 	# Store base address in $t0
	lw $t4, groundPos	# Store groundPos in $t4
	lw $t2, groundColor	# Store groundColor in $t2
	add $t4, $t0, $t4	
	li $t5, 1		# i = 1
ground:	sw $t2, 0($t4) 		# Drawing the ground
	addi $t4, $t4, 4
	addi $t5, $t5, 1
	ble $t5, 512, ground	# i <= 512, branch to ground
dj_powerup:		
	addi $t4, $t0, 30328	# Store position of powerup in $t4	
	lw $t2, djColor		# Store djColor in $t2
	sw $t2, 0($t4)		# Draw the gj powerup
	sw $t2, 4($t4)
	sw $t2, 256($t4)
	sw $t2, 260($t4)
	jr $ra			# Return to callee
	
get_pos:
	sll $a0, $a0, 2
	li $t3, 256
	mult $a1, $t3
	mflo $a1
	add $v0, $a0, $a1
	jr $ra
	
draw_character:
	addi $sp, $sp, -4	# Free space on stack
	sw $ra, 0($sp)		# Push $ra onto stack
	lw $a0, playerX		# Argument 1 for get_pos
	lw $a1, playerY		# Argument_2 for get_pos
	jal get_pos		# Get the position of the character
	li $t0, BASE_ADDRESS	# Store base address in $t0
	add $t4, $t0, $v0	# Getting the drawing positions
	li $t8, 1		# $t8 = i = 1
	lw $t3, playerFace
face:	sw $t3, 0($t4)		# Drawing the character face
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4) 
	addi $t4, $t4, 256
	addi $t8, $t8, 1	# i++
	ble $t8, 4, face	# If i <= 4 branch to face
	lw $t1, doubleJump	# $t1 = doubleJump 		
	lw $t3, playerBody	# Storing the playerBody color in $t3
	beqz $t1, drawb		# If character doesnt have double jump branch to drawbS
	lw $t3,	djColor		# Storing the double jump color in $t3
drawb:	li $t1, 1		# $t1 = i = 1
body:	sw $t3, 0($t4)		# Drawing the character body
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	addi $t4, $t4, 256
	addi $t1, $t1, 1	# i++
	ble $t1, 6, body	# If i <= 6 branch to body
	lw $ra, 0($sp)		# Pop $ra off the stack
	addi $sp, $sp, 4	# Free allocated space on the stack
	jr $ra			# Return to callee

clear_character:
	addi $sp, $sp, -4	# Free space on stack
	sw $ra, 0($sp)		# Push $ra onto stack
	lw $a0, playerX		# Argument 1 for get_pos
	lw $a1, playerY		# Argument_2 for get_pos
	jal get_pos		# Get character position
	li $t0, BASE_ADDRESS	# Store base address in $t0
	add $t4, $t0, $v0	# Getting the drawing positions
	li $t8, 1		# $t8 = i = 1
	lw $t3, black		# Store black in $t3
remove:	sw $t3, 0($t4)		# Erasing the character
	sw $t3, 4($t4)		
	sw $t3, 8($t4)
	sw $t3, 12($t4) 
	addi $t4, $t4, 256
	addi $t8, $t8, 1	# i++
	ble $t8, 10, remove	# If i <= 10 branch to remove
	lw $ra, 0($sp)		# pop $ra off the stack
	addi $sp, $sp, 4	# Free allocated space on the stack
	jr $ra			# Return to callee

keyboard:
	lw $t9, keyboardInput	# Load address to get keyboard input in $t9
	lw $t8 0($t9)		# Store value to check for keyboard input in $t8
	beq $t8, 1, check_key	# If input detected branch to check_key
	jr $ra			# Return to callee

check_key:
	lw $t2, 4($t9)			# Store input ket in $t2
	beq $t2, 0x61, move_left	# If input 'a' branch to move_left
	beq $t2, 0x64, move_right	# If input 'd' branch to move_right
	beq $t2, 0x77, move_up		# If input 'w' branch to move_up
	beq $t2, 0x70, start		# If input 'p' branch to restart
	beq $t2, 0x71, end		# If input 'q' branch to end
	jr $ra				# Return to callee
	
move_left:
	lw $t5, playerX		# Store playerX in $t5
	beqz $t5, skip_a	# If playerX we are at the edge so branch to skip_a	
	addi $sp, $sp, -4	# Free space on the stack
	sw $ra, 0($sp)		# Push $ra on the stack
	jal clear_character	# Erase the character
	lw $t5, playerX		# Store playerX in $t5
	sub $t5, $t5, 1		# $t5 = playerX--
	sw $t5, playerX		# playerX = $t5
	jal draw_character	# Redraw character
	lw $ra, 0($sp)		# Pop $ra off the stack 
	addi $sp, $sp, 4	# Free allocated space on the stack
skip_a:		
	jr $ra			# Return to callee
	
move_right:
	lw $t5, playerX		# Store playerX in $t5
	beq $t5, 60, skip_d	# If playerX we are at the edge so branch to skip_d	
	addi $sp, $sp, -4	# Free space on the stack
	sw $ra, 0($sp)		# Push $ra on the stack
	jal clear_character	# Erase the character
	lw $t5, playerX		# Store playerX in $t5
	addi $t5, $t5, 1	# $t5 = playerX++
	sw $t5, playerX		# playerX = $t5
	jal draw_character	# Redraw character
	lw $ra, 0($sp)		# Pop $ra off the stack 
	addi $sp, $sp, 4	# Free allocated space on the stack
skip_d:		
	jr $ra			# Return to callee
	
move_up:
	lw $t5, onSurface	# $t5 = onSurface
	lw $t6, doubleJump	# $t6 = doubleJumps
	beq $t5, 1, jump	# If character on surface then branch to jump
	beq $t6, 1, djump	# If character can double jump branch to djump
	jr $ra			# Return to callee
jump:	addi $sp, $sp, -4	# Clear space on the stack
	sw $ra, 0($sp)		# Push $ra onto the stack
	jal clear_character	# Erase the character
	lw $t5, playerY		# $t5 = playerY
	sub $t5, $t5, 16	# $t5 = playerY + 16
	sw $t5, playerY		# playerY = $t5
	jal draw_character	# Redraw character
	lw $ra, 0($sp)		# Pop $ra off the stack
	addi $sp, $sp, 4	# Free allocated space on the stack
skip_w:
	jr $ra			# Return to callee

djump:	lw $t7, jumped		# $t7 = jumped	
	beq $t7, 1, skip_w	# If already jumped then branch to skip_w
	li $t7, 1		# $t7 = 1
	sw $t7, jumped		# jumped = 1
	j jump			# Branch to jump

gravity:
	lw $t1, onSurface	# $t1 = onSurface
	bnez $t1, skip_gravity	# If character on surface branch to skip_gravity
	addi $sp, $sp, -4	# Free space on the stack
	sw $ra, 0($sp)		# Push $ra on the stack
	jal clear_character	# Erase the character
	lw $t5, playerY		# $t5 = playerY
	addi $t5, $t5, 1	# $t5 = playerY--
	sw $t5, playerY		# playerY = $t5
	jal draw_character	# Redraw character
	lw $ra, 0($sp)		# pop $ra off the stack
	addi $sp, $sp, 4	# Free allocated space on the stack
skip_gravity:	
	jr $ra			# Return to callee
	
ground_collision:
	lw $t1, playerY			# $t1 = playerY
	beq $t1, 110, collided_g	# If playerY = 110, branch to collided_g, else if no collision
	li $t2, 0			# $t2 = 0
	sw $t2, onSurface		# onSurface = 0	
	jr $ra				# Return to callee
collided_g:
	li $t2, 1			# $t2 = 1
	sw $t2, onSurface		# onSurface = 1
	li $t2, 0			# $t2 = 0
	sw $t2, jumped			# jumped = 0
	jr $ra				# Return to callee
	
dj_collision:
	lw $t1, playerX			# $t1 = playerX
	lw $t2, djX			# $t2 = djX
	beq $t1, $t2, check_djy		# If playerX = djX branch to check_djy
	addi $t1, $t1, 4		# $t1 = playerX + 4
	beq $t1, $t2, check_djy		# If playerX + 4 = djX branch to check_djy
	lw $t1, playerX			# $t1 = playerX
	addi $t2, $t2, 2		# $t2 = djX + 2
	beq $t1, $t2, check_djy		# If playerX = djX + 2 branch to check_djy
	jr $ra 				# Return to callee
check_djy:
	lw $t1, playerY			# $t1 = playerY
	lw $t2, djY			# $t1 = djY
	beq $t1, $t2, picked_dj		# If playerY = djY branch to picked_dj
	addi $t1, $t1, 10		# $t1 = playerY + 10
	beq $t1, $t2, picked_dj		# If playerY + 10 = djY branch to picked_dj
	addi $t2, $t2, 2		# $t2 = djY + 2
	beq $t1, $t2, picked_dj		# If playerY + 10 = djY + 2 branch to picked_dj
	jr $ra 				# Return to callee
picked_dj:
	li $t1, 1			# $t1 = 1
	sw $t1, doubleJump		# doubleJump = 1
	addi, $sp, $sp, -4		# Clear space on stack
	sw $ra, 0($sp)			# Push $ra onto stack
	li $t0, BASE_ADDRESS		# $t0 = base addresss
	lw $t1, black			# $t1 = black
	addi $t4, $t0, 30328		# Position of dj
	sw $t1, 0($t4)			# Erasing dj
	sw $t1, 4($t4)
	sw $t1, 256($t4)
	sw $t1, 260($t4)
	jal clear_character		# Erasing character
	jal draw_character		# Redrawing character
	lw $ra, 0($sp)			# Push $ra off the stack
	addi, $sp, $sp, -4		# Free allocated space on stack
	jr $ra				# Return to callee

	
end:
	li $v0, 10 # terminate the program gracefully
	syscall
