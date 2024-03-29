.data
	display_s: 	.word 0x10040000
	backgrd_e:   	.word 0x10042B00	# 4 bits * [(6 pixels * 6 lines + 7 dots) * 64 pixels]
	display_e:   	.word 0x10044000
	directions:	.asciiz "Enter 1 to play again. Enter 2 to quit: "
	sure:		.asciiz "Enter 5 to confirm choice\n"

.text
.globl endScreen
.globl blue_wins
.globl red_wins
.globl tied
# Creates the Interface for Dots and Boxes
# ----------------------------------------
	# Call the subroutine below to set up the bitmap image
	endScreen:
		lw $s0, display_s	# stores START of display
		lw $s1, backgrd_e	# stores START of background
		lw $s2, display_e	# stores END of display
		
		li $v0, 4		#print directions
		la $a0, directions
		syscall
		
		li $a1, 3		#set a1 value to 3, this is not any choice, so default screen starts with nothing selected
		
		jal black_out		#jump and link to blackout, randomly blacks out pixels on screen
		
		li $v0, 32		#set delay to 1000 milliseconds, or 1 second
		li $a0, 1000
		syscall
		li $t9, 0xffffff		#$t9 is set to white
		bgt $s3, $s4, player		#if player score greater than computer score, player wins
		blt $s3, $s4, computer		#if player score less than computer score, computer wins
		jal tied			#if tied, jump to tied
		j start				#jumpt to start

	player:	
		jal blue_wins			#player is blue, so jump and link to blue wins
		j start
		
	computer:	
		jal red_wins			#computer is red, so jump and link to red wins
		
	start:	li $t9, 0		# BLACK
		li $t1, 0xffffff	# WHITE
		
		li $t8, 3584		#offset between each choice
		
		bne $a1, 1, choice1	#if user input is 1, switch the colors to show selected
		li $t1, 0		# BLACK
		li $t9, 0xffffff	# WHITE
	choice1:	
		li $a0, 1
		add $t0, $s0, 4628
		jal end_choice
		li $t9, 0		# BLACK
		li $t1, 0xffffff	# WHITE
	
		bne $a1, 2, choice2	#if user input is 2, switch the colors to show selected
		li $t1, 0		# BLACK
		li $t9, 0xffffff	# WHITE
	choice2:
		li $a0, 2
		add $t0, $t0, $t8
		jal end_choice
		li $t9, 0		# BLACK
		li $t1, 0xffffff	# WHITE
		
		beq $a1, 3, input	#if a1 is 3 (only at the very beginning), branch
		li $v0, 4		#else, print sure
		la $a0, sure
		syscall
		
		move $s7, $a1		#save user input, to s7. If user confirms their choice, a1 will change, but we can use s7.
		
	input:	li $v0, 5		#read in integer
		syscall
		move $a1, $v0		#move to a1
		
		bne $a1, 5, start	#if user didn't confirm choice, restart
		
		bne $s7, 1, exit	#if user choice is not 1, exit
		j main
		
	exit:	li $v0, 10
		syscall

# Creates a White Background on the Bitmap
# ----------------------------------------
	background:
		add $t0, $s0, $0	# creates copy of the start of display to increment it
		li $t9, 0		# $t3 stores the color 'BLACK'
		li $t1, 0xffffff	# $t3 stores the color 'WHITE'
		fill_space:
			sw $t9, 0($t0)		# makes the pixel grey at $t0
			addi $t0, $t0, 4	# increments display pointer by 4
			bne $t0, $s2, fill_space	# while display start < display end, loop
		jr $ra

