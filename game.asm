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
# - Milestone 1, 2, 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health/Score
# 2. Fail Condition
# 3. Win Condition
# 4. Moving platforms
# 5. Pick-up effects
# 6. Double Jump
#
# Link to video demonstration for final submission:
# - https://youtu.be/fKvuaO-IAdo
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, https://github.com/MuhannadJam/Assembly-Platform-Game
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
groundColor:	.word	0x7CFC00
fireColor:	.word	0xE25822
playerFace:	.word 	0xECBCB4
playerBody:	.word	0x5579C6
black:		.word	0x000000
white:		.word	0xFFFFFF
silver:		.word 	0xC0C0C0
gold:		.word	0xD4AF37
red:		.word	0xFF0000
shieldColor:	.word	0x1E2F97
wood:		.word	0x966F33
djColor:	.word	0xB200ED

keyboardInput:	.word	0xFFFF0000

gameRunning:	.word 	1
onSurface:	.word 	1
jumped:		.word 	0
doubleJump:	.word 	0
hpPower:	.word	0
shieldOn:	.word	0
goldRing:	.word	0
shieldTimer:	.word	200
takeDamage:	.word 	1
canJump:	.word	1

groundPos:	.word	30720
djX:		.word	30
djY:		.word	117
hpX:		.word	30
hpY:		.word	68
shieldX:	.word	5	
shieldY:	.word	12
ringX:		.word	61
ringY:		.word	20
spike1X:	.word	16
spike1Y:	.word	117
spike2X:	.word	45
spike2Y:	.word 	117
plat1X:		.word	30
plat1Y:		.word 	103
plat2X:		.word	50
plat2Y:		.word 	90
plat3X:		.word	30
plat3Y:		.word 	71
plat4X:		.word	52
plat4Y:		.word 	50
plat5X:		.word	0
plat5Y:		.word 	35
plat6X:		.word	5
plat6Y:		.word 	15
fireX:		.word	30
fireY:		.word 	23
doorX:		.word	59
doorY:		.word	110
plat4Pos:	.word	13008
plat5Pos:	.word	8960
plat4D:		.word	1
plat5D:		.word	0
playerX:	.word	0
playerY:	.word	110
playerHP:	.word 	100

.eqv BASE_ADDRESS 0x10008000

.globl main
.text

main:
	
start:	
	li $t1, 1		# #t1 = 1
	sw $t1, onSurface	# onSurface = 1
	sw $t1, gameRunning	# gameRunning = 1
	sw $t1, plat4D		# plat4D = 1
	sw $t1, takeDamage	# takeDamage = 1
	sw $t1, canJump		# canJump = 1
	li $t1, 0		# t1 = 0
	sw $t1, jumped		# jumped = 0
	sw $t1, doubleJump	# doubleJump = 0
	sw $t1, hpPower		# hpPower = 0
	sw $t1, shieldOn	# shieldOn = 0
	sw $t1, goldRing	# goldRing = 0
	sw $t1, playerX		# playerX = 0
	sw $t1, plat4D		# plat5D = 0
	li $t1, 110		# $t1 = 110
	sw $t1, playerY		# playerY = 110
	li $t1, 100		# $t1 = 100
	sw $t1, playerHP	# playerHP = 100
	li $t1, 200		# $t1 = 200
	sw $t1, shieldTimer	# shieldTimer = 200
	li $t1, 52		# $t1 = 52
	sw $t1, plat4X		# plat4X = 52
	li $t1, 13008		# $t1 = 13008
	sw $t1, plat4Pos	# plat4Pos = 13008
	li $t1, 0		# $t1 = 0
	sw $t1, plat5X		# plat5X = 52
	li $t1, 8960		# $t1 = 10240
	sw $t1, plat5Pos	# plat4Pos = 10240
	jal clear_screen	# Clear the screen
	jal draw_map		# Draw the map
	jal draw_character	# Draw the character

	# Start of game loop
