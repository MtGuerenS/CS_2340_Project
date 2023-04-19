.text
.globl main
	main:
		jal check_move
		jal interface
		
		loop:	# TEST can delete this line
			jal input
		
			move $a0, $v0		# 
			move $a1, $v1		# moves the inputs as args for create_line
			addiu $a2, $0, 0
			
			jal create_line
			jal check_move
			jal save_line
		
			j loop			# TEST can delete this line
		
		# example of using create_box
		li $a0, 0
		li $a1, 0
		li $a2, 0
		jal create_box
		
exit:
		li $v0, 10 			# terminate the program
		syscall
