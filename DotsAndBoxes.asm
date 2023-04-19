.text
.globl main
.globl switchPlayer
	#a2 = player turn (0 for blue, 1 for red)
	main:
		jal check_move
		jal interface
		
		li $a2, 0
		
		loop:	# TEST can delete this line
			jal input
		
			move $a0, $v0		# 
			move $a1, $v1		# moves the inputs as args for create_line
			
			jal create_line
			jal check_move
			jal save_line
			jal switchPlayer
			
			j loop			# TEST can delete this line
		
		# example of using create_box
		li $a0, 6
		li $a1, 8
		li $a2, 0
		jal create_box
	
switchPlayer:	addi $a2, $a2, 1
		and $a2, $a2, 1
		jr $ra

exit:
		li $v0, 10 			# terminate the program
		syscall
