#####################################################################
#
# CSC258H5S Winter 2021 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Andrew Qiu, 1006261992
# - Student 2: Renfrew Ao-ieong, 1005302904
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 5
#
# Which approved additional features have been implemented?
# 1. Background Music, Jump Noise, Death Music (Feature 13)
# 2. Diplay the score on screen.	       (Feature 1)
# 3. Changing difficulty as game progresses. (Feature 12)
#
# Any additional information that the TA needs to know:
# The maximum score the player can achieve is 99. Every 10 points, the platform will shrink by 1 unit. There are also some messages displayed in the console.
#
#####################################################################
.data
	displayAddress:	.word	0x10008000
	
	# Colour
	backgroundColour: .word 0xc9f8ff # light blue
	platformColour: .word 0x49E20E # nerf green
	playerColour: .word 0xdea5a4 # pastel pink
	
	# platform locations
	platform1: .word 1280
	platform2: .word 2688
	platform3: .word 3968
	
	# platform size, will decrease as player gets more points
	platformSize: .word 10
	
	playerLocation: .word 0
	leftLeg: .word 0
	rightLeg: .word 0
	
	counter: .word 0
	willShiftDown: .word 0
	
	#lastCollision: .word 3 #defaults to 3 since doodler starts at platform 3
	points: .word 0
	pointsMessage: .asciiz "Points: "
	deathMessage: .asciiz "GAMEOVER!"
	winningMessage: .asciiz "Congratz on getting 99 points! \nGAMEOVER!"
	
	#debug
	newLine: .asciiz "\n"
	
	#Sound
	pitch: .byte 69

	instrument: .byte 31

	pitch1: .byte 10
	pitch2: .byte 127
	pitch3: .byte 63
	duration: .byte 100
	instrument1: .byte 104
	instrument2: .byte 111
	instrument3: .byte 95
	volume1: .byte 70
	volume2: .byte 127
	chromaticPitches: .byte 72,71,70,69,68,67,66,65,64,63,62,61,60,0
	
.text
	lw $t0, displayAddress	# $t0 stores the base address for display

main: 
	jal setBackgroundINIT
	jal initializeObjects

initializeObjects:
	# Initalize the third platform
	lw $t1, platform3
	addi $sp, $sp, -4
	sw $t1, 0($sp)
 	jal generateRandomLocation
 	
 	# store location platform 3
 	lw $t0, 0($sp)
 	sw $t0, platform3
 
 	# paints platform
 	addi $sp, $sp, -4
	sw $t0, 0($sp)
 	jal createPlatformINIT
 	
 	# update player's location to sit on platform 3
 	lw  $t0, platform3
 	subi $t0, $t0, 368 # subtract 3 rows
 	sw $t0, playerLocation
 	
 	# Create Player
 	jal createPlayerINIT
 
	# Initalize the second platform	
	#li $t1, 2688
	lw  $t1, platform2
	addi $sp, $sp, -4
	sw $t1, 0($sp)
 	jal generateRandomLocation
 	
 	# store location platform 2
 	lw $t0, 0($sp)
 	sw $t0, platform2
 	
 	# paints platform
 	addi $sp, $sp, -4
	sw $t0, 0($sp)
 	jal createPlatformINIT
	
	# Initalize the first platform 
	#li $t1, 1408
	lw  $t1, platform1
	addi $sp, $sp, -4
	sw $t1, 0($sp)
 	jal generateRandomLocation
 	
 	# store location platform 1
 	lw $t0, 0($sp)
 	sw $t0, platform1
 	
 	# paints platform
 	addi $sp, $sp, -4
	sw $t0, 0($sp)
 	jal createPlatformINIT
 	
 	# paints inital points
 	jal drawScore

playINIT:
	li $t1, 1
	#beq $t1, $zero Exit
	beq $t1, $zero mainLoop
	li $v0, 32
	li $a0, 1000
	syscall
	
	#j Exit
	j mainLoop