game_loop:
	li $v0, 32
	li $a0, 40
	syscall
	jal moving_platform	# Move the platform
	jal platforms		# Draw all platforms
	jal spikes		# Draw the spikes
	jal draw_fire		# Draw fire platform
	jal keyboard		# Check keyboard inputs
	jal check_shield	# Check if character has shield
	jal ground_collision	# Check player collision with ground
	jal fire_collision	# Check for fire ground collision
	jal plat_collisions	# Check for playform collision
	jal object_collisions	# Check for object collisions
	jal escape		# Check if character has won
	jal health		# Draw the player hearts
	jal gravity		# Check if gravity needs to be applied
	lw $t1, gameRunning	
	bnez $t1, game_loop	# If gameRunning continue loop else jump to End
	j end
		
get_pos:
	sll $a0, $a0, 2		# $a0 = X *4
	li $t3, 256		
	mult $a1, $t3		
	mflo $a1		# $a1 = Y * 256	
	add $v0, $a0, $a1	# pos = (X * 4) + (Y  * 256)
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
draw_dj:sw $t2, 0($t4)		# Draw the dj powerup
	sw $t2, 4($t4)
	sw $t2, 8($t4)
	addi $t4, $t4, 256
	addi $t3, $t3, 1	
	ble $t3, 3, draw_dj	# If i <= 3 branch to draw_dj
hp_powerup:
	addi $t4, $t0, 17528	# Store position of hp powerup in $t4	
	lw $t2, red		# Store red color in $t2
	sw $t2, 4($t4)		# Drawing hp powerup
	sw $t2, 256($t4)		
	sw $t2, 260($t4)
	sw $t2, 264($t4)
	sw $t2, 516($t4)
shield_powerup:		
	addi $t4, $t0, 3092	# Store position of powerup in $t4	
	lw $t2, shieldColor	# Store shield color in $t2
	sw $t2, 4($t4)		# Drawing hp powerup
	sw $t2, 256($t4)		
	sw $t2, 260($t4)
	sw $t2, 264($t4)
	sw $t2, 516($t4)
golden_ring:	
	addi $t4, $t0, 5364	# Store position of ring in $t4	
	lw $t2, gold		# Store gold color in $t2
	li $t3, 1		# i = 1
draw_ring:
	sw $t2, 0($t4)		# Draw the ring
	sw $t2, 4($t4)
	sw $t2, 8($t4)
	addi $t4, $t4, 256
	addi $t3, $t3, 1	
	ble $t3, 3, draw_ring	# If i <= 3 branch to draw_dj
	addi $t4, $t4, -512
	lw $t2, black
	sw $t2, 4($t4)
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
	li $t1, 18296		# Get platform 3 pos
	sw $t1, 0($sp)		# Push platform 3 pos on stack
	jal draw_platform	# Draw platform 
	addi $sp, $sp, -4
	lw $t1, plat4Pos	# Get platform 4 pos
	sw $t1, 0($sp)		# Push platform 4 pos on stack
	jal draw_platform	# Draw platform 
	addi $sp, $sp, -4
	lw $t1, plat5Pos	# Get platform 5 pos
	sw $t1, 0($sp)		# Push platform 5 pos on stack
	jal draw_platform	# Draw platform 
	addi $sp, $sp, -4
	li $t1, 3860		# Get platform 6 pos
	sw $t1, 0($sp)		# Push platform 6 pos on stack	
	jal draw_platform	# Draw platform 6
	lw $ra, 0($sp)		# Pop $ra off the stack
	addi $sp, $sp, 4
	jr $ra			# Return to callee

# Drawing the fire platform	
draw_fire:
	li $t0, BASE_ADDRESS
	addi $t4, $t0, 6008	# Get fire ground position
	lw $t2, fireColor	# Set $t2 to fire color
	li $t5, 1		# i = 1
fire_ground:
	sw $t2, 0($t4) 		# Drawing the ground
	addi $t4, $t4, 4
	addi $t5, $t5, 1
	ble $t5, 34, fire_ground	# i <= 34, branch to ground
	jr $ra

# Draw the escape door
escape_door:
	li $t0, BASE_ADDRESS
	addi $t4, $t0, 28396	# Get the door position
	lw $t2, wood		# Set $t2 to wood color
	li $t5, 1		# i = 1
