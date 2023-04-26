.data	
.align 2
onezero_array:	.space 468
space:		.space 468
two_array:	.space 468
space2:		.space 468
three_array:	.space 468

.text
.globl make_move
# Makes a Move
# ------------
	# Description: prioritizes boxes with 3 lines in it, then it goes for boxes with 0-1 lines, then it goes for boxes with 2 lines
	make_move:
		sw $ra, -4($sp)			#save return address to stack
		jal create_array		#call create array to get all the possible moves
		lw $ra, -4($sp)			#get return address from stack
		move $t3, $s5			#s5 is the number of moves that will create a box. Move that to t3
	calcmove:	
		div $t4, $t3, 4			#divide t3 by 4
		beq $t4, 0, next_move		#if there are no moves that will create a box, check moves that will create a 2 lined or 1 lined box
	random:	move $a1, $t4			#if there is a move that creates the specified box, load number of moves possible
		li $v0, 42			#generate random number from the number of possible moves that satisfy how many lines we want
		syscall	
		move $t0, $a0			#get random number, move to $t0
		mul $t0, $t0, 4			#multiply random number by 4 cause each word in array is 4 bytes
		bne $t3, $s5, calc2		#branch if we're not looking for moves that affect 3 lined boxes
		lw $t0, three_array($t0)	#else, get the value at the index given by the random number from the three lined array
		j cont				#jump to continue
	calc2:	bne $t3, $t8, calc1		#branch if we're not looking for moves that affect 0 or 1 lined boxes
		lw $t0, onezero_array($t0)	#else, get value from 1,0 array
		j cont				#jump to continue
	calc1:	lw $t0, two_array($t0)		#if not affecting 0, 1, or 3 lined boxes, must affect 2 lined boxes. Get value from 2 line array
	cont:	div $t0, $t0, 36		#divide value by 36 to get the row (9 columns in each row, 4 bytes each, remainder goes away)
		move $a0, $t0			#move row value to $a0
		and $t2, $t0, 1			#get row is odd or even
		mfhi $t1			#get remainder from previous division by 36
		srl $t1, $t1, 1			#divide by 2
		bnez $t2, finish		#branch if odd
		addi $t1, $t1, 1		#if row is even, add 1 to col
	finish:	move $a1, $t1			#put column value into $a1
		j return			#return
		
	next_move:				#checks next possible available moves
		beq $t3, $t8, onezero		#branch if we just checked for lines that affect 0 or 1 line boxes
		move $t3, $t8			#if we didn't just check for 0 or 1 line boxes, check for 0,1 line boxes
		j calcmove			#jump to calcmove
	onezero:
		move $t3, $s6			#if we checked 0,1 line boxes, then check 2  line boxes
		j calcmove			#jump to calcmove
		
	exit:
		li $v0, 10 	# terminate the program
		syscall
		
# Random Move
# -----------

# Create array
# ------------
create_array:
		li $t0, 0			#starting index of array
		li $s5, 0			#counter for index of three line boxes
		li $s6, 0			#counter for index of two line boxes
		li $t8, 0			#counter for index of 0,1 line boxes
	loop:
		beq $t0, 468, return		#if end of array, return
		lw $t1, line_array($t0)	#load value in line array into t1
		bnez $t1, increment		#if line already exists, check next line
		div $t2, $t0, 36		#get index by dividing $t0 by 4
		mfhi $t1			#get remainder from previous division
		and $t3, $t2, 1			#get if row is odd or even
		beqz $t3, horizontal		#branch if row  # is even
		srl $t2, $t2, 1			#divide column number by 2
		mul $t2, $t2, 32		#multiply column number by 32
		add $t2, $t2, $t1		#add column and row values to get index
		lw $t3, box_array($t2)		#get how many lines the box to the right of vertical line has
		addi $t4, $t2, -4		#subtract 4 from column number
		lw $t5, box_array($t4)		#get how many lines the box to the left of vertical line has
		beq $t1, 32, vbox2		#branch if equal to 32, these are the lines at edge of grid, so they don't have a right box
		beq $t1, 0, vbox1		#branch if equal to 0, these are the lines at edge of grid, so they don't have a left box
		bgt $t3, $t5, vbox1		#if right box has more lines that left box, branch to vbox1
	vbox2:	bne $t5, 3, vtry22		#if left box has more, check if the number of lines the left box has is 3
		sw $t0, three_array($s5)	#if so, save $t0 to the three array
		j done3				#jump to done3
	vtry22:	bne $t5, 2, vtry21		#if number of lines the left box has is not 2, branch
		sw $t0, two_array($s6)		#else, save to possible 2 line moves
		j done2				#jump to done2
	vtry21:	sw $t0, onezero_array($t8)	#save $t0 to 0,1 line moves
		j done1				#jump to done1
	vbox1:	bne $t3, 3, vtry12		#same thing but with right box bigger
		sw $t0, three_array($s5)
		j done3
	vtry12:	bne $t3, 2, vtry11
		sw $t0, two_array($s6)
		j done2
	vtry11:	sw $t0, onezero_array($t8)
		j done1
	horizontal:				#same thing but for horizontal lines
		beq $t1, 32, increment
		srl $t2, $t2, 1
		mul $t2, $t2, 32
		add $t2, $t2, $t1
		lw $t3, box_array($t2)
		addi $t4, $t2, -32
		lw $t5, box_array($t4)
		blt $t4, 0, hbox1
		bgt $t2, 192, hbox2
		bgt $t3, $t5, hbox1
	hbox2:	bne $t5, 3, htry22		#horizontal line, top box has more lines
		sw $t0, three_array($s5)
		j done3
	htry22:	bne $t5, 2, htry21
		sw $t0, two_array($s6)
		j done2
	htry21:	sw $t0, onezero_array($t8)
		j done1
	hbox1:	bne $t3, 3, htry12		#bottom box has more lines
		sw $t0, three_array($s5)
		j done3
	htry12:	bne $t3, 2, htry11
		sw $t0, two_array($s6)
		j done2
	htry11:	sw $t0, onezero_array($t8)
		j done1
		
	done3:	addi $s5, $s5, 4		#increments the 3 line index
		j increment
	done2:	addi $s6, $s6, 4		#increments the 2 line index
		j increment
	done1:	addi $t8, $t8, 4		#increments the 0,1 line index
		j increment
		
	increment:
		addi $t0, $t0, 4		#increments index by 4
		j loop				#goes back to loop to check next line
				
return:	jr $ra
		
		
