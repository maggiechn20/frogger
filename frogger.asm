# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000
frog_x:		.word 16			# set frog position
frog_y:		.word 28 			# to (16,28) (placing FL leg)
vehicles_1: 	.space 512			# 4*32*4 bytes allocated for the first road
vehicles_2:     .space 512			# 4*32*4 bytes allocated for the second road
river_1: 	.space 512			# 4*32*4 bytes allocated for the first river
river_2:     	.space 512			# 4*32*4 bytes allocated for the second river


.text

#
# Road and Vehicles -----------
#


# FIRST ROW OF ROAD

# Allocate the colours into the .space variable

lw $t0, displayAddress	# $t0 stores the base address for display
li $t5, 0x808080 	# $t5 stores the grey colour used for the road
li $t6, 0xffff00	# t6 stores the yellow colour for cars


la $t9, vehicles_1	# $t9 holds address of array vehicles
add $t4, $zero, $zero 	# $t4 holds i = 0
add $t1, $zero, 128 	# $t1 holds 128

space_array_loop:
bge $t4, $t1, finish_road  # exit loop when i >= 128 
li $t8, 0		   # reset $t8 to zero for each loop

sll $t2, $t4, 2 	   # $t2 = $t0 * 4 = i * 4 = offset 
add $t3, $t9, $t2 	   # $t3 = addr(A) + i * 4 = addr(A[i])
sw $t5, 0($t3) 		   # colour it grey (A[i] = 0x808080)

add $t8, $t4, 0		   # Assign the value of $t4 to $t8
addi $t2, $zero, 32 	   # assign $t1 to be 32
div $t8, $t2		   # Divide $t8 by 32
mfhi $t7 		   # Store the remainder of the division to $t7 

ble $t7, 8, colour_yellow  	# if $t7 <= 8, it represents a car pixel.
bge $t7, 16, double_check_range # if $t7 >= 16, check if the value is below 24 before assigning colour.
j end_colouring
 
double_check_range:
ble $t7, 24, colour_yellow 	# if $t7 <= 24, that means it is a car pixel.
j end_colouring
		
colour_yellow:	
sw $t6, 0($t3) 		   # colour it yellow (A[i] = 0xffff00)		   			  	   			   

end_colouring:
			   				   			  		   			   			   			   			   
addi $t4, $t4, 1 	   # increment i 
j space_array_loop

finish_road:


# Paint the actual vehicle and road 

lw $t0, displayAddress	# set $t0 as the base address for the display
li $t2, 0 		# reset $t2 to 0 to use as offset again
li $t4, 0 		# reset $t4 to 0 
li $t3, 0 		# reset $t3 to 0 
li $t5, 0x808080 	# $t5 stores the grey colour used for the road
li $t8, 0
li $t6, 0
li $t7, 0
addi $t6, $t6, 640 	# since the road starts at (0, 20) and 20 * 32 = 640
addi $t7, $t7, 768	# set $t7 to 768
addi $t0, $t0, 2560 	# set $t0 as the first painted pixel

paint_loop:
beq $t6, $t7, finish_paint_loop 	# Branch to Exit if $t6 /= 768
sll $t2, $t4, 2 	   		# $t2 = $t4 * 4 = i * 4 = offset
add $t3, $t9, $t2 	   		# $t3 = addr(A) + i * 4 = addr(A[i])
lw $t8, 0($t3)				# load the value of $t3 into register $t8
sw $t8, 0($t0)				# paint the first unit on the first row green. 
addi $t4, $t4, 1 	  		# increment i 
addi $t6, $t6, 1			# increment $t6 by 1
addi $t0, $t0, 4			# increment $t0 by 4
j paint_loop

finish_paint_loop:



#
# Set/draw the background 
#

lw $t0, displayAddress # $t0 stores the base address for display
li $t5, 0	# resets $t5 to zero
li $t4, 0
li $t6, 0
li $t7, 0
li $t8, 0
li $t1, 0xff0000 # $t1 stores the red colour code
li $t2, 0x4dad53 # $t2 stores the green colour used for the land
li $t3, 0x967bb8 # $t3 stores the lavender colour used for the frog
sw $t1, 0($t0) # paint the first (top-left) unit red.
sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?


# draw the destination green land

# initialize the Loop variables $t4 and $t5 
add $t4, $t4, $zero		# set $t4 to zero 
addi $t5, $t5, 256		# set $t5 to 256 

draw_destination:
beq $t4, $t5, end_draw_destination	# Branch to Exit if $t4 == 512
sw $t2, 0($t0)				# paint the first unit on the first row green. 
addi $t0, $t0, 4			# move to the next pixel in the bitmap

addi $t4, $t4, 1		# incrment $t4 by 1
j draw_destination

end_draw_destination:

# draw the middle green land
addi $t4, $t4, 256		# set $t4 to 512. Since $t4 was last 256, 512 = 256 + 256 
addi $t5, $t5, 384		# set $t5 to 640. ($t5 was last 256, and 640 = 258 + 384)
addi $t0, $t0, 1024		# set $t0 to the new beginning pixel

draw_middle:
beq $t4, $t5, end_draw_middle	# Branch to Exit if $t4 == 640
sw $t2, 0($t0)			# paint the first unit on the first row green. 
addi $t0, $t0, 4		# move to the next pixel in the bitmap

addi $t4, $t4, 1		# incrment $t4 by 1
j draw_middle

end_draw_middle:


# draw the starting green land 
addi $t4, $t4, 256		# set $t4 to 896. Since $t4 was last 640, 896 = 640 + 256 
addi $t5, $t5, 384		# set $t5 to 1024. ($t5 was last 640, and 1024 = 640 + 384)
addi $t0, $t0, 1024		# set $t0 to the new beginning pixel

draw_beginning:
beq $t4, $t5, end_draw_beginning	# Branch to Exit if $t4 == 640
sw $t2, 0($t0)				# paint the first unit on the first row green. 
addi $t0, $t0, 4			# move to the next pixel in the bitmap

addi $t4, $t4, 1			# incrment $t4 by 1
j draw_beginning

end_draw_beginning:


#
# Draw the frog
#

frog_movement:
lw $t0, displayAddress 		# $t0 stores the base address for display
la $t6, frog_x 			# $t6 has the same address as frog_x
lw $t7, 0($t6)			# Fetch x position of frog
la $t6, frog_y 			# $t6 has the same address as frog_x
lw $t8, 0($t6)			# Fetch y position of frog
sll $t7, $t7, 2			# Multiply $t7 by 4
sll $t8, $t8, 7			# Multiply $t8 by 128
add $t0, $t0, $t8		# Add y offset to $t0
add $t0, $t0, $t7		# Add x offset to $t0

jal draw_frog

# Function: drawing the frog!
draw_frog:
sw $t3, 0($t0) 		# draw the front left leg at the specified frog_x and frog_y coordinates. 
sw $t3, 12($t0) 	# draw the front right leg
addi $t0, $t0, 132 	# Second Row of frog (upper half of body)
sw $t3, 0($t0) 		# 
sw $t3, 4($t0) 		#
addi $t0, $t0, 128 	# Third Row of frog (lower half of body) 
sw $t3, 0($t0) 		# 
sw $t3, 4($t0) 		# 
addi $t0, $t0, 124 	# Lower legs of frog 
sw $t3, 0($t0) 		# 
sw $t3, 12($t0) 	# 
jr $ra

# Exit: (?) don't know why it'ls not here
li $v0, 10 # terminate the program gracefully
syscall
