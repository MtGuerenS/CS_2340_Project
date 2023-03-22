.data
	display_start: .word 0x10040000
	backgrd_end:   .word 0x10043000
	display_end:   .word 0x10044000

.text
.globl interface
.globl create_line
# Creates the Interface for Dots and Boxes
# ----------------------------------------
	# Call the subroutine below to set up the bitmap image
	interface:
		lw $s0, display_start	# stores START of display
		lw $s1, backgrd_end	# stores START of background
		lw $s2, display_end	# stores END of display
		
		addi $sp, $sp, -4 	#
		sw $ra, 0($sp)		# preserves original return address
		
		jal background
		
		jal dots
		
		lw $ra, 0($sp)		#
		addi $sp, $sp, 4	# goes back to where it was excuted
		jr $ra			#

# Creates a White Background on the Bitmap
# ----------------------------------------
	background:
		add $t0, $s0, $0	# creates copy of the start of display to increment it
		li $t1, 0xffffff	# $t3 stores the color 'WHITE'
		li $t2, 0xeeeeee	# $t3 stores the color 'GREY'
		# bkgd_loop:
		#	sw $t1, 0($t0)		# makes the pixel white at $t0
		#	addi $t0, $t0, 4	# increments display pointer by 4
		#	bne $t0, $s1, bkgd_loop	# while display start < background end, loop
		fill_space:
			sw $t2, 0($t0)		# makes the pixel grey at $t0
			addi $t0, $t0, 4	# increments display pointer by 4
			bne $t0, $s2, fill_space	# while display start < display end, loop
		jr $ra
	
# Create the Dots for the Interface
# ---------------------------------
	dots:
		add $t0, $s0, 1040	# sets the address of the first dot (4*256+16)
		li $t1, 0x000000	# $t3 stores the color 'BLACK'
		add $t2, $s0, 1279	# t2 is the stopping point for creating dots in col (4*256+255)
		j dots_col
			
		dots_row:
			bge $t0, $s1, return	# exit the loop if col stopping point > background end, return
			addi $t2, $t2, 2303	# updates the col stopping point to the next row
			addi $t0, $t0, 2048	# updates where the row will start
			dots_col:
				sw $t1, 0($t0)		# makes the pixel black at $t0
				addi $t0, $t0, 32	# increments by 8 pixels
				blt $t0, $t2, dots_col	# while display pointer < background end, loop
				j dots_row		# else 
		return:
			jr $ra
		
# Create Line 
# -----------
	# a0 = row num
	# a1 = col num
	# a2 = player num
	# Notes: a0 and a1 is the player move and a2 determines the color
	create_line:
		and $t1, $a0, 1		# if the row is odd then is is a vert line
		bnez, $t1, vert_line	# if the coord is a vert line, create one
		horz_line:
			jr $ra
		vert_line:
			# The few blocks are trying to find the end pixel for the line and store it in $t1
			addi $t1, $a0, 1	# turns row num given to num from 1-5
			srl $t1, $t1, 1		# this makes it easy to multiply,  t1 = end of line
			
			addi $t2, $t1, -1	#
			mul $t2, $t2, 256	# gets the offset from the pixel
			
			mul $t1, $t1, 2048	# 
			add $t1, $t1, $t2	# y coord of the end of vert line
			
			add $t2, $a1, 1		# turns col num given to num from 1-5
			srl $t2, $t2, 1		# this makes it easy to multiply,  t1 = end of line
			
			mul $t2, $t2, 32	#
			add $t0, $s0, 1040	# x coord of the end of vert line
			
			add $t1, $t1, $t2	#
			add $t1, $t0, $t1	# combines the x and y coods to make end point
			
			addi $t0, $t1, -2048	# sets the start pixel for loop 8 pixels down (8*4*64)
			li $t2, 0xff0000	# $t3 stores the color 'RED'
			lp_vert:
				addi $t0, $t0, 256	# go down one pixel
				bgt $t0, $t1, return	# if start > end, stop
				sw $t2, 0($t0)		# color the pixel at $t0
				j lp_vert
		jr $ra
		
	exit:
		li $v0, 10 			# terminate the program
		syscall