createPlayerINIT:
	# access variables
	lw $t0, displayAddress
	lw $t2, playerColour
	lw $t8, playerLocation

	add $t0, $t0, $t8
	
	# Initalize player
	sw $t2, 0($t0)	# Head

	li $t3, 128
	leftLegWrapCond:
		div $t0, $t3
		mfhi $t4
		beqz $t4, leftLegWrapTrue
	
	rightLegWrapCond:
		addi $t6, $t0, 4
		div $t6, $t3
		mfhi $t4
		beqz $t4, rightLegWrapTrue
	
	addi $t0, $t0, 124
	
	sw $t2, 0($t0) # Bodi
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	
	addi $t0, $t0, 128
	sw $t2, 0($t0) # Legs
	sw $t2, 8($t0)
	
	addi $t8, $t8, 252
 	sw $t8, leftLeg
 	addi $t8, $t8, 8
 	sw $t8, rightLeg
	
	jr $ra
	
	leftLegWrapTrue:
		addi $t0, $t0, 128
		sw $t2, 0($t0) # Chest 
		sw $t2, 4($t0) # Right Shoulder
		sw $t2, 124($t0) #Left Shoulder
		addi $t0, $t0, 128
		sw $t2, 4($t0) # Right Leg
		sw $t2, 124($t0) # Left Leg
		addi $t8, $t8, 256
		addi $t8, $t8, 4
		sw $t8, rightLeg
		addi $t8, $t8, 120
		sw $t8, leftLeg
		jr $ra
		
	rightLegWrapTrue:
		addi $t0, $t0, 128
		sw $t2, 0($t0) # Chest 
		sw $t2, -4($t0) # Left Shoulder
		sw $t2, -124($t0) #Right Shoulder
		addi $t0, $t0, 128
		sw $t2, -4($t0) # Left Leg
		sw $t2, -124($t0) # Right Leg
		addi $t8, $t8, 256
		addi $t8, $t8, -4
		sw $t8, leftLeg
		addi $t8, $t8, -120
		sw $t8, rightLeg
		jr $ra

createPlatformINIT:
	lw $t0, displayAddress
	
	# platform location
	lw $t5, 0($sp)
	addi $sp, $sp, 4
	add $t0, $t0, $t5
	
	# counter
	li $t1, 0
	
	# size of platform 
	# platform size starts 10, every 10 points, shrink platform size by 1
	li $t2, 10
	
	lw $t9, points
	div $t8, $t9, $t2
	mflo $t8
	
	sub $t2, $t2, $t8 
	sw $t2, platformSize

createPlatformLoop:
	#  if counter != size
	beq $t1, $t2, returnPlatformLoop

	# Set each unit's colour
	lw $t3, platformColour
	sw $t3, 0($t0)
	
	# 'increase offset by 4'
	addi $t0, $t0, 4
	
	addi $t1, $t1, 1
	j createPlatformLoop
	
returnPlatformLoop: 
	#addi $sp, $sp, -4
	#sw $t6, 0($sp)
	jr $ra
	
setBackgroundINIT:
	lw $t0, displayAddress
	
	# unit counter
	li $t1, 0
	
	# units
	li $t3, 1024
	
setBackgroundLoop:
	# if counter != # units
	beq $t1, $t3, setBackgroundLoopExit
	
	# Set each unit's colour
	lw $t4, backgroundColour
	sw $t4, 0($t0)
	
	# 'increase offset by 4'
	addi $t0, $t0, 4
	
	# counter++
	addi $t1, $t1, 1
	j setBackgroundLoop
	
setBackgroundLoopExit:
	jr $ra
	
