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
silver:		.word 	0xC0C0C0
red:		.word	0xFF0000
wood:		.word	0x966F33
djColor:	.word	0xB200ED

keyboardInput:	.word	0xFFFF0000

gameRunning:	.word 	1
onSurface:	.word 	1
jumped:		.word 	0
doubleJump:	.word 	0
hpPower:	.word	0

groundPos:	.word	30720
djX:		.word	30
djY:		.word	117
hpX:		.word	30
hpY:		.word	67
spike1X:	.word	10
spike1Y:	.word	117
spike2X:	.word	50
spike2Y:	.word 	117
plat1X:		.word	30
plat1Y:		.word 	103
plat2X:		.word	50
plat2Y:		.word 	90
plat3X:		.word	30
plat3Y:		.word 	70
plat4X:		.word	52
plat4Y:		.word 	50
plat4Pos:	.word	13008
plat4D:		.word	1
playerX:	.word	0
playerY:	.word	110
playerHP:	.word 	4

str:		.asciiz	"Test\n"

.eqv BASE_ADDRESS 0x10008000

.globl main
.text

main:
	
start:	
	li $t1, 1		# #t1 = 1
	sw $t1, onSurface	# onSurface = 1
	sw $t1, gameRunning	# gameRunning = 1
	sw $t1, plat4D		# plat4D = 1
	li $t1, 0		# t1 = 0
	sw $t1, jumped		# jumped = 0
	sw $t1, doubleJump	# doubleJump = 0
	sw $t1, hpPower		# hpPower = 0
	sw $t1, playerX		# playerX = 0
	li $t1, 110		# $t1 = 110
	sw $t1, playerY		# playerY = 110
	li $t1, 4		# $t1 = 4
	sw $t1, playerHP	# playerHP = 4
	li $t1, 52		# $t1 = 52
	sw $t1, plat4X		# plat4X = 52
	li $t1, 50		# $t1 = 50
	sw $t1, plat4Y		# plat4X = 50
	li $t1, 13008		# $t1 = 13008
	sw $t1, plat4Pos	# plat4Pos = 13008
	jal clear_screen	# Clear the screen
	jal draw_map		# Draw the map
	jal draw_character	# Draw the character

	# Start of game loop
game_loop:
	li $v0, 32
	li $a0, 40
	syscall
	jal moving_platform	# Move the platform
	jal health		# Make the program sleep for wd
	jal platforms		# Draw all platforms
	jal spikes		# Draw the spikes
	jal keyboard		# Check keyboard inputs
	jal ground_collision	# Check player collision with ground
	jal plat_collisions	# Check for playform collision
	jal dj_collision	# Check for dj powerup collision
	jal hp_collision	# Check for hp powerup collision
	jal gravity		# Check if gravity needs to be applied
	lw $t1, gameRunning	
	bnez $t1, game_loop	# If gameRunning continue loop else jump to End
	j end
		
get_pos:
	sll $a0, $a0, 2
	li $t3, 256
	mult $a1, $t3
	mflo $a1
	add $v0, $a0, $a1
	jr $ra
	
# Function to clear screen
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
	
# Function to draw map
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
	addi $t4, $t0, 30072	# Store position of powerup in $t4	
	lw $t2, djColor		# Store djColor in $t2
	li $t3, 1		# i = 1
draw_dj:sw $t2, 0($t4)		# Draw the gj powerup
	sw $t2, 4($t4)
	sw $t2, 8($t4)
	addi $t4, $t4, 256
	addi $t3, $t3, 1	
	ble $t3, 3, draw_dj	# If i <= 3 branch to draw_dj
hp_powerup:
	addi $t4, $t0, 17272	# Store position of hp powerup in $t4	
	lw $t2, red		# Store red color in $t2
	sw $t2, 4($t4)		# Drawing hp powerup
	sw $t2, 256($t4)		
	sw $t2, 260($t4)
	sw $t2, 264($t4)
	sw $t2, 516($t4)
	jr $ra
