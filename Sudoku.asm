# TRIAL FOR SUDOKU


# WHAT WE NEED:
# Main menu: how to play and starting the game
# Display tile user is on
# Display the numbers : macros for number creation and also font color
# Main menu: ANGELA (How to play; play easy; play hard)
# Algorithm: checking if user input is correct
# Bitmap Display

#################### DISPLAY CONFIG ######################
# Unit width in Pixels: 8
# Unit height in Pixels: 8
# Display Width in Pixels: 512
# Display Height in Pixels: 1024
#########################################################

.data 
frameBuffer: .space 0x8000
#firstPixel: .word 1728
textColorValue: .word 0x005e5e5e
backgroundColorValue: .word 0x00dbdbdb
borderColorValue: .word 0x00858585
darkBorderColorValue: .word 0x00515151
blueBackgroundValue: .word 0x00bdc7db
easyPuzzle: .word -1, -1, 3, -1, 9, 4, 1, 6, 7, 4, 7, 9, 6, 1, -1, -1, -1, -1, 5, -1, -1, -1, 7, -1, -1, 9, -1, 3, 2, -1, 9, -1 , -1, -1, 7, -1, 1, -1, -1, -1, -1, 8, -1, -1, 5, -1, 5, 7, 2, 6, 1, -1, -1, 3, -1, -1, 5, 4, -1, -1, 7, -1, 6, -1, -1, 2, 3, -1, 6, 4, -1, -1, -1, 3, -1, -1, 8, -1, 2, 5, -1
row0: .word -1, -1, 3, -1, 9, 4, 1, 6, 7
row1: .word 4, 7, 9, 6, 1, -1, -1, -1, -1
row2: .word 5, -1, -1, -1, 7, -1, -1, 9, -1
row3: .word 3, 2, -1, 9, -1 , -1, -1, 7, -1
row4: .word 1, -1, -1, -1, -1, 8, -1, -1, 5
row5: .word -1, 5, 7, 2, 6, 1, -1, -1, 3
row6: .word -1, -1, 5, 4, -1, -1, 7, -1, 6
row7: .word -1, -1, 2, 3, -1, 6, 4, -1, -1
row8: .word -1, 3, -1, -1, 8, -1, 2, 5, -1
correctRow: .word 2, 8, 3, 5, 9, 4, 1, 6, 7, 4, 7, 9, 6, 1, 3, 5, 8, 2, 5, 6, 1, 8, 7, 2, 3, 9, 4, 3, 2, 8, 9, 4, 5, 6, 7, 1, 1, 4, 6, 7, 3, 8, 9, 2, 5, 9, 5, 7, 2, 6, 1, 8, 4, 3, 8, 1, 5, 4, 2, 9, 7, 3, 6, 7, 9, 2, 3, 5, 6, 4, 1, 8, 6, 3, 4, 1, 8, 7, 2, 5 ,9
row0corr: .word 2, 8, 3, 5, 9, 4, 1, 6, 7
row1corr: .word 4, 7, 9, 6, 1, 3, 5, 8, 2
row2corr: .word 5, 6, 1, 8, 7, 2, 3, 9, 4
row3corr: .word 3, 2, 8, 9, 4, 5, 6, 7, 1
row4corr: .word 1, 4, 6, 7, 3, 8, 9, 2, 5
row5corr: .word 9, 5, 7, 2, 6, 1, 8, 4, 3
row6corr: .word 8, 1, 5, 4, 2, 9, 7, 3, 6
row7corr: .word 7, 9, 2, 3, 5, 6, 4, 1, 8
row8corr: .word 6, 3, 4, 1, 8, 7, 2, 5 ,9