paintScreen:
	# save return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal setBackgroundINIT	
	
	lw $t0, platform3
	# paints platform
 	addi $sp, $sp, -4
	sw $t0, 0($sp)
 	jal createPlatformINIT
	
	lw $t0, platform2
	# paints platform
 	addi $sp, $sp, -4
	sw $t0, 0($sp)
 	jal createPlatformINIT
	
	lw $t0, platform1
	 # paints platform
 	addi $sp, $sp, -4
	sw $t0, 0($sp)
 	jal createPlatformINIT
 	
 	# paintPlayer
 	jal createPlayerINIT
 	
 	# paintScore
 	jal drawScore
 	
	# pop return address
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
	
generateRandomLocation:
	# platform location
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	
	# random number in the x direction
	li $a1, 22 # edge of the board - width of platform
	li $v0, 42
	syscall
	
	li $t1, 4
	mult $a0, $t1 # multiple random number by 4
	mflo $t2
	add $t0, $t0, $t2
 	
	# return new location
	addi $sp, $sp, -4
	sw $t0, 0($sp)

	jr $ra

Sleep:
	ori $v0, $zero, 32		# Syscall sleep
	ori $a0, $zero, 150		# For this many miliseconds
	syscall
	jr $ra				# Return
	nop

mainLoop:
	jal Sleep
	gameLoop:
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal jumpSound
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jal jump
		
		j gameLoop
	
getInput:
	lw $t5, 0xffff0000 
	beq $t5, 1, checkPressed
	
	jr $ra
		
checkPressed:
	lw $t5, 0xffff0004 
	beq $t5, 0x6A, moveLeft		# the "j" key
	beq $t5, 0x6B, moveRight		# the "k" key

	jr $ra

moveLeft:
	# Moves the player left 1 unit (4 bytes)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal resetInput

	lw $t0, playerLocation
	li $t1, 128
	leftIF:
		div $t0, $t1
		mfhi $t2
		beqz $t2, leftElse
	addi $t0, $t0, -4
	sw $t0, playerLocation
	j moveExit

	leftElse:
		addi $t0, $t0, 124
		sw $t0, playerLocation
		j moveExit
	
moveRight:

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal resetInput

	lw $t0, playerLocation
	li $t1, 128
	addi $t2, $t0, 4
	rightIF:
		div $t2, $t1
		mfhi $t3
		beqz $t3, rightElse
	addi $t0, $t0, 4
	sw $t0, playerLocation
	j moveExit

	rightElse:
		addi $t0, $t0, -124
		sw $t0, playerLocation
		j moveExit

moveExit:
	jal paintScreen
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

resetInput:
	sw $zero, 0xffff0000	# clear 'user input'
	sw $zero, 0xffff0004
	jr $ra

jump:
	# counter 
	li $t1, 0
	sw $t1, counter # need counter address since $t1 is being used else where
	
jumpUp:
	lw $t1, counter 
	li $t2, 12 # in case $t2 is being used
	
	beq $t1, $t2 jumpUpExit 
	
	# player is constantly moving up
	lw $t0, playerLocation

	GenerateNewPlatformTrue:	
		slti $t3, $t0, 1664 # if player reaches this point start generating new platforms and discard old
		
		li $t9, 7 # generate new platform only if player reaches certain height and jump counter is 8
		seq $t4, $t1, $t9
		
		and $t3, $t3, $t4
		
		li $t5, 1
		bne $t3, $t5 GeneratePlatformFalse
	
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	
		jal generateNewPlatform
		li $t6, 1
		sw $t6, willShiftDown
	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	
GeneratePlatformFalse:
	lw $t0, willShiftDown
	li $t1, 1
	bne $t0, $t1, decreasePlatformFalse
	
	decreasePlatformTrue:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal shiftPlatformsDown
		
		#added this
		lw $t0 playerLocation
		addi $t0, $t0, 128
		sw $t0, playerLocation
		#end
		
		lw $ra, 0($sp)
		addi $sp, $sp 4