draw_door:
	sw $t2, 0($t4) 		# Drawing the door
	sw $t2, 4($t4) 
	sw $t2, 8($t4) 
	sw $t2, 12($t4)
	sw $t2, 16($t4) 
	addi $t4, $t4, 256
	addi $t5, $t5, 1
	ble $t5, 10, draw_door	# i <= 10, branch to draw_door
	addi $t4, $t4, -1536
	lw $t2, gold		# Set $t3 to gold color
	sw $t2, 4($t4) 		
	sw $t2, 8($t4) 
	sw $t2, 260($t4) 		
	sw $t2, 264($t4) 
	jr $ra
	
# Check if player can escape
escape:
	lw $t1, goldRing	# $t1 = goldRing
	beqz $t1, no_escape	# If player does not have ring branch to no_escape
	lw $t1, playerY		# $t1 = playerY
	addi $t1, $t1, 10	# $t1 = playerY + 10
	lw $t2, doorY		# $t2 = doorY
	bgt $t2, $t1, no_escape	# if doorY > playerY + 10 branch to no_escape
	lw $t1, playerX		# $t1 = playerX
	lw $t2, doorX		# $t2 = doorX
	addi $t1, $t1, 4	# $t1 = playerX + 4		
	blt $t1, $t2, no_escape	# If playerX + 4 < doorX branch to no_escape
	j game_won	
no_escape:
	jr $ra
	
health:
	li $t0, BASE_ADDRESS	# Store base address in $t0
	addi $t1, $t0, 648	# Set position of hearts in $t1
	lw $t2, playerHP 	# $t2 = playerHP
	li $t3, 25
	div $t2, $t3
	mflo $t2
	blez $t2, game_over
	lw $t4, shieldOn	# $t4 = shieldOn
	lw $t5, shieldTimer	# $t5 = shieldTimer
	lw $t3, red		# Store red color in $t3
	beqz $t4, draw_h	# If shield not on then branch to draw_h
	beqz $t5, draw_h	# If shieldTimer = 0 then branch to draw_h
	lw $t3, shieldColor	# Store shield color in $t3			
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

refresh_heart:
	li $t0, BASE_ADDRESS	# Store base address in $t0
	addi $t1, $t0, 648	# Set position of hearts in $t1
	lw $t2, black		# Set $t2 to color black
	li $t3, 1		# i = 1
ref_h:	sw $t2, 0($t1)		# Erase hearts
	sw $t2, 256($t1)
	sw $t2, 512($t1)
	sw $t2, 768($t1)
	addi $t3, $t3, 1	# i++
	addi $t1, $t1, 4
	ble $t3, 30, ref_h	# If i <= 30 branch to ref_h
	jr $ra
	
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
	beqz $t1, goldc		# If character doesnt have double jump branch to goldc
	lw $t3,	djColor		# Storing the double jump color in $t3
goldc:	lw $t1, goldRing	# $t1 = goldRing
	beqz $t1, drawb		# If character doesnt have ring branch to drawb
	lw $t3,	gold		# Storing the gold color in $t3
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
	lw $t1, gameRunning
	lw $t2, 4($t9)			# Store input ket in $t2
	beq $t2, 0x70, start		# If input 'p' branch to restart
	beq $t2, 0x71, end		# If input 'q' branch to end
	beqz $t1, no_key
	beq $t2, 0x61, move_left	# If input 'a' branch to move_left
	beq $t2, 0x64, move_right	# If input 'd' branch to move_right
	beq $t2, 0x77, move_up		# If input 'w' branch to move_up

no_key:	jr $ra				# Return to callee
	
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
	lw $t7, canJump		# $t7 = canJump
	beqz $t7, no_j
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
	beqz $t5, skip_w
	addi $t7, $t7, 1	# i++
	ble $t7, 16, loop_j	# If i <= 4 branch to loop_j
skip_w:	lw $ra, 0($sp)		# Pop $ra off the stack
	addi $sp, $sp, 4	# Free allocated space on the stack
no_j:	jr $ra			# Return to callee

# Function that handles double jumping
djump:	lw $t7, jumped		# $t7 = jumped	
	beq $t7, 1, no_j	# If already jumped then branch to no_j
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
	
