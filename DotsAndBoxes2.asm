.text
.globl main
	main:
		jal interface
		
		loop:	# TEST can delete this line
			jal input
		
			move $a0, $v0		# 
			move $a1, $v1		# moves the inputs as args for create_line
			#addiu $a2, $0, 1
			
			jal create_line
			jal saveLine
		
			j loop			# TEST can delete this line
		
exit:
		li $v0, 10 			# terminate the program
		syscall