decreasePlatformFalse:
	lw $t0, playerLocation
	subi $t0, $t0, 128
	sw $t0, playerLocation
	jal paintScreen
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal sound1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jal Sleep
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal sound2
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jal getInput
	
	lw $t1, counter
	addi $t1, $t1, 1
	sw $t1, counter
	
	j jumpUp
	
jumpUpExit:
	# reset willShiftDown to 0
	li $t6, 0
	sw $t6, willShiftDown

	# counter 
	li $t1, 0
	sw $t1, counter # need counter address since $t1 is being used else where
	jal jumpDown
	
jumpDown:
	lw $t0, playerLocation
	lw $a0, leftLeg
	lw $a1, rightLeg
	
	addi $sp, $sp, -24			# Increase stack size
	sw $ra, 0($sp)				# Store the return address
	sw $t0, 4($sp)				# Store $t0
	sw $t1, 8($sp)				# Store $t1
	sw $t2, 12($sp)				# Store $t2
	sw $t1, 16($sp)				# Store $t3
	sw $t2, 20($sp)				# Store $t4
	
	jal checkCollision
	
	lw $ra, 0($sp)				# Load original values back
	lw $t0, 4($sp)				
	lw $t1, 8($sp)				
	lw $t2, 12($sp)				
	lw $t1, 16($sp)				
	lw $t2, 20($sp)				
	addi $sp, $sp, 24			# Shrink back the stack
	
	beq $v0, 1, gameLoop
	beq $v0, 2, death

	#lw $t0, playerLocation
	addi $t0, $t0, 128
	sw $t0, playerLocation
	jal paintScreen
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal sound1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jal Sleep
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal sound2
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jal getInput
	j jumpDown

checkCollision:	
	# no need to check collision for platform1 player will never reach to platform1
	lw $t1, platform2
	lw $t2, platform3
	
	# Collision occurs when the leg is above a platform
	# We check if the leg is above the range of values that
	# the platform takes up (10 blocks wide)

	addi $a0, $a0, 128	# Set to one row below legs
	addi $a1, $a1, 128
	
	# Platform 2
	
	sle $t3, $t1, $a0  # Platform 2 Left Edge <= left leg
	
	# get platform size + offset
	lw $t9, platformSize
	subi $t9, $t9, 1
	li $t7, 4
	mult $t9, $t7
	mflo $t9

	add $t1, $t1, $t9 # offset
	sle $t4, $a0, $t1  # left leg <= Platform 2 right Edge
	
	and $t3, $t3, $t4  # $t3 = 1 if left leg on platform
	
	beq $t3, 1, increasePointsTrue
	
	lw $t1, platform2  # Reset platform 2
	
	sle $t3, $t1, $a1  

	# get platform size + offset
	lw $t9, platformSize
	subi $t9, $t9, 1
	li $t7, 4
	mult $t9, $t7
	mflo $t9

	add $t1, $t1, $t9 # offset

	sle $t4, $a1, $t1
	
	and $t3, $t3, $t4  
	bne $t3, 1, increasePointsFalse

	increasePointsTrue:
		lw $t8, points
		addi $t8, $t8, 1
		sw $t8, points	
	
		addi $sp, $sp, -4 # store return address
		sw $ra, 0($sp)
	
		jal checkWin
	
		lw $ra, 0($sp) # pop return address
		addi $sp, $sp, 4
	
		beq $t3, 1, colTrue

