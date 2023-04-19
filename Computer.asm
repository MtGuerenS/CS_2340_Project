.data
	

.text
.globl find_01lines

# Makes a Move
# ------------
	# Description: prioritizes boxes with 3 lines in it, then it goes for boxes with 0-1 lines, then it goes for boxes with 2 lines
	# $v0 = row num
	# $v1 = col num
	make_move:
		#la $t0, box_array
		#li $t1, -1
		#li $t2, 2
		#lp_fill:
		#	add $t1, $t1, 1
		#	sw $t2, 0($t0)
		#	addi $t0, $t0, 4
		#	bne $t1, 192, lp_fill # TEST CAN DELETE
		
		#li $t0, 2		#
		#sw $t0, box_array 	# TEST CAN DELETE
	
		lw $a0, display_end	# sets bass address to after display
		jal find_3lines	
		
		beqz $v0, move_01	# if there are no boxes with 3 lines go to next
		j exit
	
	move_01:
		sll $v0, $v0, 2		# makes size word aligned
		add $v1, $v0, $v1 	# word aligned size + base address = address of next elements
		
		move $a0, $v1		# sets bass address to after 3 lines array
		jal find_01lines
		
		beqz $v0, move_2	# if there are no boxes with 3 lines go to next
		j exit
		
	move_2:
		sll $v0, $v0, 2		# makes size word aligned
		add $v1, $v0, $v1 	# word aligned size + base address = address of next elements
		
		move $a0, $v1		# sets bass address to after 0/1 lines array
		jal find_2lines
		
	exit:
		li $v0, 10 	# terminate the program
		syscall
		
# Random Move
# -----------

# Finds Boxes with Three Lines
# ----------------------------
	# Description: Creates an array filled with the scalar coords of boxes with 3 lines
	# $a0 = base address
	# $v0 = size of array
	# $v1 = address of first element
	find_3lines:
		addi $sp, $sp, -4 	#
		sw $ra, 0($sp)		# preserves original return address
				
		move $v1, $a0		# start here in heap so we don't overrite any pixels, $v0 == base address
		
		li $a0, 3		# sets args $a0/1 to 3
		li $a1, 3		# will create an array of boxes with 3 lines
		move $a2, $v1		# $a2 = base address
		
		jal create_array
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		move $v0, $a0
	
		lw $ra, 0($sp)		#
		addi $sp, $sp, 4	# goes back to where it was excuted
		jr $ra			#
		
# Finds Boxes with Zero and One Lines
# ----------------------------
	# Description: Creates an array filled with the scalar coords of boxes with 0 and 1 lines
	# $a0 = base address
	# $v0 = size of array
	# $v1 = address of first element
	find_01lines:
		addi $sp, $sp, -4 	#
		sw $ra, 0($sp)		# preserves original return address
				
		move $v1, $a0		# start here in heap so we don't overrite any pixels, $v0 == base address
		
		li $a0, 0		# sets args $a0 to 0 and $a1 to 1
		li $a1, 1		# will create an array of boxes with 3 lines
		move $a2, $v1		# $a2 = base address
		
		jal create_array
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		move $v0, $a0
	
		lw $ra, 0($sp)		#
		addi $sp, $sp, 4	# goes back to where it was excuted
		jr $ra			#
		
# Finds Boxes with Two Lines
# ----------------------------
	# Description: Creates an array filled with the scalar coords of boxes with 2 lines
	# $a0 = base address
	# $v0 = size of array
	# $v1 = address of first element
	find_2lines:
		addi $sp, $sp, -4 	#
		sw $ra, 0($sp)		# preserves original return address
				
		move $v1, $a0		# start here in heap so we don't overrite any pixels, $v0 == base address
		
		li $a0, 2		# sets args $a0 to 0 and $a1 to 1
		li $a1, 2		# will create an array of boxes with 3 lines
		move $a2, $v1		# $a2 = base address
		
		jal create_array
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		move $v0, $a0
	
		lw $ra, 0($sp)		#
		addi $sp, $sp, 4	# goes back to where it was excuted
		jr $ra			#
		
# Creates Array of Boxes with N and M Lines
# -----------------------------------------
	# $a0 = num lines in box to find
	# $a1 = num lines in box to find (if not different you must make it the same)
	# $a2 = base address of your array
	# $v0 = size of array
	create_array:
		la $t0, box_array	# $t0 = address of box array
		addi $t1, $t0, 192 	# $t1 = end condition -- (address of array + space allocated)
		li $v0, 0		# $v0 = size of new array
		
		lp_box:
			beq $t0, $t1, return 	# if counter == size of box array, exit loop
			lw $t2, 0($t0)		# $t2 = element in box array
			
			beq $a0, $t2, match	# check if args match curent element
			beq $a1, $t2, match	# if they do, go to match
			
			addi $t0, $t0, 4	# increment iterator
			j lp_box
			
			match:
				sll $t3, $v0, 2		# bit adjusted size of array
				add $t3, $a2, $t3	# $t3 = base address + size of array
				
				la $t2, box_array	# $t2 = address of box array
				sub $t2, $t2, $t0	# $t2 = address of box array - current address in bx arry = index
				sw $t2, 0($t3)		# stores index in new array
				
				addi $v0, $v0, 1	# increment size of array
				addi $t0, $t0, 4	# increment iterator
				j lp_box
		
		return:
			jr $ra
		
		