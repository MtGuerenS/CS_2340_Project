.data
	row_prompt: .asciiz "Enter the ROW number for you move: "
	col_prompt: .asciiz "Enter the COLUMN number for you move: "
	err_msg:    .asciiz "Invalid move. Select another line.\n"

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
    # if row and col are both even/odd, return false in $v0
    input_eval:

        xor $t0, $a0, $a1    	# even num starts with 0 odd with 1, case would be true
        and $t0, $t0, 1        	# gets the LSb (ie xxxxx0)
        add $v0, $t0, $0    	# returns the T/F value
        beqz $v0, error	
        blt $a0, 0, error	#jumps to error if row input is less than 0
        blt $a1, 0, error	#jumps to error if column input is less than 0
        bgt $a0, 12, error	#jumps to error if row input is greater than 12
        bgt $a1, 16, error	#jumps to error if column input is greater than 16

#        sle $v0, $0, $a0    	#
#        beqz $v0, error     	# if row num is < 0, branch

#        addiu $t0, $0, 13	# sets $t0 to 13
#        slt $v0, $a0, $t0    	#
#        beqz $v0, error     	# if row num is > 12, branch

#        sle $v0, $0, $a1    	#
#        beqz $v0, error     	# if col num is < 0, branch

#        addiu $t0, $0, 17    	# sets $t0 to 17
#        slt $v0, $a1, $t0    	#
#        beqz $v0, error     	# if col num is > 16, branch
        
        sw $ra, -4($sp)	#saves return address to stack
        jal check_move		#checks if line is already taken, if $v1 = 0, not taken, if $v1 = 1, taken
        lw $ra, -4($sp)	#retrieves return address from stack
        bnez $v1, error	#returns an error if line is already taken

        j return

        error:
            	#move $t0, $v0	# stores result in temp register so it isnt changed

            	la $a0, err_msg	#
            	addiu $v0, $0, 4	# print error message
            	syscall   		#
            	
		li $v0, 0		#set $v0 to 0 because this is the error method and it should always return an error
		
            	#move $v0, $t0   	# restores the original value of $v0

    return: jr $ra

    exit:
        li $v0, 10       	# terminate the program
        syscall