spikes:
	li $t0, BASE_ADDRESS
	addi $t4, $t0, 30016	# Store position of spike 1 in $t4
	addi $t5, $t0, 30132	# Store position of spike 2 in $t5
	lw $t2, silver		# Store silver color in $t2
	sw $t2, 4($t4)		# Draw the spikes
	sw $t2, 4($t5)
	sw $t2, 260($t4)
	sw $t2, 260($t5)
	sw $t2, 512($t4)
	sw $t2, 516($t4)
	sw $t2, 520($t4)
	sw $t2, 512($t5)
	sw $t2, 516($t5)
	sw $t2, 520($t5)
	jr $ra			# Return to callee
	
platforms:
	addi $sp, $sp, -4
	sw $ra, 0($sp)		# Push $ra onto stack
	addi $sp, $sp, -4
	li $t1, 26488		# Get platform 1 pos
	sw $t1, 0($sp)		# Push platform 1 pos on stack	
	jal draw_platform	# Draw platform 1
	addi $sp, $sp, -4
	li $t1, 23240		# Get platform 2 pos
	sw $t1, 0($sp)		# Push platform 2 pos on stack
	jal draw_platform	# Draw platform 2
	addi $sp, $sp, -4
	li $t1, 18040		# Get platform 3 pos
	sw $t1, 0($sp)		# Push platform 3 pos on stack
	jal draw_platform	# Draw platform 
	addi $sp, $sp, -4
	lw $t1, plat4Pos	# Get platform 4 pos
	sw $t1, 0($sp)		# Push platform 4 pos on stack
	jal draw_platform	# Draw platform 
	lw $ra, 0($sp)		# Pop $ra off the stack
	addi $sp, $sp, 4
	jr $ra			# Return to callee

health:
	li $t0, BASE_ADDRESS	# Store base address in $t0
	addi $t1, $t0, 648	# Set position of hearts in $t1
	lw $t2, playerHP 	# $t2 = playerHP
	lw $t3, red		# Store red color in $t3
draw_h:	sw $t3, 4($t1)		# Draw the hearts
	sw $t3, 12($t1)
	sw $t3, 256($t1)
	sw $t3, 260($t1)
	sw $t3, 264($t1)
	sw $t3, 268($t1)
	sw $t3, 272($t1)
	sw $t3, 516($t1)
	sw $t3, 520($t1)
	sw $t3, 524($t1)
	sw $t3, 776($t1)
	sub $t2, $t2, 1		# $t2--
	addi $t1, $t1, 24	
	bgtz $t2, draw_h	# If $t2 > 0 branch to draw_h
	jr $ra			# Return to callee
	
# Function to draw platform
draw_platform:
	li $t0, BASE_ADDRESS	# Store base address in $t0
	lw $t1, 0($sp)		# Store platform pos in $t1
	lw $t2, wood		# Store wood color in $t2
	addi $sp, $sp, 4	
	add $t3, $t0, $t1	# Get position to draw platform
	li $t4, 1		# i = 1
draw_p:	sw $t2, 0($t3)		# Draw platform
	addi $t3, $t3, 4
	addi $t4, $t4, 1
	ble $t4, 12, draw_p	# If i <= 12 branch to draw_p
	jr $ra			# Return to callee

# Function to erase platform
clear_platform:
	li $t0, BASE_ADDRESS	# Store base address in $t0
	lw $t1, 0($sp)		# Store platform pos in $t1
	lw $t2, black		# Store black color in $t2
	addi $sp, $sp, 4	
	add $t3, $t0, $t1	# Get position to erase platform
	li $t4, 1		# i = 1
clr_p:	sw $t2, 0($t3)		# Clear platform
	addi $t3, $t3, 4
	addi $t4, $t4, 1
	ble $t4, 12, clr_p	# If i <= 12 branch to clr_p
	jr $ra			# Return to callee
	
# Function to draw character	
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

# Function to erase character
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


# Function to hnadle keyboard input
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
	sub $t5, $t5, 2		# $t5 = playerX--
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
	addi $t5, $t5, 2	# $t5 = playerX++
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
	li $t7, 1		# i = 1