# Function to handle shield
check_shield:
	lw $t1, shieldOn	# Checking shield values
	lw $t2, shieldTimer
	beqz $t1, no_shield
	beqz $t2, no_shield
	li $t1, 0
	sw $t1, takeDamage
	addi $t2, $t2, -1
	sw $t2, shieldTimer
	li $t0, BASE_ADDRESS
	li $t3, 25
	lw $t4, black
	addi $t5, $t0, 1928
clear_timer:			# Erasing shield timer
	sw $t4, 0($t5)
	addi $t3, $t3, -1
	addi $t5, $t5, 4
	bgtz $t3, clear_timer
	srl $t2, $t2, 3
	addi $t3, $t0, 1928
	lw $t4, shieldColor
shield_timer:			# Drawing shield
	sw $t4, 0($t3)
	addi $t2, $t2, -1
	addi $t3, $t3, 4
	bgtz $t2, shield_timer
	jr $ra
no_shield:			# No shield
	li $t1, 1
	sw $t1, takeDamage
	lw $t4, black
	addi $t5, $t0, 1928
	sw $t4, 0($t5)
	jr $ra
	
# Function to detect ground collision
ground_collision:
	lw $t1, playerY			# $t1 = playerY
	beq $t1, 110, collision		# If playerY = 110, branch to collision, else if no collision
	li $t2, 0			# $t2 = 0
	sw $t2, onSurface		# onSurface = 0	
	jr $ra				# Return to callee

# Function to detect fire collision
fire_collision:
	lw $t1, playerX
	lw $t2, playerY
	lw $t3, fireX
	lw $t4, fireY
	addi $t2, $t2, 10
	beq $t2, $t4, check_fx
	jr $ra
check_fx:
	add $t4, $t1, 4 
	blt $t4, $t3, skip_fx
	addi $t3, $t3, 34
	bgt $t1, $t3, skip_fx
collision_fx:
	li $t2, 1			# $t2 = 1
	sw $t2, onSurface		# onSurface = 1
	li $t2, 0			# $t2 = 0
	sw $t2, canJump			# canJump = 0
	lw $t2, takeDamage		# $t2 = takeDamage
	beqz $t2, ret_f			# If cannot take damage branch to ret_f
	lw $t2, playerHP		# $t2 = playerHP
	addi $t2, $t2, -4		# $t2 = $t2 - 4
	sw $t2, playerHP		# playerHP - 4
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal refresh_heart
	lw $ra, 0($sp)
	addi $sp, $sp, 4
ret_f:	jr $ra				# Return to callee
skip_fx:
	li $t2, 0			# $t2 = 0
	sw $t2, onSurface		# onSurface = 0
	li $t2, 1			# $t2 = 1
	sw $t2, canJump			# canJump = 1
	jr $ra
	
	
# Function to detect platform collision
plat_collisions:
	addi $sp, $sp, -4	
	sw $ra, 0($sp)		# Push $ra onto stack
	addi $sp, $sp, -4
	lw $t1, plat1X		
	sw $t1, 0($sp)		# Push plat1X on the stack
	addi $sp, $sp, -4
	lw $t1, plat1Y
	sw $t1, 0($sp)		# Push plat1Y on the stack
	jal platform_collision	# Check for platform 1 collision
	addi $sp, $sp, -4	
	lw $t1, plat2X
	sw $t1, 0($sp)		# Push plat2X on the stack
	addi $sp, $sp, -4
	lw $t1, plat2Y		
	sw $t1, 0($sp)		# Push plat2Y on the stack
	jal platform_collision	# Check for platform 2 collision
	addi $sp, $sp, -4
	lw $t1, plat3X		
	sw $t1, 0($sp)		# Push plat3X on the stack
	addi $sp, $sp, -4
	lw $t1, plat3Y
	sw $t1, 0($sp)		# Push plat3Y on the stack
	jal platform_collision	# Check for platform 3 collision
	addi $sp, $sp, -4
	lw $t1, plat4X		
	sw $t1, 0($sp)		# Push plat4X on the stack
	addi $sp, $sp, -4
	lw $t1, plat4Y
	sw $t1, 0($sp)		# Push plat4Y on the stack
	jal platform_collision	# Check for platform 4 collision
	addi $sp, $sp, -4
	lw $t1, plat5X		
	sw $t1, 0($sp)		# Push plat5X on the stack
	addi $sp, $sp, -4
	lw $t1, plat5Y
	sw $t1, 0($sp)		# Push plat5Y on the stack
	jal platform_collision	# Check for platform 5 collision
	addi $sp, $sp, -4
	lw $t1, plat6X		
	sw $t1, 0($sp)		# Push plat6X on the stack
	addi $sp, $sp, -4
	lw $t1, plat6Y
	sw $t1, 0($sp)		# Push plat6Y on the stack
	jal platform_collision	# Check for platform 5 collision
	lw $ra, 0($sp)		# Pop $ra off the stack
	addi $sp, $sp, 4
	jr $ra			# Return to callee
	
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
plat4:	addi $sp, $sp, -4
	lw $t1, plat4Pos
	sw $t1, 0($sp)
	jal clear_platform
	lw $t2, plat4X
	lw $t3, plat4D
	lw $t4, plat4Pos
	beqz $t3, plat4_right