# Registers used: $t0, $t1, $t2, $t3, $t4, $t5, $t6, $s0, $s1, $s2, $s3, $s4
# however does not really matter too much since this macro is being called once in the very beginning of the program
# might need to change later if we want to implement various options before this haha cause it uses a lot of registers
.macro createGrid
	la $t0, frameBuffer 	# load frame buffer addres
	li $t1, 0 		# holds the starting pixel of the bitmap display
	li $t2, 0x00dbdbdb	# regular background color
	li $t3 0x00858585	# border color
	li $t6 0x00515151	# darker border
	li $s0, 7 		# pixel spacing for column
	li $s4, 21
	li $s1, 512 		# pixel spacing for row
	li $s2, 64		# start of chunk to display a row
	li $s3, 1536
	whatColor:
		# shifts the grid 27 rows downwards
		blt $t1, 1728, changeTile
		# stops the grid after 9 rows
		bge $t1, 6400, changeTile
		# moves the grid to align with the start of the display
		subi $t5, $t1, 192
		# create the rows
		div $t5, $s3
		mfhi $t4
		blt $t4, 64, darkBorderColor
		div $t5, $s2
		mfhi $s5
		div $s5, $s4
		mfhi $s5
		beqz $s5, darkBorderColor
		div $t5, $s1
		mfhi $t4
		blt $t4, 64, borderColor
		div $s5, $s0
		mfhi $s5
		beqz $s5, borderColor
		b backgroundColor
	darkBorderColor:
		sw $t6, 0($t0)
		b changeTile
	borderColor:
		sw $t3, 0($t0)
		b changeTile
	backgroundColor:
		sw $t2, 0($t0)
	changeTile:
	addi $t0, $t0, 4 	# advance to next pixel position in display
	addi $t1, $t1, 1 	# increase pixel position
	blt $t1, 0x2000, whatColor 
.end_macro

# holds pixel address place in $s7: needed for transfer of data
# uses registers: $t6, $t7, $s7
.macro getAddressForNum(%int)
	li $s7, 1728
	li $t6, 9
	div $t7, %int, 9
	mul $t7, $t7, 512
	add $s7, $s7, $t7
	div %int, $t6
	mfhi $t7
	mul $t7, $t7, 7
	add $s7, $s7, $t7
	# this grabs the pixel location of the beginning of most numbers
	addi $s7, $s7, 130
	# this translates to the address of that pixel to be added to the frameBuffer
	mul $s7, $s7, 4
	la $t6, frameBuffer
	add $s7, $t6, $s7
.end_macro

.macro getAddressForBack(%int)
	li $s7, 1728
	li $t6, 9
	div $t7, %int, 9
	mul $t7, $t7, 512
	add $s7, $s7, $t7
	div %int, $t6
	mfhi $t7
	mul $t7, $t7, 7
	add $s7, $s7, $t7
	# this grabs the pixel location for the first background pixel in the tile
	addi $s7, $s7, 65
	# this translates to the address of that pixel to be added to the frameBuffer
	mul $s7, $s7, 4
	la $t6, frameBuffer
	add $s7, $t6, $s7
.end_macro

# Uses $t5 as the number color; we can change later; this register is intialized within the display easy numbers
# %int is the number pixel address that we start at for the specific tile
# These create macros are/should only be called by the display specific number macros

# create the left vertical line for the numbers
.macro createLeftV(%int)
	# $t5 from the display macros holds the color we want to display
	sw $t5, 0(%int)
	sw $t5, 256(%int)
	sw $t5, 512(%int)
	sw $t5, 768(%int)
	sw $t5, 1024(%int)
.end_macro

# create the right vertical line for the numbers
.macro createRightV(%int)
	sw $t5, 12(%int)
	sw $t5, 268(%int)
	sw $t5, 524(%int)
	sw $t5, 780(%int)
	sw $t5, 1036(%int)
.end_macro

# create the top horizontal line
.macro createTopH(%int)
	sw $t5, 0(%int)
	sw $t5, 4(%int)
	sw $t5, 8(%int)
	sw $t5, 12(%int)
.end_macro

# create the middle horizontal line
.macro createMiddleH(%int)
	sw $t5, 512(%int)
	sw $t5, 516(%int)
	sw $t5, 520(%int)
	sw $t5, 524(%int)
.end_macro

