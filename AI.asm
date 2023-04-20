.data	
.align 2
move_array:	.space 468

.text
.globl make_move
# Makes a Move
# ------------
	# Description: prioritizes boxes with 3 lines in it, then it goes for boxes with 0-1 lines, then it goes for boxes with 2 lines
	make_move:
		li $v0, 3
		sw $ra, -4($sp)
		jal create_array
		lw $ra, -4($sp)
		
		div $s5, $s5, 4
		beq $s5, 0, move_2
		move $a1, $s5
		li $v0, 42
		syscall
		move $t0, $a0
		mul $t0, $t0, 4
		lw $t0, move_array($t0)
		div $t0, $t0, 36
		move $a0, $t0
		and $t2, $t0, 1
		mfhi $t1
		srl $t1, $t1, 1
		bnez $t2, finish
		addi $t1, $t1, 1
	finish:	move $a1, $t1
		j return
		
	move_2:	li $v0, 0
		sw $ra, -4($sp)
		jal create_array
		lw $ra, -4($sp)
		
		div $s5, $s5, 4
		beq $s5, 0, move_3
		move $a1, $s5
		li $v0, 42
		syscall
		move $t0, $a0
		mul $t0, $t0, 4
		lw $t0, move_array($t0)
		div $t0, $t0, 36
		move $a0, $t0
		and $t2, $t0, 1
		mfhi $t1
		srl $t1, $t1, 1
		bnez $t2, finis
		addi $t1, $t1, 1
	finis:	move $a1, $t1
		j return
		
	move_3:	li $v0, 1
		sw $ra, -4($sp)
		jal create_array
		lw $ra, -4($sp)
		
		div $s5, $s5, 4
		beq $s5, 0, move_4
		move $a1, $s5
		li $v0, 42
		syscall
		move $t0, $a0
		mul $t0, $t0, 4
		lw $t0, move_array($t0)
		div $t0, $t0, 36
		move $a0, $t0
		and $t2, $t0, 1
		mfhi $t1
		srl $t1, $t1, 1
		bnez $t2, fini
		addi $t1, $t1, 1
	fini:	move $a1, $t1
		j return
		
	move_4:	li $v0, 2
		sw $ra, -4($sp)
		jal create_array
		lw $ra, -4($sp)
		
		div $s5, $s5, 4
		beq $s5, 0, return
		move $a1, $s5
		li $v0, 42
		syscall
		move $t0, $a0
		mul $t0, $t0, 4
		lw $t0, move_array($t0)
		div $t0, $t0, 36
		move $a0, $t0
		and $t2, $t0, 1
		mfhi $t1
		srl $t1, $t1, 1
		bnez $t2, fin
		addi $t1, $t1, 1
	fin:	move $a1, $t1
		j return
		
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
	loop:
		beq $t0, 468, return		#if end of array, return
		lw $t1, line_array($t0)	#load value in line array into t1
		bnez $t1, increment		#if line already exists, check next line
		div $t2, $t0, 36
		mfhi $t1
		beq $t1, 32, increment
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
	vbox2:	bne $t5, $v0, increment
		sw $t0, move_array($s5)
		addi $s5, $s5, 4
		j increment
	vbox1:	bne $t3, $v0, increment
		sw $t0, move_array($s5)
		addi $s5, $s5, 4
		j increment
	horizontal:
		srl $t2, $t2, 1
		mul $t2, $t2, 32
		add $t2, $t2, $t1
		lw $t3, box_array($t2)
		addi $t4, $t2, -32
		lw $t5, box_array($t4)
		blt $t4, 0, hbox1
		bgt $t2, 192, hbox2
		bgt $t3, $t5, hbox1
	hbox2:	bne $t5, $v0, increment
		sw $t0, move_array($s5)
		addi $s5, $s5, 4
		j increment
	hbox1:	bne $t3, $v0, increment
		sw $t0, move_array($s5)
		addi $s5, $s5, 4
		
	increment:
		addi $t0, $t0, 4		#increments index by 4
		j loop				#goes back to loop to check next line
				
return:	jr $ra
		
		