plat4_left:
	beqz $t2, plat4_right
	addi $t2, $t2, -1
	addi $t4, $t4, -4
	li $t5, 1
	sw $t2, plat4X
	sw $t4, plat4Pos
	sw $t5, plat4D
	j plat5
plat4_right:
	beq $t2, 52, plat4_left
	addi $t2, $t2, 1
	addi $t4, $t4, 4
	li $t5, 0
	sw $t2, plat4X
	sw $t4, plat4Pos
	sw $t5, plat4D
plat5:	addi $sp, $sp, -4
	lw $t1, plat5Pos
	sw $t1, 0($sp)
	jal clear_platform
	lw $t2, plat5X
	lw $t3, plat5D
	lw $t4, plat5Pos
	beqz $t3, plat5_right
plat5_left:
	beqz $t2, plat5_right
	addi $t2, $t2, -1
	addi $t4, $t4, -4
	li $t5, 1
	sw $t2, plat5X
	sw $t4, plat5Pos
	sw $t5, plat5D
	j plat_d
plat5_right:
	beq $t2, 52, plat5_left
	addi $t2, $t2, 1
	addi $t4, $t4, 4
	li $t5, 0
	sw $t2, plat5X
	sw $t4, plat5Pos
	sw $t5, plat5D
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

# Function to handle object collisions:
object_collisions:
	addi $sp, $sp, -4
	sw $ra, 0($sp)			# Push $ra onto stack	
dj:	lw $t1, doubleJump		# $t1 = doubleJump
	beq $t1, 1, hp			# If doubleJump = 1 branch to hp
	lw $t1, djX			
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push djX on the stack
	lw $t1, djY
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push djY on the stack
	jal check_collision
	lw $t1, 0($sp)			# Pop collision off the stack
	addi $sp, $sp, 4
	beqz $t1, hp			# If no dj collision branch to hp
picked_dj:
	li $t1, 1			# $t1 = 1
	sw $t1, doubleJump		# doubleJump = 1
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
hp:	lw $t1, hpPower			# $t1 = hpPower
	beq $t1, 1, shield		# If hpPower = 1 branch to shield
	lw $t1, hpX
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push hpX on the stack
	lw $t1, hpY
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push hpY on the stack
	jal check_collision
	lw $t1, 0($sp)			# Pop collision off the stack
	addi $sp, $sp, 4
	beqz $t1, shield		# If no collision branch to shield
picked_hp:
	li $t1, 1			# $t1 = 1
	sw $t1, hpPower			# hpPower = 1
	lw $t1, playerHP		# $t1 = playerHP
	addi $t1, $t1, 25		# $t1 = $t1 + 25
	sw $t1, playerHP		# playerHP + 25
	li $t0, BASE_ADDRESS		# $t0 = base addresss
	lw $t2, black			# $t1 = black
	addi $t4, $t0, 17528		# Position of hp
	sw $t2, 4($t4)			# Erasing hp powerup
	sw $t2, 256($t4)		
	sw $t2, 260($t4)
	sw $t2, 264($t4)
	sw $t2, 516($t4)
	jal refresh_heart