loop_j:	jal clear_character	# Erase the character
	lw $t5, playerY		# $t5 = playerY
	sub $t5, $t5, 1		# $t5 = playerY + 1
	sw $t5, playerY		# playerY = $t5
	jal draw_character	# Redraw character
	addi $t7, $t7, 1	# i++
	ble $t7, 16, loop_j	# If i <= 4 branch to loop_j
	lw $ra, 0($sp)		# Pop $ra off the stack
	addi $sp, $sp, 4	# Free allocated space on the stack
skip_w:
	jr $ra			# Return to callee

# Function that handles double jumping
djump:	lw $t7, jumped		# $t7 = jumped	
	beq $t7, 1, skip_w	# If already jumped then branch to skip_w
	li $t7, 1		# $t7 = 1
	sw $t7, jumped		# jumped = 1
	j jump			# Branch to jump

# Function to handle gravity
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
	
# Function to detect ground collision
ground_collision:
	lw $t1, playerY			# $t1 = playerY
	beq $t1, 110, collision		# If playerY = 110, branch to collision, else if no collision
	li $t2, 0			# $t2 = 0
	sw $t2, onSurface		# onSurface = 0	
	jr $ra				# Return to callee


# Function to detect platform collision
plat_collisions:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	lw $t1, plat1X
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, plat1Y
	sw $t1, 0($sp)
	jal platform_collision
	addi $sp, $sp, -4
	lw $t1, plat2X
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, plat2Y
	sw $t1, 0($sp)
	jal platform_collision
	addi $sp, $sp, -4
	lw $t1, plat3X
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, plat3Y
	sw $t1, 0($sp)
	jal platform_collision
	addi $sp, $sp, -4
	lw $t1, plat4X
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, plat4Y
	sw $t1, 0($sp)
	jal platform_collision
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
platform_collision:
	lw $t1, playerX
	lw $t2, playerY
	lw $t4, 0($sp)
	lw $t3, 4($sp)
	addi $sp, $sp, 8
	addi $t2, $t2, 10
	beq $t2, $t4, check_px
	jr $ra
check_px:
	add $t4, $t1, 4 
	blt $t4, $t3, skip_px
	addi $t3, $t3, 12
	bgt $t1, $t3, skip_px
	j collision
skip_px:
	jr $ra
	
# Function to move the platforms
moving_platform:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	lw $t1, plat4Pos
	sw $t1, 0($sp)
	jal clear_platform
	lw $t2, plat4X
	lw $t3, plat4D
	lw $t4, plat4Pos
	beqz $t3, plat_right
plat_left:
	beqz $t2, plat_right
	addi $t2, $t2, -1
	addi $t4, $t4, -4
	li $t5, 1
	sw $t2, plat4X
	sw $t4, plat4Pos
	sw $t5, plat4D
	j plat_d
plat_right:
	beq $t2, 52, plat_left
	addi $t2, $t2, 1
	addi $t4, $t4, 4
	li $t5, 0
	sw $t2, plat4X
	sw $t4, plat4Pos
	sw $t5, plat4D
plat_d:	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

# Function to handle platform collision					
collision:
	li $t2, 1			# $t2 = 1
	sw $t2, onSurface		# onSurface = 1
	li $t2, 0			# $t2 = 0
	sw $t2, jumped			# jumped = 0
	jr $ra				# Return to callee
	
# Function to hnadle picking up dj powerup
dj_collision:
	lw $t1, doubleJump		# $t1 = doubleJump
	beq $t1, 1, ret_dj		# If powerup already picked up branch to skip_dj
	lw $t1, playerX			# $t1 = playerX
	lw $t2, djX			# $t2 = djX
	beq $t1, $t2, check_djy		# If playerX = djX branch to check_djy
	addi $t1, $t1, 4		# $t1 = playerX + 4
	beq $t1, $t2, check_djy		# If playerX + 4 = djX branch to check_djy
	lw $t1, playerX			# $t1 = playerX
	addi $t2, $t2, 3		# $t2 = djX + 3
	beq $t1, $t2, check_djy		# If playerX = djX + 3 branch to check_djy
	jr $ra 				# Return to callee
