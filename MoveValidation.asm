.data
.globl line_array
.globl box_array
line_array:	.space 468
box_array:	.space 192

.text
.globl	save_line
.globl	check_box
.globl	check_move
.globl 	mem_reset

mem_reset:
		li $t0, 0			#reset values of line_array and box_array to 0
		li $t1, 0
		li $t2, 0
	loop1:	sw $t0, line_array($t1)
		addi $t1, $t1, 4
		bne $t1, 468, loop1
	loop2:	sw $t0, box_array($t2)
		addi $t2, $t2, 4
		bne $t2, 192, loop2
		jr $ra

save_line:	
		li $t2, 1			#save line to array in memory ($s4 is the value we write in memory to represent line is taken)
		div $t1, $a1, 2			#divide user second input by 2 (this is cause user input will jump by 2 each time: (0,1)(0,3)(0,5)(0,7), etc)
		mul $t0, $a0, 9			#multiply user first input by 9 (because this is the row, and each row is 8 lines long)
		add $t0, $t0, $t1		#add 8*row and col value
		sll $t0, $t0, 2			#multiply by 4 because each word is 4 bytes
		sw $t2, line_array($t0)	#store 1 in array
		
		div $t3, $a0, 2			#divide rol num by 2 (cause there only 6 rows of boxes)
		mul $t3, $t3, 8			#multiply that by 8 (cause there are 8 columns of boxes and we want to go to the right row)
		add $t3, $t3, $t1		#add that to column number (cause we want to go to the right column in the right row)
		sll $t3, $t3, 2			#multiply by 4 (cause each value is 4 bytes)
		
		beq $a0, 12, save_box2		#if row num is  12, there is only 1 box to save, so we jump to the save box 2
		beq $a1, 16, save_box2		#if col num is 12, there is only 1 box to save, so we jump to the save box 2
		
		lw $t4, box_array($t3)		#we get the current value in the box array
		addi $t4, $t4, 1		#we add 1 to that value
		sw $t4, box_array($t3)		#save the value back into box array
		
	save_box2:				#this is the second box
		beq $a0, 0, return		#if row num is 0, there is only 1 box to save, and we've already saved it, so return
		beq $a1, 0, return		#if col num is 0, there is only 1 box to save, and we've already saved it, so return
		
		and $t5, $a0, 1			#get the least significant digit of row input
		beqz $t5, hori			#if row is even, line is horizontal, so we jump to the horizontal save area
		addi $t3, $t3, -4		#for vertical lines, the second box will be 1 box before, so add -4 to current box index
		lw $t4, box_array($t3)		#get the value from box array
		addi $t4, $t4, 1		#increment by 1
		sw $t4, box_array($t3)		#save new value to box array
		j return			#return
		
	hori:	addi $t3, $t3, -32		#for horizontal boxes, the second box will be above, so -32 (there are 8 boxes in a row)
		lw $t4, box_array($t3)		#load value in box array
		addi $t4, $t4, 1		#increment value in box array
		sw $t4, box_array($t3)		#save new value into box array
		j return			#return to jal instruction

# Checks Move
# -----------
	# $a0 = row num
	# $a1 = col num
	# Description: checks to see if line is already taken
	check_move:
		li $v1, 0			#set $v1 to 0, both to erase previous value and set default value
		div $t1, $a1, 2			#divide user second input by 2 (this is cause user input will jump by 2 each time: (0,1)(0,3)(0,5)(0,7), etc)
		mul $t0, $a0, 9			#multiply user first input by 9 (because this is the row, and each row is 8 lines long)
		add $t0, $t0, $t1		#add 8*row and col value
		sll $t0, $t0, 2			#multiply by 4 because each word is 4 bytes
		lw $t1, line_array($t0)	#load value from line array
		bnez $t1, error			#if line value not 0, line is already taken, go to error
		j return			#return
		
	error:	li $v1, 1			#set v1 to 1
		j return			#return
	