shield: lw $t1, shieldOn		# $t1 = shieldOn
	beq $t1, 1, ring		# If shieldOn = 1 branch to spike1
	lw $t1, shieldX
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push shieldX on the stack
	lw $t1, shieldY
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push shieldY on the stack
	jal check_collision
	lw $t1, 0($sp)			# Pop collision off the stack
	addi $sp, $sp, 4
	beqz $t1, ring		# If no collision branch to shield
picked_shield:
	li $t1, 1			# $t1 = 1
	sw $t1, shieldOn		# shieldOn = 1
	li $t0, BASE_ADDRESS		# $t0 = base addresss
	lw $t1, black			# $t1 = black
	addi $t4, $t0, 3092		# Position of shield
	li $t5, 1			# i = 1
clr_shield:	
	sw $t1, 0($t4)			# Erasing shield
	sw $t1, 4($t4)
	sw $t1, 8($t4)
	addi $t5, $t5, 1
	addi $t4, $t4, 256
	ble $t5, 3, clr_dj		# If i <= 3 branch to clr_shield
ring:	lw $t1, goldRing		# $t1 = goldRing
	beq $t1, 1, spike1		# If goldRing = 1 branch to spike1
	lw $t1, ringX			
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push ringX on the stack
	lw $t1, ringY
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push ringY on the stack
	jal check_collision
	lw $t1, 0($sp)			# Pop collision off the stack
	addi $sp, $sp, 4
	beqz $t1, spike1		# If no ring collision branch to spike1
picked_ring:
	li $t1, 1			# $t1 = 1
	sw $t1, goldRing		# goldRing = 1
	li $t0, BASE_ADDRESS		# $t0 = base addresss
	lw $t1, black			# $t1 = black
	addi $t4, $t0, 5364		# Position of ring
	li $t5, 1			# i = 1
clr_ring:	
	sw $t1, 0($t4)			# Erasing ring
	sw $t1, 4($t4)
	sw $t1, 8($t4)
	addi $t5, $t5, 1
	addi $t4, $t4, 256
	ble $t5, 3, clr_ring		# If i <= 3 branch to clr_ring
	jal clear_character		# Erasing character
	jal draw_character		# Redrawing character
	jal escape_door			# Draw the escape door
spike1: lw $t1, takeDamage		# $t1 = takeDamage
	beqz $t1, obj_r			# If takeDamage = 0 branch to obj_r
	lw $t1, spike1X
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push spike1X on the stack
	lw $t1, spike1Y
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push spike1Y on the stack
	jal check_collision
	lw $t1, 0($sp)			# Pop collision off the stack
	addi $sp, $sp, 4
	beqz $t1, spike2		# If no collision branch to spike2
spike1_c:
	lw $t1, playerHP		# $t1 = playerHP
	addi $t1, $t1, -1		# $t1--
	sw $t1, playerHP		# playerHP--
	jal refresh_heart
spike2: lw $t1, takeDamage		# $t1 = takeDamage
	beqz $t1, obj_r			# If takeDamage = 0 branch to obj_r
	lw $t1, spike2X
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push spike2X on the stack
	lw $t1, spike1Y
	addi $sp, $sp, -4
	sw $t1, 0($sp)			# Push spike2Y on the stack
	jal check_collision
	lw $t1, 0($sp)			# Pop collision off the stack
	addi $sp, $sp, 4
	beqz $t1, obj_r			# If no collision branch to obj_r
spike2_c:
	lw $t1, playerHP		# $t1 = playerHP
	addi $t1, $t1, -1		# $t1--
	sw $t1, playerHP		# playerHP--
	jal refresh_heart
obj_r:	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
# Function to hnadle picking up dj powerup
check_collision:
	lw $t3, 0($sp)			# $t3 = Y
	lw $t2, 4($sp)			# $t2 = X
	addi $sp, $sp, 4		
	lw $t1, playerY			# $t1 = playerY
	blt $t3, $t1, skip_oc		# If Y < playerY branch to skip_oc
	addi $t1, $t1, 10		# $t1 = playerY + 10
	bgt $t3, $t1, skip_oc		# If Y > playerY + 10 branch to skip_oc