check_djy:
	lw $t1, playerY			# $t1 = playerY
	lw $t2, djY			# $t1 = djY
	beq $t1, $t2, picked_dj		# If playerY = djY branch to picked_dj
	addi $t1, $t1, 10		# $t1 = playerY + 10
	beq $t1, $t2, picked_dj		# If playerY + 10 = djY branch to picked_dj
	addi $t2, $t2, 3		# $t2 = djY + 3
	beq $t1, $t2, picked_dj		# If playerY + 10 = djY + 3 branch to picked_dj
	jr $ra 				# Return to callee
picked_dj:
	li $t1, 1			# $t1 = 1
	sw $t1, doubleJump		# doubleJump = 1
	addi, $sp, $sp, -4		# Clear space on stack
	sw $ra, 0($sp)			# Push $ra onto stack
	li $t0, BASE_ADDRESS		# $t0 = base addresss
	lw $t1, black			# $t1 = black
	addi $t4, $t0, 30072		# Position of dj
	li $t5, 1			# i = 1
clr_dj:	sw $t1, 0($t4)			# Erasing dj
	sw $t1, 4($t4)
	sw $t1, 8($t4)
	addi $t5, $t5, 1
	addi $t4, $t4, 256
	ble $t5, 3, clr_dj		# If i <= 3 branch to clr_dj
	jal clear_character		# Erasing character
	jal draw_character		# Redrawing character
	lw $ra, 0($sp)			# Push $ra off the stack
	addi, $sp, $sp, -4		# Free allocated space on stack
ret_dj:	jr $ra				# Return to callee

# Function to hnadle picking up hp powerup
hp_collision:
	lw $t1, hpPower			# $t1 = hpPowe
	beq $t1, 1, ret_hp		# If powerup already picked up branch to ret_hp
	lw $t1, playerX			# $t1 = playerX
	lw $t2, hpX			# $t2 = hpX
	beq $t1, $t2, check_hpy		# If playerX = hpX branch to check_hpy
	addi $t1, $t1, 4		# $t1 = playerX + 4
	beq $t1, $t2, check_hpy		# If playerX + 4 = hpX branch to check_hpy
	lw $t1, playerX			# $t1 = playerX
	addi $t2, $t2, 3		# $t2 = hpX + 3
	beq $t1, $t2, check_hpy		# If playerX = hpX + 3 branch to check_hpy
	jr $ra 				# Return to callee
check_hpy:
	lw $t1, playerY			# $t1 = playerY
	lw $t2, hpY			# $t1 = djY
	beq $t1, $t2, picked_hp		# If playerY = hpY branch to picked_dj
	addi $t1, $t1, 10		# $t1 = playerY + 10
	beq $t1, $t2, picked_hp		# If playerY + 10 = hpY branch to picked_dj
	addi $t2, $t2, 3		# $t2 = hpY + 3
	beq $t1, $t2, picked_hp		# If playerY + 10 = hpY + 3 branch to picked_dj
	jr $ra 				# Return to callee
picked_hp:
	li $t1, 1			# $t1 = 1
	sw $t1, hpPower			# hpPower = 1
	lw $t1, playerHP		# $t1 = playerHP
	addi $t1, $t1, 1		# $t1++
	sw $t1, playerHP		# playerHP++
	li $t0, BASE_ADDRESS		# $t0 = base addresss
	lw $t2, black			# $t1 = black
	addi $t4, $t0, 17272		# Position of hp
	sw $t2, 4($t4)			# Erasing hp powerup
	sw $t2, 256($t4)		
	sw $t2, 260($t4)
	sw $t2, 264($t4)
	sw $t2, 516($t4)
ret_hp:	jr $ra				# Return to callee


end:
	li $v0, 10 # terminate the program gracefully
	syscall
