.data
line_array:	.space 468
box_array:	.space 192

.text
.globl	saveLine
.globl	checkLine

saveLine:	li $t2, 1		#save line to array in memory ($s4 is the value we write in memory to represent line is taken)
		div $t1, $a1, 2		#divide user second input by 2 (this is cause user input will jump by 2 each time: (0,1)(0,3)(0,5)(0,7), etc)
		mul $t0, $a0, 9		#multiply user first input by 8 (because this is the row, and each row is 8 lines long)
		add $t0, $t0, $t1	#add 8*row and col value
		sll $t0, $t0, 2		#multiply by 4 because each word is 4 bytes
		sw $t2, line_array($t0)	#store 1 in array
		
		div $t3, $a0, 2
		mul $t3, $t3, 8
		add $t3, $t3, $t1
		sll $t3, $t3, 2
		beq $a0, 12, saveb2
		beq $a0, 16, saveb2
		lw $t4, box_array($t3)
		addi $t4, $t4, 1
		sw $t4, box_array($t3)
	saveb2:	beq $a0, 0, return
		beq $a1, 0, return
		and $t5, $a0, 1
		beqz $t5, hori
		addi $t3, $t3, -4
		lw $t4, box_array($t3)
		addi $t4, $t4, 1
		sw $t4, box_array($t3)
		j return
	hori:	addi $t3, $t3, -32
		lw $t4, box_array($t3)
		addi $t4, $t4, 1
		sw $t4, box_array($t3)
		j return		#return to jal instruction
		
checkLine:	li $t2, -1
		sw $t2, -4($sp)
		sw $t2, -8($sp)
		sw $t2, -12($sp)
		sw $t2, -16($sp)
		and $t5, $a0, 1
		div $t3, $a0, 2
		div $t8, $a1, 2		#divide user second input by 2 (this is cause user input will jump by 2 each time: (0,1)(0,3)(0,5)(0,7), etc)
		mul $t3, $t3, 8
		add $t3, $t3, $t8
		sll $t3, $t3, 2
		lw $t4, box_array($t3)
		beqz $t5, checkh
		beq $a1, 16, check2
		bne $t4, 3, check2
		addi $t6, $a0, -1
		sw $t6, -4($sp)
		sw $a1, -8($sp)
	check2:	beq $a1, 0, return
		addi $t3, $t3, -4
		lw $t4, box_array($t3)
		bne $t4, 3, return
		addi $t6, $a0, -1
		addi $t7, $a1, -2
		sw $t6, -12($sp)
		sw $t7, -16($sp)
		j return
	checkh:	beq $a0, 12, check3
		bne $t4, 3, check3
		addi $t6, $a1, -1
		sw $a0, -4($sp)
		sw $t6, -8($sp)
	check3:	beq $a0, 0, return
		addi $t3, $t3, -32
		lw $t4, box_array($t3)
		bne $t4, 3, return
		addi $t6, $a0, -2
		addi $t7, $a1, -1
		sw $t6, -12($sp)
		sw $t7, -16($sp)
		
return:		jr $ra			#return