check_ojx:
	lw $t1, playerX			# $t1 = playerX
	beq $t1, $t2, collision_oj	# If playerX = X branch to collision_oj
	addi $t1, $t1, 3		# $t1 = playerX + 4	
	bgt $t2, $t1, skip_oc		# If X > playerX + 4 branch to skip_oc
	lw $t1, playerX			# $t1 = playerX 
	addi $t2, $t2, 3		# $t2 = X + 3
	blt $t2, $t1, skip_oc		# If X + 3 < playerX
collision_oj:
	li $t1, 1
	sw $t1, 0($sp)
	jr $ra				# Return to callee
skip_oc:
	li $t1, 0
	sw $t1, 0($sp)
	jr $ra 				# Return to callee

# These functions are to draw letters on screen
a:
	sw $t3, 4($t2)		
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 256($t2)
	sw $t3, 272($t2)
	sw $t3, 512($t2)
	sw $t3, 528($t2)
	sw $t3, 768($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 780($t2)
	sw $t3, 784($t2)
	sw $t3, 1024($t2)
	sw $t3, 1040($t2)
	sw $t3, 1280($t2)
	sw $t3, 1296($t2)
	sw $t3, 1536($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 24
	jr $ra

c:
	sw $t3, 4($t2)		
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 16($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 1024($t2)
	sw $t3, 1280($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1548($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 24
	jr $ra
	
e:
	sw $t3, 0($t2)		
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 780($t2)
	sw $t3, 1024($t2)
	sw $t3, 1280($t2)
	sw $t3, 1536($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1548($t2)
	addi $t2, $t2, 20
	jr $ra
	
g:
	sw $t3, 4($t2)		
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 16($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 1024($t2)
	sw $t3, 1036($t2)
	sw $t3, 1040($t2)
	sw $t3, 1280($t2)
	sw $t3, 1296($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1548($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 24
	jr $ra
	
m:
	sw $t3, 4($t2)		
	sw $t3, 8($t2)
	sw $t3, 16($t2)
	sw $t3, 20($t2)
	sw $t3, 256($t2)
	sw $t3, 268($t2)
	sw $t3, 280($t2)
	sw $t3, 512($t2)
	sw $t3, 524($t2)
	sw $t3, 536($t2)
	sw $t3, 768($t2)
	sw $t3, 780($t2)
	sw $t3, 792($t2)
	sw $t3, 1024($t2)
	sw $t3, 1036($t2)
	sw $t3, 1048($t2)
	sw $t3, 1280($t2)
	sw $t3, 1304($t2)
	sw $t3, 1536($t2)
	sw $t3, 1560($t2)
	addi $t2, $t2, 32
	jr $ra
	
n:	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 16($t2)
	sw $t3, 256($t2)
	sw $t3, 276($t2)
	sw $t3, 512($t2)
	sw $t3, 532($t2)
	sw $t3, 768($t2)
	sw $t3, 788($t2)
	sw $t3, 1024($t2)
	sw $t3, 1044($t2)
	sw $t3, 1280($t2)
	sw $t3, 1300($t2)
	sw $t3, 1536($t2)
	sw $t3, 1556($t2)
	addi $t2, $t2, 28
	jr $ra
	jr $ra

o:
	sw $t3, 4($t2)		
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 16($t2)
	sw $t3, 256($t2)
	sw $t3, 276($t2)
	sw $t3, 512($t2)
	sw $t3, 532($t2)
	sw $t3, 768($t2)
	sw $t3, 788($t2)
	sw $t3, 1024($t2)
	sw $t3, 1044($t2)
	sw $t3, 1280($t2)
	sw $t3, 1300($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1548($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 28
	jr $ra

r:
	sw $t3, 0($t2)		
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 256($t2)
	sw $t3, 272($t2)
	sw $t3, 512($t2)
	sw $t3, 528($t2)
	sw $t3, 768($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 780($t2)
	sw $t3, 1024($t2)
	sw $t3, 1032($t2)
	sw $t3, 1280($t2)
	sw $t3, 1292($t2)
	sw $t3, 1536($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 24
	jr $ra

s:	sw $t3, 0($t2)		
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 16($t2)		
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 780($t2)
	sw $t3, 784($t2)
	sw $t3, 1040($t2)
	sw $t3, 1296($t2)
	sw $t3, 1536($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1548($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 24
	jr $ra
	
t:	sw $t3, 0($t2)		
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 12($t2)
	sw $t3, 16($t2)
	sw $t3, 264($t2)
	sw $t3, 520($t2)
	sw $t3, 776($t2)
	sw $t3, 1032($t2)
	sw $t3, 1288($t2)
	sw $t3, 1544($t2)
	addi $t2, $t2, 24
	jr $ra
	
u:	sw $t3, 0($t2)
	sw $t3, 20($t2)
	sw $t3, 256($t2)
	sw $t3, 276($t2)
	sw $t3, 512($t2)
	sw $t3, 532($t2)
	sw $t3, 768($t2)
	sw $t3, 788($t2)
	sw $t3, 1024($t2)
	sw $t3, 1044($t2)
	sw $t3, 1280($t2)
	sw $t3, 1300($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1548($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 28
	jr $ra
			
v:
	sw $t3, 0($t2)		
	sw $t3, 16($t2)
	sw $t3, 256($t2)
	sw $t3, 272($t2)
	sw $t3, 512($t2)
	sw $t3, 528($t2)
	sw $t3, 768($t2)
	sw $t3, 784($t2)
	sw $t3, 1024($t2)
	sw $t3, 1040($t2)
	sw $t3, 1284($t2)
	sw $t3, 1292($t2)
	sw $t3, 1544($t2)
	addi $t2, $t2, 24
	jr $ra

w:	sw $t3, 0($t2)		
	sw $t3, 24($t2)
	sw $t3, 256($t2)
	sw $t3, 280($t2)
	sw $t3, 512($t2)
	sw $t3, 524($t2)
	sw $t3, 536($t2)
	sw $t3, 768($t2)
	sw $t3, 780($t2)
	sw $t3, 792($t2)
	sw $t3, 1024($t2)
	sw $t3, 1036($t2)
	sw $t3, 1048($t2)
	sw $t3, 1280($t2)
	sw $t3, 1292($t2)
	sw $t3, 1304($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1552($t2)
	sw $t3, 1556($t2)
	addi $t2, $t2, 32
	jr $ra
	
y:	sw $t3, 0($t2)
	sw $t3, 16($t2)
	sw $t3, 256($t2)
	sw $t3, 272($t2)
	sw $t3, 512($t2)
	sw $t3, 528($t2)
	sw $t3, 768($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 780($t2)
	sw $t3, 784($t2)
	sw $t3, 1040($t2)
	sw $t3, 1280($t2)
	sw $t3, 1296($t2)
	sw $t3, 1536($t2)
	sw $t3, 1540($t2)
	sw $t3, 1544($t2)
	sw $t3, 1548($t2)
	sw $t3, 1552($t2)
	addi $t2, $t2, 24
	jr $ra

exclamation:
	sw $t3, 0($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 1024($t2)
	sw $t3, 1536($t2)
	addi, $t2, $t2, 8
	jr $ra
	
	
game_over:
	jal clear_screen
	li $t1, 0
	sw $t1, gameRunning
	li $t0, BASE_ADDRESS
	addi $t2, $t0, 15380
	lw $t3, white
	jal g			# Writing Game
	jal a
	jal m	
	jal e
	addi $t2, $t2, 16	# Space
	jal o			# writing Over
	jal v
	jal e
	jal r
go_loop:	
	jal keyboard
	li $v0, 32
	li $a0, 40
	syscall
	j go_loop
	
	
game_won:
	jal clear_screen
	li $t1, 0
	sw $t1, gameRunning
	li $t0, BASE_ADDRESS
	lw $t3, white
	addi $t2, $t0, 14108
	jal c			# Writing Congrats
	jal o
	jal n
	jal g
	jal r
	jal a
	jal t
	jal s
	addi $t2, $t0, 16412	# Next line
	jal y			# Writing You
	jal o
	jal u
	addi $t2, $t2, 16	# Space
	jal w			# Writing Won
	jal o
	jal n	
	addi $t2, $t2, 4	# Small space
	jal exclamation		# Writing !!
	jal exclamation
gw_loop:	
	jal keyboard
	li $v0, 32
	li $a0, 40
	syscall
	j gw_loop

end:
	li $v0, 10 # terminate the program gracefully
	syscall