# Checks Box
# -----------
	# $a0 = row num
	# $a1 = col num
	# Description: checks to see if the line placed makes a box, and if it does then place the box
	check_box:
		addi $sp, $sp, -4    	#updates the stack pointer
		sw $ra, 0($sp)        	#places return address on stack

        	move $s5, $a0		#save user row input
        	move $s6, $a1		#save user col input

        	jal check_line		#call check line (will get 2 coordinates for 2 boxes and store then in -4, -8, -12, -16 of stack

        	lw $a0, -4($sp)        # gets x cood of box 1
        	lw $a1, -8($sp)        # gets y cord of box 1
        	beq $a0, -1, box2	#if no box complete, go to box 2
        	li $t9, 1		#after box complete, still same person's turn
        	jal create_box		#draw in box

	box2:        
		lw $a0, -12($sp)    	#gets x cood of box 2
        	lw $a1, -16($sp)    	#gets y cord of box 2
        	beq $a0, -1, switch	#if no box complete, jump to switch
        	li $t9, 1		#after box complete, still same person's turn
        	jal create_box 		#create box

	switch:
		bne $t9, 1, recover	#if we did not create a box, don't switch player turn
		li $t9, 0		#set $t9 to 0 for future tests
		jal switchPlayer	#switch player turn
		
	recover:	
		move $a0, $s5		#recover row input
        	move $a1, $s6		#recover col input

        	lw $ra, 0($sp)        	#gets return address from stack
        	addi $sp, $sp, 4    	#updates the stack pointer

        	j return
				
check_line:	li $t2, -1		#if no box complete, return -1
		sw $t2, -4($sp)		#sets default return to -1
		sw $t2, -8($sp)
		sw $t2, -12($sp)
		sw $t2, -16($sp)
		
		and $t5, $a0, 1		#gets least significant bit
		div $t3, $a0, 2		#divide row input by 2 (cause only 6 rows of boxes)
		div $t8, $a1, 2		#divide user second input by 2 (this is cause user input will jump by 2 each time: (0,1)(0,3)(0,5)(0,7), etc)
		mul $t3, $t3, 8		#mul by 8 because each row has 8 boxes
		add $t3, $t3, $t8	#add row and col to get to right row and right col
		sll $t3, $t3, 2		#multiply by 4 cause each word is 4 bytes
		
		lw $t4, box_array($t3)	#get value at box array
		beqz $t5, checkh	#if least significant bit is 0, line is horizontal
		beq $a1, 16, check2	#if col input is 16, we only need to check 1 box, so branch to check2
		bne $t4, 3, check2	#if value in box array is not 3, go to check2
		addi $t6, $a0, -1	#if value is in box array, we have completed a box
		sw $t6, -4($sp)		#set stack values to the coordinates of the top left corner of box
		sw $a1, -8($sp)
		
	check2:	beq $a1, 0, return	#if col value is 0, we only need to check 1 box nad that box has been checked, so return
		addi $t3, $t3, -4	#we get to location of second box
		lw $t4, box_array($t3)	#get value in box array
		bne $t4, 3, return	#if value is not 3, return
		addi $t6, $a0, -1	#if value is 3, box is completed
		addi $t7, $a1, -2
		sw $t6, -12($sp)	#save box coordinates to stack
		sw $t7, -16($sp)
		j return
		
	checkh:	beq $a0, 12, check3	#if row is 12, we only need to check 1 box, go to check3
		bne $t4, 3, check3	#if value in box array is not 3, check second box
		addi $t6, $a1, -1	#if value is 3, we completed a box
		sw $a0, -4($sp)		#save box coordinates to stack
		sw $t6, -8($sp)
		
	check3:	beq $a0, 0, return	#if row is 0, we only need to check 1 box and we've already checked it, so return
		addi $t3, $t3, -32	#get box 2 location
		lw $t4, box_array($t3)	#get value from box array
		bne $t4, 3, return	#if value is not 3, return
		addi $t6, $a0, -2	#if value is 3
		addi $t7, $a1, -1
		sw $t6, -12($sp)	#save box coordinates to stack
		sw $t7, -16($sp)
		
return:		jr $ra			#return

