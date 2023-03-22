.text
.globl main
	main:
		jal interface
		
		loop:	# TEST can delete
			jal input
		
			move $a0, $v0		# 
			move $a1, $v1		# moves the inputs as args for create_line
		
			jal create_line
		
			j loop			# TEST can delete
		
exit:
		li $v0, 10 			# terminate the program
		syscall
