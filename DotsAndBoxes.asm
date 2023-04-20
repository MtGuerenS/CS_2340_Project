.data
game_over:	.asciiz "Game Over!\n"
player_wins:	.asciiz "Player Wins!"
computer_wins:	.asciiz "Computer Wins!"
tie:		.asciiz "Tie!"

.text
.globl main
.globl switchPlayer
	#a2 = player turn (0 for blue, 1 for red)
	#s3 = player score
	#s4 = computer score
	main:
		jal interface
		
		li $a2, 0
		
		loop:	# TEST can delete this line
			add $t0, $s3, $s4		#gets sum of player score and computer score
			beq $t0, 48, gameOver		#if the sum is 48, jump to game over
			
			beqz $a2, p1
			li $v0, 32
			la $a0, 1000
			syscall
			
			jal make_move
			j update
			
		p1:	jal input
		
			move $a0, $v0		# 
			move $a1, $v1		# moves the inputs as args for create_line
			
		update:	jal create_line		#creates a line on interface
			jal check_box		#checks if new line will create boxes
			jal save_line		#saves the line into the line array and increments the values in the box array
			jal switchPlayer	#switches player turn
			
			j loop			# TEST can delete this line
		
		# example of using create_box
		li $a0, 6
		li $a1, 8
		li $a2, 0
		jal create_box
	
switchPlayer:	addi $a2, $a2, 1
		and $a2, $a2, 1
		jr $ra
		
gameOver:	li $v0, 4			#print "Game Over!\n"
		la $a0, game_over
		syscall
		
		bgt $s3, $s4, player		#if player score greater than computer score, player wins
		blt $s3, $s4, computer		#if player score less than computer score, computer wins
		la $a0, tie			#if neither (scores are equal) print tie message
		syscall
		j exit

	player:	
		la $a0, player_wins		#print player wins message
		syscall
		j exit
		
	computer:	
		la $a0, computer_wins		#print computer wins message
		syscall
		j exit

exit:
		li $v0, 10 			# terminate the program
		syscall
