.data
	row_prompt: .asciiz "Enter the ROW number for you move: "
	col_prompt: .asciiz "Enter the COLUMN number for you move: "
	err_msg:    .asciiz "The row _ and column _ is an invalid move.\n"

.text
.globl input
# Input
# ----
	# prompts the user enter a value
	# checks to see if its valid
	# returns the values
	input:
		addi $sp, $sp, -4 	#
		sw $ra, 0($sp)		# preserves original return address
	
		addi $sp, $sp, -4 	#
		sw $s0, 0($sp)		# 
		addi $sp, $sp, -4 	# preserves saved resgisters
		sw $s1, 0($sp)		#
		inpt_loop:
			addiu $v0, $0, 4	#
			la $a0, row_prompt	# prints the row prompt
			syscall			#
		
			addiu $v0, $0, 5	#
			syscall			# reads row num and stores it in s0
			add $s0, $v0, $0	#
		
			addiu $v0, $0, 4	#
			la $a0, col_prompt	# prints the column prompt
			syscall			#
		
			addiu $v0, $0, 5	#
			syscall			# reads col num and stores it in s1
			add $s1, $v0, $0	#
	
			move $a0, $s0		#
			move $a1, $s1		# sets the row and col as args
		
			jal input_eval		# checks to see if the row and col are valid lines
		
			beqz $v0, inpt_loop	# if returns false, repeat until valid
		
			move $v0, $s0		# row
			move $v1, $s1		# col
		
			lw $s1, 0($sp)		#
			addi $sp, $sp, 4	#
			lw $s0, 0($sp)		# returns the original saved registers
			addi $sp, $sp, 4	#
		
			lw $ra, 0($sp)		#
			addi $sp, $sp, 4	# goes back to where it was excuted
			jr $ra			#
		
# Input Evaluation
# ----------------
	# a0 = row num
	# a1 = col num
	# if row and col are both even/odd, return false
	input_eval:
	
		xor $t0, $a0, $a1	# even num starts with 0 odd with 1, case would be true
		and $t0, $t0, 1		# gets the LSb (ie xxxxx0)
		add $v0, $t0, $0	# returns the T/F value
		
		beqz $v0, error
		#bgt $a1, 16, error	#if inputs are outside the boundaries of the grid, return error message
		blt $a1, 0, error	
		#bgt $a0, 12, error
		blt $a0, 0, error	
		
	return: jr $ra
		
		
	error:	la $a0, err_msg		#
		addiu $v0, $0, 4	# print error message
		syscall		# moves the right value to be returned
		
		li $v0, 0	#tells computer to re-prompt the user
		
		j return
		
	exit:
		li $v0, 10 			# terminate the program
		syscall
