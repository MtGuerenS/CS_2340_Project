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
		sw $ra, -4($sp)
		jal create_array
		lw $ra, -4($sp)
		move $t3, $s5
	calcmove:	
		div $t4, $t3, 4
		beq $t4, 0, next_move
	random:	move $a1, $t4
		li $v0, 42
		syscall
		move $t0, $a0
		mul $t0, $t0, 4
		bne $t3, $s5, calc2
		lw $t0, three_array($t0)
		j cont
	calc2:	bne $t3, $s7, calc1
		lw $t0, onezero_array($t0)
		j cont
	calc1:	lw $t0, two_array($t0)
	cont:	div $t0, $t0, 36
		move $a0, $t0
		and $t2, $t0, 1
		mfhi $t1
		srl $t1, $t1, 1
		bnez $t2, finish
		addi $t1, $t1, 1
	finish:	move $a1, $t1
		j return
		
	next_move:
		beq $t3, $s7, onezero
		move $t3, $s7
		j calcmove
	onezero:
		move $t3, $s6
		j calcmove
		
	exit:
		li $v0, 10 	# terminate the program
		syscall
		
# Random Move
# -----------

# Create array
# ------------
create_array:
		li $t0, 0			#starting index of array
		li $s5, 0
		li $s6, 0
		li $s7, 0
	loop:
		beq $t0, 468, return		#if end of array, return
		lw $t1, line_array($t0)	#load value in line array into t1
		bnez $t1, increment		#if line already exists, check next line
		div $t2, $t0, 36
		mfhi $t1
		and $t3, $t2, 1
		beqz $t3, horizontal
		srl $t2, $t2, 1
		mul $t2, $t2, 32
		add $t2, $t2, $t1
		lw $t3, box_array($t2)
		addi $t4, $t2, -4
		lw $t5, box_array($t4)
		beq $t1, 32, vbox2
		beq $t1, 0, vbox1
		bgt $t3, $t5, vbox1
	vbox2:	bne $t5, 3, vtry22
		sw $t0, three_array($s5)
		j done3
	vtry22:	bne $t5, 2, vtry21
		sw $t0, two_array($s6)
		j done2
	vtry21:	sw $t0, onezero_array($s7)
		j done1
	vbox1:	bne $t3, 3, vtry12
		sw $t0, three_array($s5)
		j done3
	vtry12:	bne $t3, 2, vtry11
		sw $t0, two_array($s6)
		j done2
	vtry11:	sw $t0, onezero_array($s7)
		j done1
	horizontal:
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
	hbox2:	bne $t5, 3, htry22
		sw $t0, three_array($s5)
		j done3
	htry22:	bne $t5, 2, htry21
		sw $t0, two_array($s6)
		j done2
	htry21:	sw $t0, onezero_array($s7)
		j done1
	hbox1:	bne $t3, 3, htry12
		sw $t0, three_array($s5)
		j done3
	htry12:	bne $t3, 2, htry11
		sw $t0, two_array($s6)
		j done2
	htry11:	sw $t0, onezero_array($s7)
		j done1
		
	done3:	addi $s5, $s5, 4
		j increment
	done2:	addi $s6, $s6, 4
		j increment
	done1:	addi $s7, $s7, 4
		j increment
		
	increment:
		addi $t0, $t0, 4		#increments index by 4
		j loop				#goes back to loop to check next line
				
return:	jr $ra
		
		