increasePointsFalse:
	# Platform 3
	
	sle $t3, $t2, $a0  # Check if left leg is on platform 3
	
	# get platform size + offset
	lw $t9, platformSize
	subi $t9, $t9, 1
	li $t7, 4
	mult $t9, $t7
	mflo $t9
	
	add $t2, $t2, $t9
	sle $t4, $a0, $t2
	
	and $t3, $t3, $t4  # $t3 = 1 if left leg on platform
	
	beq $t3, 1, colTrue
	
	lw $t2, platform3  # Reset platform 3
	
	sle $t3, $t2, $a1
	
	# get platform size + offset
	lw $t9, platformSize
	subi $t9, $t9, 1
	li $t7, 4
	mult $t9, $t7
	mflo $t9
	
	add $t2, $t2, $t9
	
	sle $t4, $a1, $t2
	
	and $t3, $t3, $t4
	
	beq $t3, 1, colTrue
	
	# If player falls to the bottom
	lw $t0, playerLocation # head
	
	sub $t0, $t0, 128	# checks to see if head is off the screen
	li $t1, 3968      	# left most bottom row
	sle $t3, $t1, $t0	# left most <= row above head
	
	li $t1, 4096		# right most bottom row
	sle $t4, $t0, $t1	# left leg <= row above head
	
	and $t3, $t3, $t4
	beq $t3, 1, colDead
	
	# Done
	colFalse:
		li $v0, 0
		jr $ra
	
	colTrue:
		li $v0, 1
		jr $ra
		
	colDead:
		li $v0, 2
		jr $ra		
	
generateNewPlatform:
	# store return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, platform2
	sw $t0, platform3
	
	lw $t0, platform1
	sw $t0, platform2
	
	# creates new platform1
	li $t0, 0
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	 
	jal generateRandomLocation
	
	lw $t0, 0($sp)
	sw $t0, platform1
	addi $sp, $sp, 4
	
	# load return address
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	 			
shiftPlatformsDown:

	lw $t0, platform3
	#addi $t0, $t0, 128 # increase row
	addi $t0, $t0, 256 # increase row
	sw $t0, platform3
	
	lw $t0, platform2
	#addi $t0, $t0, 128 # increase row
	addi $t0, $t0, 256 # increase row
	sw $t0, platform2
	
	lw $t0, platform1
	#addi $t0, $t0, 128 # increase row
	addi $t0, $t0, 256 # increase row
	sw $t0, platform1

	jr $ra
 
checkWin:
	lw $t9, points
	li $t8, 99
	beq $t9, $t8, win
	jr $ra
	
win:
	li $v0, 4
	la $a0, winningMessage
	syscall
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	li $v0, 4
	la $a0, pointsMessage
	syscall
	
	li $v0, 1
	lw $a0, points
	syscall
	
	jal paintScreen
	j drawGameOver

# FEATURES #

# Display points on screen
drawScore:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # save return address

	# determines tens digit
	lw $t0, displayAddress
	lw $t1, points
	
	addi $t0, $t0, 4
	addi $sp, $sp, -4 
	sw $t0, 0($sp) # push location
	
	li $t9, 10
	div $t2, $t1, 10 
	mflo $t2 # gets the tens digit
	
	addi $sp, $sp, -4
	sw $t2, 0($sp) # push digit
	
	jal drawDigit # draw tens digit
	
	# determines ones digit
	lw $t0, displayAddress
	addi $t0, $t0, 20
	addi $sp, $sp, -4
	sw $t0, 0($sp) # push location
	
	lw $t1, points
	li $t9, 10
	div $t2, $t1, 10 
	mfhi $t2 # gets the ones digit
	
	addi $sp, $sp, -4
	sw $t2, 0($sp) # push digit

	jal drawDigit
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4 # gets saved return address
	
	jr $ra

drawDigit:
	# parameters: (location, number)
	lw $t3, 0($sp)
	addi $sp, $sp, 4 # pops number 
	
	li $t5, 0
	beq $t3, $t5, drawZero
	
	li $t5, 1
	beq $t3, $t5, drawOne
	
	li $t5, 2
	beq $t3, $t5, drawTwo
	
	li $t5, 3
	beq $t3, $t5, drawThree
	
	li $t5, 4
	beq $t3, $t5, drawFour
	
	li $t5, 5
	beq $t3, $t5, drawFive
	
	li $t5, 6
	beq $t3, $t5 drawSix
	
	li $t5, 7
	beq $t3, $t5 drawSeven
	
	li $t5, 8
	beq $t3, $t5, drawEight
	
	li $t5, 9
	beq $t3, $t5 drawNine
	