#	endScreen:
#		li $t9, 0
#		li $t8, 0
#	repeat:	li $a1, 4096
#		li $v0, 42
#		syscall
#		move $t1, $a0
#		sll $t1, $t1, 2
#		add $t0, $s0, $t1
#	next:	lw $t2, 0($t0)
#		bne $t0, $s2, loop
#		addi $t0, $s0, -4
#	loop:	addi $t0, $t0, 4
#		beqz $t2, next
#		li $v0, 32
#		li $a0, 3
#		syscall
#		sw $t9, -4($t0)
#		addi $t8, $t8, 1
#		bne $t8, 4000, repeat
#		j return
		
	black_out:				
		li $t9, 0		#save $t9 as black
		li $t8, 0		#t8 is a counter for how many pixels it has changed to black
	repeat:	li $a1, 4096		#4096 pixels in total, load that as upper limit in random
		li $v0, 42		#choose a random number from 0 to 4095
		syscall
		move $t1, $a0		#move random number to $t1
		sll $t1, $t1, 2		#multiply t1 by 4
		add $t0, $s0, $t1	#add t1 and s0 to get a random pixel
		lw $t2, 0($t0)		#get value at pixel
		beqz $t2, repeat	#if pixel is already black, repeat
		li $v0, 32		#else, delay by 1 millisecond 
		li $a0, 1
		syscall
		sw $t9, ($t0)		#change pixel to black
		addi $t8, $t8, 1	#increment pixels changed counter
		bne $t8, 3373, repeat	#if pixels changed not equal 3373, repeat
		j return		#return
			
	end_choice:
		addi $t3, $t0, 792			#offset from beginning of choice to the center where the text will be
		add $t2, $t0, 216			#add 216 to $t0 because that is width of choice
		ehorizontal:
			sw $t1, 0($t0)			#save color
			addi $t0, $t0, 4		#go to next pixel
			bne $t0, $t2, ehorizontal	#if not at end, repeat
		addi $t0, $t0, 32			#go to next line
		sw $t1, 4($t0)				#save a pixel
		add $t2, $t0, 216			#get end of line
		ehorizontal2:
			sw $t9, 8($t0)			#do the same thing as the first horizontal line
			addi $t0, $t0, 4
			bne $t0, $t2, ehorizontal2
		sw $t1, 8($t0)				#change color of another pixel
		addi $t0, $t0, 40			#add 40 to t0
		addi $t4, $t0, 1792			#add 1792 to t0, get end
	evertical:					#vertical lines
		sw $t1, 0($t0)				#save pixel
		addi $t5, $t0, 228			#get beginning of line
		einner_fill:				#fill the area between the 2 vertical lines with a different color
			sw $t9, 4($t0)			#save pixel
			addi $t0, $t0, 4		#go to next pixel
			bne $t0, $t5, einner_fill	#repeat
		sw $t1, 0($t0)				#save another pixel
		addi $t0, $t0, 28			#go to next line
		bne $t0, $t4, evertical		#if we're not at end of line, branch back
		
		sw $t1, 4($t0)				#save another pixel
		add $t2, $t0, 216			#get end of line
		ehorizontal3:				#create another horizontal line, fill in between
			sw $t9, 8($t0)
			addi $t0, $t0, 4
			bne $t0, $t2, ehorizontal3
		sw $t1, 8($t0)				#save another pixel
		
		addi $t0, $t0, 48			#go to next line
		add $t2, $t0, 216			#get end of line
		ehorizontal4:				#fill in between
			sw $t1, 0($t0)
			addi $t0, $t0, 4
			bne $t0, $t2, ehorizontal4
		addi $t0, $t0, -2776			#subtract $t0 by 2776 to get the its original value
			
		beq $a0, 2, quit			#if its option 2, branch to quit, else print play again
		
	play_again:
		addi $t3, $t3, 8	#offset
		sw $t1, 0($t3)		#P
		sw $t1, 4($t3)
		sw $t1, 8($t3)
		sw $t1, 256($t3)
		sw $t1, 264($t3)
		sw $t1, 512($t3)
		sw $t1, 516($t3)
		sw $t1, 520($t3)
		sw $t1, 768($t3)
		sw $t1, 1024($t3)
		
		sw $t1, 16($t3)		#L
		sw $t1, 272($t3)
		sw $t1, 528($t3)
		sw $t1, 784($t3)
		sw $t1, 1040($t3)
		sw $t1, 1044($t3)
		sw $t1, 1048($t3)
		
		sw $t1, 32($t3)		#A
		sw $t1, 36($t3)
		sw $t1, 40($t3)
		sw $t1, 288($t3)
		sw $t1, 296($t3)
		sw $t1, 544($t3)
		sw $t1, 548($t3)
		sw $t1, 552($t3)
		sw $t1, 800($t3)
		sw $t1, 808($t3)
		sw $t1, 1056($t3)
		sw $t1, 1064($t3)
		
		sw $t1, 48($t3)		#Y
		sw $t1, 56($t3)
		sw $t1, 304($t3)
		sw $t1, 312($t3)
		sw $t1, 564($t3)
		sw $t1, 820($t3)
		sw $t1, 1076($t3)
		
		sw $t1, 72($t3)		#A
		sw $t1, 76($t3)
		sw $t1, 80($t3)
		sw $t1, 328($t3)
		sw $t1, 336($t3)
		sw $t1, 584($t3)
		sw $t1, 588($t3)
		sw $t1, 592($t3)
		sw $t1, 840($t3)
		sw $t1, 848($t3)
		sw $t1, 1096($t3)
		sw $t1, 1104($t3)
		
		sw $t1, 88($t3)		#G
		sw $t1, 92($t3)
		sw $t1, 96($t3)
		sw $t1, 344($t3)
		sw $t1, 600($t3)
		sw $t1, 608($t3)
		sw $t1, 856($t3)
		sw $t1, 864($t3)
		sw $t1, 1112($t3)
		sw $t1, 1116($t3)
		sw $t1, 1120($t3)
		
		sw $t1, 104($t3)	#A
		sw $t1, 108($t3)
		sw $t1, 112($t3)
		sw $t1, 360($t3)
		sw $t1, 368($t3)
		sw $t1, 616($t3)
		sw $t1, 620($t3)
		sw $t1, 624($t3)
		sw $t1, 872($t3)
		sw $t1, 880($t3)
		sw $t1, 1128($t3)
		sw $t1, 1136($t3)
		
		sw $t1, 120($t3)	#I
		sw $t1, 124($t3)
		sw $t1, 128($t3)
		sw $t1, 380($t3)
		sw $t1, 636($t3)
		sw $t1, 892($t3)
		sw $t1, 1144($t3)
		sw $t1, 1148($t3)
		sw $t1, 1152($t3)
		
		sw $t1, 136($t3)	#N
		sw $t1, 148($t3)
		sw $t1, 392($t3)
		sw $t1, 396($t3)
		sw $t1, 404($t3)
		sw $t1, 648($t3)
		sw $t1, 652($t3)
		sw $t1, 656($t3)
		sw $t1, 660($t3)
		sw $t1, 904($t3)
		sw $t1, 912($t3)
		sw $t1, 916($t3)
		sw $t1, 1160($t3)
		sw $t1, 1172($t3)
		
		#sw $t1, 156($t3)
		#sw $t1, 160($t3)
		#sw $t1, 164($t3)
		#sw $t1, 420($t3)
		#sw $t1, 672($t3)
		#sw $t1, 1184($t3)
		j return
		
	quit:	sw $t1, 60($t3)		#Q
		sw $t1, 64($t3)
		sw $t1, 312($t3)
		sw $t1, 324($t3)
		sw $t1, 568($t3)
		sw $t1, 580($t3)
		sw $t1, 824($t3)
		sw $t1, 832($t3)
		sw $t1, 836($t3)
		sw $t1, 1084($t3)
		sw $t1, 1088($t3)
		sw $t1, 1092($t3)
		
		sw $t1, 76($t3)		#U
		sw $t1, 84($t3)
		sw $t1, 332($t3)
		sw $t1, 340($t3)
		sw $t1, 588($t3)
		sw $t1, 596($t3)
		sw $t1, 844($t3)
		sw $t1, 852($t3)
		sw $t1, 1100($t3)
		sw $t1, 1104($t3)
		sw $t1, 1108($t3)
		
		sw $t1, 92($t3)		#I
		sw $t1, 96($t3)
		sw $t1, 100($t3)
		sw $t1, 352($t3)
		sw $t1, 608($t3)
		sw $t1, 864($t3)
		sw $t1, 1116($t3)
		sw $t1, 1120($t3)
		sw $t1, 1124($t3)
		
		sw $t1, 108($t3)	#T
		sw $t1, 112($t3)
		sw $t1, 116($t3)
		sw $t1, 368($t3)
		sw $t1, 624($t3)
		sw $t1, 880($t3)
		sw $t1, 1136($t3)
		
	return:	jr $ra
		
	red_wins:
		li $t9, 0xffffff
		addi $t0, $s0, 1860	#offset
		
		sw $t9, 0($t0)		#R
		sw $t9, 4($t0)
		sw $t9, 8($t0)
		sw $t9, 256($t0)
		sw $t9, 264($t0)
		sw $t9, 512($t0)
		sw $t9, 516($t0)
		sw $t9, 768($t0)
		sw $t9, 776($t0)
		sw $t9, 1024($t0)
		sw $t9, 1032($t0)
		
		sw $t9, 16($t0)		#E
		sw $t9, 20($t0)	
		sw $t9, 24($t0)
		sw $t9, 272($t0)
		sw $t9, 528($t0)
		sw $t9, 532($t0)
		sw $t9, 536($t0)
		sw $t9, 784($t0)
		sw $t9, 1040($t0)
		sw $t9, 1044($t0)
		sw $t9, 1048($t0)
		
		sw $t9, 32($t0)		#D
		sw $t9, 36($t0)
		sw $t9, 288($t0)
		sw $t9, 296($t0)
		sw $t9, 544($t0)
		sw $t9, 552($t0)
		sw $t9, 800($t0)
		sw $t9, 808($t0)
		sw $t9, 1056($t0)
		sw $t9, 1060($t0)
		
		sw $t9, 56($t0)		#W
		sw $t9, 72($t0)
		sw $t9, 312($t0)
		sw $t9, 328($t0)
		sw $t9, 568($t0)
		sw $t9, 576($t0)
		sw $t9, 584($t0)
		sw $t9, 824($t0)
		sw $t9, 832($t0)
		sw $t9, 840($t0)
		sw $t9, 1084($t0)
		sw $t9, 1092($t0)
		
		sw $t9, 80($t0)		#I
		sw $t9, 336($t0)
		sw $t9, 592($t0)
		sw $t9, 848($t0)
		sw $t9, 1104($t0)
		
		sw $t9, 88($t0)		#N
		sw $t9, 100($t0)
		sw $t9, 344($t0)
		sw $t9, 348($t0)
		sw $t9, 356($t0)
		sw $t9, 600($t0)
		sw $t9, 604($t0)
		sw $t9, 608($t0)
		sw $t9, 612($t0)
		sw $t9, 856($t0)
		sw $t9, 864($t0)
		sw $t9, 868($t0)
		sw $t9, 1112($t0)
		sw $t9, 1124($t0)
		
		sw $t9, 108($t0)	#S
		sw $t9, 112($t0)
		sw $t9, 116($t0)
		sw $t9, 364($t0)
		sw $t9, 620($t0)
		sw $t9, 624($t0)
		sw $t9, 628($t0)
		sw $t9, 884($t0)
		sw $t9, 1132($t0)
		sw $t9, 1136($t0)
		sw $t9, 1140($t0)
		j return
		
	blue_wins:
		li $t9, 0xffffff
		addi $t0, $s0, 1872	#offset from beginning of display
		
		sw $t9, -16($t0)	#B
		sw $t9, -20($t0)
		sw $t9, 236($t0)
		sw $t9, 244($t0)
		sw $t9, 492($t0)
		sw $t9, 496($t0)
		sw $t9, 748($t0)
		sw $t9, 756($t0)
		sw $t9, 1004($t0)
		sw $t9, 1008($t0)
		
		sw $t9, -4($t0)		#L
		sw $t9, 252($t0)
		sw $t9, 508($t0)
		sw $t9, 764($t0)
		sw $t9, 1020($t0)
		sw $t9, 1024($t0)
		sw $t9, 1028($t0)
		
		sw $t9, 12($t0)		#U
		sw $t9, 20($t0)
		sw $t9, 268($t0)
		sw $t9, 276($t0)
		sw $t9, 524($t0)
		sw $t9, 532($t0)
		sw $t9, 780($t0)
		sw $t9, 788($t0)
		sw $t9, 1036($t0)
		sw $t9, 1040($t0)
		sw $t9, 1044($t0)
		
		sw $t9, 28($t0)		#E
		sw $t9, 32($t0)
		sw $t9, 36($t0)
		sw $t9, 284($t0)
		sw $t9, 540($t0)
		sw $t9, 544($t0)
		sw $t9, 548($t0)
		sw $t9, 796($t0)
		sw $t9, 1052($t0)
		sw $t9, 1056($t0)
		sw $t9, 1060($t0)
		
		sw $t9, 56($t0)		#W
		sw $t9, 72($t0)	
		sw $t9, 312($t0)
		sw $t9, 328($t0)
		sw $t9, 568($t0)
		sw $t9, 576($t0)
		sw $t9, 584($t0)
		sw $t9, 824($t0)
		sw $t9, 832($t0)
		sw $t9, 840($t0)
		sw $t9, 1084($t0)
		sw $t9, 1092($t0)
		
		sw $t9, 80($t0)		#I
		sw $t9, 336($t0)
		sw $t9, 592($t0)
		sw $t9, 848($t0)
		sw $t9, 1104($t0)
		
		sw $t9, 88($t0)		#N
		sw $t9, 100($t0)
		sw $t9, 344($t0)
		sw $t9, 348($t0)
		sw $t9, 356($t0)
		sw $t9, 600($t0)
		sw $t9, 604($t0)
		sw $t9, 608($t0)
		sw $t9, 612($t0)
		sw $t9, 856($t0)
		sw $t9, 864($t0)
		sw $t9, 868($t0)
		sw $t9, 1112($t0)
		sw $t9, 1124($t0)
		
		sw $t9, 108($t0)	#S
		sw $t9, 112($t0)
		sw $t9, 116($t0)
		sw $t9, 364($t0)
		sw $t9, 620($t0)
		sw $t9, 624($t0)
		sw $t9, 628($t0)
		sw $t9, 884($t0)
		sw $t9, 1132($t0)
		sw $t9, 1136($t0)
		sw $t9, 1140($t0)
		j return
		
	tied:
		li $t9, 0xffffff	#color is white
		addi $t0, $s0, 1896	#offset from beginning of display
		
		sw $t9, 0($t0)		#T
		sw $t9, 4($t0)
		sw $t9, 8($t0)
		sw $t9, 260($t0)
		sw $t9, 516($t0)
		sw $t9, 772($t0)
		sw $t9, 1028($t0)
		
		sw $t9, 16($t0)		#I
		sw $t9, 20($t0)
		sw $t9, 24($t0)
		sw $t9, 276($t0)
		sw $t9, 532($t0)
		sw $t9, 788($t0)
		sw $t9, 1040($t0)
		sw $t9, 1044($t0)
		sw $t9, 1048($t0)
		
		sw $t9, 32($t0)		#E
		sw $t9, 36($t0)
		sw $t9, 40($t0)
		sw $t9, 288($t0)
		sw $t9, 544($t0)
		sw $t9, 548($t0)
		sw $t9, 552($t0)
		sw $t9, 800($t0)
		sw $t9, 1056($t0)
		sw $t9, 1060($t0)
		sw $t9, 1064($t0)
		j return