# create the bottom horizontal line
.macro createBottomH(%int)
	sw $t5, 1024(%int)
	sw $t5, 1028(%int)
	sw $t5, 1032(%int)
	sw $t5, 1036(%int)
.end_macro

# FOR NOW ALL DISPLAY NUMBER MACROS ARE TAKING IN THE TILE (should be nice and easy for further implementation)
# taking in the tile that the user or the program is at to display
.macro displayOne(%int)
	# add 1's
## FOR NOW $t5 HOLDS THE COLOR USED
	# move the position of the address over to the right by one to start drawing
	addi $s7, $s7, 4
	sw $t5, 0($s7)
	sw $t5, 4($s7)
	sw $t5, 260($s7)
	sw $t5, 516($s7)
	sw $t5, 772($s7)
	sw $t5, 1028($s7)
.end_macro

.macro displayTwo(%int)
	# Create Two Frame
	createTopH($s7)
	createMiddleH($s7)
	createBottomH($s7)
	# shift address over by 268 and store the color
	sw $t5, 268($s7)
	sw $t5, 768($s7)
.end_macro

.macro displayThree(%int)
	# Create three
	createTopH($s7)
	createMiddleH($s7)
	createBottomH($s7)
	createRightV($s7)
.end_macro

.macro displayFour(%int)
	createMiddleH($s7)
	createRightV($s7)
	sw $t5, 0($s7)
	sw $t5, 256($s7)
.end_macro

.macro displayFive(%int)
	# Create Two Frame
	createTopH($s7)
	createMiddleH($s7)
	createBottomH($s7)
	# shift to fill in the holes
	sw $t5, 256($s7)
	sw $t5, 780($s7)
.end_macro

.macro displaySix(%int)
	displayFive(%int)
	sw $t5, 768($s7)
.end_macro

.macro displaySeven(%int)
	createTopH($s7)
	createRightV($s7)
.end_macro

.macro displayEight(%int)
	createTopH($s7)
	createMiddleH($s7)
	createBottomH($s7)
	createRightV($s7)
	createLeftV($s7)
.end_macro
	
.macro displayNine(%int)
	displayFour(%int)
	createTopH($s7)
.end_macro


# find out what number was inputted and display it
# Not using any registers
# taking in two parameters: the number that needs to be displayed and the tile that it needs to be displayed in
# calls the display"ACTUAL_NUMBER" macro:
# In total uses registers: $s7 for address starting point gathered from the tile number and $t5 which hold the color to write in
# and $t6 & $t7 for the macro: getAddressForNum and $t4 will be used to load the color to check if we need to change the background to neutral before displaying the number
.macro displayNumber(%number, %tile)
	# everytime we need to display a number at the tile we want to grab the address of the tile that it is at
	getAddressForNum(%tile)
	#lw $t4, 0($s7)
	#beq $t4, 0x00858585, changeBackground
	#lw $t4, 4($s7)
	#beq $t4, 0x00858585, changeBackground
checkNum:
	beq %number, 1, displayOneL
	beq %number, 2, displayTwoL
	beq %number, 3, displayThreeL
	beq %number, 4, displayFourL
	beq %number, 5, displayFiveL
	beq %number, 6, displaySixL
	beq %number, 7, displaySevenL
	beq %number, 8, displayEightL
	beq %number, 9, displayNineL

displayOneL:
	displayOne(%tile)
	j exit
displayTwoL:
	displayTwo(%tile)
	j exit
displayThreeL:
	displayThree(%tile)
	j exit
displayFourL:
	displayFour(%tile)
	j exit
displayFiveL:
	displayFive(%tile)
	j exit
displaySixL:
	displaySix(%tile)
	j exit
displaySevenL:
	displaySeven(%tile)
	j exit
displayEightL:
	displayEight(%tile)
	j exit
displayNineL:
	displayNine(%tile)
	j exit
changeBackground:
	resetTileBackground(%tile)
	j checkNum
exit:

.end_macro

# Registers used: $t0, $t1, $t5, $s0
# used from other macros: $t6, $t7, $s7
# should only be called once in the beginning
.macro displayEasyNumbers
	# hold the color
	li $t5, 0x005e5e5e
	# grabbing first address of the puzzle
	la $s0, easyPuzzle
	# loop counter
	li $t1, 0
	
loop:
	lw $t0, 0($s0)
	
	bltz $t0, nextTile
	displayNumber($t0, $t1)
	
nextTile:
	# increment the base address by 4
	addi $s0, $s0, 4
	#increment the counter by one
	addi $t1, $t1, 1
	#implement conditional to breakout of the loop
	blt $t1, 81, loop
.end_macro

# takes in the tile that the user is at and displays the background color
# uses registers $t4, $t5, $t6, $t7, $s7
.macro setTileBackground(%int)
	# blue background color
	li $t4, 0x00bdc7db
	getAddressForBack(%int)
	li $t6, 0
	resetRow:
	li $t7, 0
	setColorOfTile:
	# grab the color of that pixel
	lw $t5, 0($s7)
	# if it is the color of the text, then do not change that value
	beq $t5, 0x005e5e5e, changeToNextTile
	beq $t5, 0x00858585, changeToNextTile
	beq $t5, 0x0017bf04, changeToNextTile
	sw $t4, 0($s7)
	changeToNextTile:
	# change the counter
	addi $t7, $t7, 1
	# change to next tile
	addi $s7, $s7, 4
	# if havent completed the row, continue to the next tile
	blt $t7, 6, setColorOfTile
	
	# if completed go to the beginning of the next row
	addi $s7, $s7, 232
	addi $t6, $t6, 1
	blt $t6, 7, resetRow
	
.end_macro

# this macro changes the entire background color of the tile
.macro resetTileBackground(%int)
	li $t4, 0x00dbdbdb
	getAddressForBack(%int)
	li $t6, 0
	resetRow:
	li $t7, 0
	setColorOfTile:
	# grab the color of that pixel
	lw $t5, 0($s7)
	# if it is the color of the text, then do not change that value
	beq $t5, 0x005e5e5e, changeToNextTile
	beq $t5, 0x0017bf04, changeToNextTile
	sw $t4, 0($s7)
	changeToNextTile:
	# change the counter
	addi $t7, $t7, 1
	# change to next tile
	addi $s7, $s7, 4
	# if havent completed the row, continue to the next tile
	blt $t7, 6, setColorOfTile
	
	# if completed go to the beginning of the next row
	addi $s7, $s7, 232
	addi $t6, $t6, 1
	blt $t6, 7, resetRow
	
.end_macro

# this macro resets the background without changing the number that has been already placed by the user
.macro resetTileBackWONum(%int)
	li $t4, 0x00dbdbdb
	getAddressForBack(%int)
	li $t6, 0
	resetRow:
	li $t7, 0
	setColorOfTile:
	# grab the color of that pixel
	lw $t5, 0($s7)
	# if it is the color of the text, then do not change that value
	beq $t5, 0x005e5e5e, changeToNextTile
	beq $t5, 0x00858585, changeToNextTile
	beq $t5, 0x0017bf04, changeToNextTile
	sw $t4, 0($s7)
	changeToNextTile:
	# change the counter
	addi $t7, $t7, 1
	# change to next tile
	addi $s7, $s7, 4
	# if havent completed the row, continue to the next tile
	blt $t7, 6, setColorOfTile
	
	# if completed go to the beginning of the next row
	addi $s7, $s7, 232
	addi $t6, $t6, 1
	blt $t6, 7, resetRow
.end_macro

.macro String(%str)
	li $v0, 4
	.data
	message: .asciiz %str
	.text
	la $a0, message
	syscall
.end_macro

.macro GetUserInput
	String("\nPlease enter here: ")
	li $v0, 5
	syscall
	move $t0, $v0
.end_macro

.data

.text
# REGISTERS WE WILL USE
# $s0: designated for tile that we are at on the board; ranges from 0-80
# $s1: designated for holding user input
# $s2: designed to hold the address pixel of where the user is at (main purpose for checking if there is a number there
 # and if the user can overwrite the number there or not
# $s7: is held for purposes of grabbing the pixel address

main:
	#
	# This is where the main menu display should go
	#
	# display main menu
	String("............... SUDOKU ...............\n")
	String(".                                    .\n")
	String(".         (1) How To Play            .\n")
	String(".         (2) Start Game             .\n")
	String(".         (3) Exit                   .\n")
	String(".                                    .\n")
	String("......... Number Fight Club ..........\n")
	#loading ammount of errors into s6
	li $s6, 42
	# get user inputs and branch to respective label
	GetUserInput
	
	ble $t0, 0, invalid
	beq $t0, 1, howToPlay
	beq $t0, 2, createGrid
	beq $t0, 3, exit
	bge $t0, 4, invalid
	
invalid:
	# if input is less than 1 or greater than 3, prompts user to try again
	String("Invalid input, please try again.\n")
	j main
	
howToPlay:
	# tells user how to play the game
	String("\n......................... HOW TO PLAY .........................\n")
	String(" CONTROLS: \n")
	String("     w = Move Cursor Up \n")
	String("     a = Move Cursor Left \n")
	String("     d = Move Cursor Right \n")
	String("     s = Move Cursor Down \n")
	String("     q = Exit Program \n")
	String(" HOW TO PLAY SUDOKU: \n")
	String("     Sudoku   is   played  on  a  grid  of  9 x 9  spaces\n")
	String("     with  nine   3 x 3  squares,   rows,   and  columns.\n")
	String("     Each   square,  row,  and  column  contains  numbers\n")
	String("     1 to 9.  To  fill  out  a  square  there must be  NO\n")
	String("     repeats  of  the same number in a square,  row,  and\n")
	String("     column. You should not guess, instead use process of\n")
	String("     elimination and deductive reasoning to decide  which\n")
	String("     numbers go in each blank space. The game is finished\n")
	String("     when  the  board  is  completed meaning you  won! :D \n")
	String(".................................................................\n")
	# allows the user to choose to play the game or exit
	continue:
		String("\n     Enter '1' to start\n")
		String("     Enter '2' to return to main menu\n")
		String("     Enter '3' to exit\n")
	
	GetUserInput
	blt $t0, 1, invalidHTP
	beq $t0, 1, createGrid
	beq $t0, 2, main
	beq $t0, 3, exit
	bgt $t0, 3, invalidHTP
	
#invalid selection handling for how to play
invalidHTP:
	String("Invalid input. Please try again.")
	j continue
	
createGrid:
	createGrid
	# should grab whether easy or hard game mode if we want to implement that
	displayEasyNumbers
	li $s0, 0
	setTileBackground($s0)
	
gameLoop:
	li   $v0, 12       
  	syscall            # Read Character
	addiu $a0, $v0, 0  # $a0 gets the next char
	move $s1, $a0
	beqz $s6, complete #checks if the game is over
	
	#blt $s1, 58, numberCalled
	blt $s1, 58, checkCorrect
	beq $s1, 97, moveLeftA
	beq $s1, 100, moveRightD
	beq $s1, 119, moveUpW
	beq $s1, 115, moveDownS
	beq $s1, 113, exit
	
	b gameLoop
moveLeftA:
	resetTileBackWONum($s0)
	subi $s0, $s0, 1
	bltz $s0, resetSmallNumber
	setTileBackground($s0)
	j gameLoop
	
moveRightD:
	resetTileBackWONum($s0)
	addi $s0, $s0, 1
	beq $s0, 81, resetBigNumber
	setTileBackground($s0)
	j gameLoop
	
moveUpW:
	resetTileBackWONum($s0)
	subi $s0, $s0, 9
	bltz $s0, resetSmallNumber
	setTileBackground($s0)
	j gameLoop
	
moveDownS:
	resetTileBackWONum($s0)
	addi $s0, $s0, 9
	bgt $s0, 80, resetBigNumber
	setTileBackground($s0)
	j gameLoop
	
resetBigNumber:
	subi $s0, $s0, 81
	setTileBackground($s0)
	j gameLoop
	
resetSmallNumber:
	addi $s0, $s0, 81
	setTileBackground($s0)
	j gameLoop
	
# need to get value of that 
numberCalled:
	getAddressForNum($s0)
	lw $s2, 0($s7)
	# exit if cannot overwrite, checking to see if the pixel is a text color or if correct color
	beq $s2, 0x005e5e5e, gameLoop
	beq $s2, 0x0017bf04, gameLoop
	lw $s2, 4($s7)
	# this checks for the number one
	beq $s2, 0x005e5e5e, gameLoop
	beq $s2, 0x0017bf04, gameLoop
	# now checks to see if user inputted a number before here
	beq $s2, 0x00858585, resetTile
	lw $s2, 0($s7)
	beq $s2, 0x00858585, resetTile
	# if it passes the test, change the char to a number
	subi $s1, $s1, 48
	li $t5, 0x00858585
	displayNumber($s1, $s0)
	j gameLoop

resetTile:
	resetTileBackground($s0)
	subi $s1, $s1, 48
	li $t5, 0x00858585
	displayNumber($s1, $s0)
	setTileBackground($s0)
	j gameLoop
resetTileG:
	resetTileBackground($s0)
	subi $s1, $s1, 48
	li $t5, 0x0017bf04
	displayNumber($s1, $s0)
	setTileBackground($s0)
	j gameLoop	
	
# check if numb is correct 
checkCorrect:
	#loading the base addres of the array into $t8
	la $s3, correctRow
	#loop counter
	li $t9, -1
	j correctionLoop
	
correctionLoop:
	#current number of loop
	lw $t0, 0($s3)
	#incrimentcounter
	addi $t9, $t9, 1
	#incriment to next vlae
	addi $s3, $s3, 4
	#find the specific value of the array
	beq $t9, $s0, stopLoop
	j correctionLoop

stopLoop:
	#change the char to a number to compare
	subi $t3, $s1, 48	
	beq $t0, $t3, ifCorrect
	j numberCalled
	 
ifCorrect:
	#subtract from the amount of errors
	sub $s6, $s6, 1
	#do the numba in green
	getAddressForNum($s0)
	lw $s2, 0($s7)
	# exit if cannot overwrite, checking to see if the pixel is a text color or if correct color
	beq $s2, 0x0017bf04, gameLoop
	lw $s2, 4($s7)
	# this checks for the number one
	beq $s2, 0x005e5e5e, gameLoop
	# now checks to see if user inputted a number before here
	beq $s2, 0x00858585, resetTileG
	lw $s2, 0($s7)
	beq $s2, 0x00858585, resetTileG
	# if it passes the test, change the char to a number
	subi $s1, $s1, 48
	#set color to green
	li $t5, 0x0017bf04
	displayNumber($s1, $s0)
	#set color back to gray
	li $t5, 0x00858585

	j gameLoop

complete:
	# jump here if board was completed correctly
	String("........... GAME COMPLETED ...........\n")
	String(".                                    .\n")
	String(".              YOU WIN!!             .\n")
	String(".        (????)?(????)        .\n")
	String(".                                    .\n")
	String(".      (1) Return To Main Menu       .\n")
	String(".      (2) Play Again                .\n")
	String(".      (3) Exit                      .\n")
	String(".                                    .\n")
	String("......................................\n")
	
	GetUserInput
	blt $t0, 1, invalidComp
	beq $t0, 1, main
	beq $t0, 2, createGrid
	beq $t0, 3, exit
	bgt $t0, 3, invalidComp
	
#invalid selection handling for when the game is completed
invalidComp:
	String("Invalid input. Please try again.")
	j complete
	
exit:
	# exit message yey
	String("\n    THANK YOU FOR PLAYING SUDOKU >V<\n")
	String("                by the Number Fight Club\n")
	li $v0, 10
	syscall