drawZero:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	jr $ra
	
drawOne:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	sw $t1, 8($t0)
	
	jr $ra

drawTwo:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	jr $ra

drawThree:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row	
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	jr $ra

drawFour:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4  
	
	li $t1, 0x000000 # black colour
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	
	jr $ra
	
drawFive:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4  
	
	li $t1, 0x000000 # black colour
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	jr $ra
	
drawSix:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row

	jr $ra
	
drawSeven:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row

	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
			
	jr $ra
	
drawEight:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row

	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	jr $ra
	
drawNine:
	lw $t1, 0($sp) # takes in the location
	addi $sp, $sp, 4 
	
	li $t1, 0x000000 # black colour
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	addi $t0, $t0, 128 # offset to next row
	
	sw $t1, 8($t0)
	
	jr $ra
	
jumpSound:
	li $v0, 31 
	lbu $t0, pitch
	lbu $t1, duration 
	lbu $t2, instrument
	lbu $t3, volume2
	move $a0, $t0 
	move $a1, $t1 
	move $a2, $t2
	move $a3, $t3 
	syscall 
	jr $ra
	
sound1:
	li $v0, 31 
	lbu $t0, pitch1
	lbu $t1, duration 
	lbu $t2, instrument1
	lbu $t3, volume1
	move $a0, $t0 
	move $a1, $t1 
	move $a2, $t2
	move $a3, $t3 
	syscall
	jr $ra
	
sound2:
	li $v0, 31 
	lbu $t0, pitch3
	lbu $t1, duration 
	lbu $t2, instrument1
	lbu $t3, volume1
	move $a0, $t0 
	move $a1, $t1 
	move $a2, $t2
	move $a3, $t3 
	syscall
	jr $ra

death:
	li $v0, 31 
	la $t0, chromaticPitches
	la $t1, duration 
	la $t2, instrument2
	la $t3, volume2
	move $t4, $t0
	move $a0, $t0
	move $a1, $t1 
	move $a2, $t2
	move $a3, $t3
	musicLoop:
		lb $a0, 0($t0)
		beqz $a0, endMusic
		syscall
		addi $t0, $t0, 1
		j musicLoop
	endMusic:
		li $v0, 4
		la $a0, deathMessage
		syscall
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		li $v0, 4
		la $a0, pointsMessage
		syscall
		
		li $v0, 1
		lw $a0, points
		syscall

drawGameOver:
	# creates mesage row by row
	lw $t0, displayAddress
	li $t1, 0xff0000 # red
	addi $t0, $t0, 1576
	
	sw $t1, 0($t0) # b
	sw $t1, 32($t0) # e
	sw $t1, 36($t0)
	sw $t1, 40($t0)	
	sw $t1, 48($t0) # !
	addi $t0, $t0, 128 # offset
	
	sw $t1, 0($t0) # b
	sw $t1, 32($t0) # e
	sw $t1, 48($t0) # !
	addi $t0, $t0, 128
	
	sw $t1, 0($t0) # b
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 16($t0) # y
	sw $t1, 24($t0)
	sw $t1, 32($t0) # e
	sw $t1, 36($t0) 
	sw $t1, 40($t0)
	sw $t1, 48($t0) # !
	addi $t0, $t0, 128
	
	sw $t1, 0($t0) # b
	sw $t1, 8($t0)
	sw $t1, 16($t0) # y
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 32($t0) # e
	addi $t0, $t0, 128
	
	sw $t1, 0($t0) # b
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 24($t0) #  y
	sw $t1, 32($t0) # e
	sw $t1, 36($t0) 
	sw $t1, 40($t0)
	sw $t1, 48($t0) # 1
	addi $t0, $t0, 128
	
	sw $t1, 16($t0) # y
	sw $t1, 20($t0) 
	sw $t1, 24($t0)

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall

