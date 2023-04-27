.data
prompt:		.asciiz "Which game mode would you like to play?\n2 for 2P, 1 for 1P, 0 for 0P: "

.text
.globl main
.globl switchPlayer
	#a2 = player turn (0 for blue, 1 for red)
	#s3 = player score
	#s4 = computer score
	main:
		li $s3, 0		#reset scores
		li $s4, 0
		jal mem_reset		#reset memory
		
		li $v0, 4		#print prompt
		la $a0, prompt
		syscall
		
		li $a1, 3		#get startscreen
		jal startScreen
		
		
		jal interface		#print interface
		
		li $a2, 0
		
		loop:	# TEST can delete this line
			add $t0, $s3, $s4		#gets sum of player score and computer score
			beq $t0, 48, endScreen		#if the sum is 48, jump to game over
			
			beq $s7, 2, p1		#if user chooses 2 player, skip to player input
			beq $s7, 0, comp	#if user chooses 0 players, skip to comp
			beqz $a2, p1		#if user chooses 1 player, go to player input when its player's turn
		comp:	li $v0, 32		#add delay of 300 milliseconds
			la $a0, 300
			syscall
			
			jal make_move		#computer AI makes move
			j update		#jump to update
			
		p1:	jal input		#get player input
		
			move $a0, $v0		# 
			move $a1, $v1		# moves the inputs as args for create_line
			
		update:	jal create_line		#creates a line on interface
			#jal move_sound
			jal check_box		#checks if new line will create boxes
			jal save_line		#saves the line into the line array and increments the values in the box array
			jal switchPlayer	#switches player turn
			
			j loop			# TEST can delete this line
		
		# example of using create_box
		li $a0, 6
		li $a1, 8
		li $a2, 0
		jal create_box
	
switchPlayer:	addi $a2, $a2, 1		#add 1 to a2
		and $a2, $a2, 1			#get only least significant bit
		jr $ra				#return

exit:
		li $v0, 10 			# terminate the program
		syscall
