#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Maggie Chen, 1006777800
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission? 1 (and like a bit of 2)
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
#
# The movement of the logs and vehicles are still incomplete, but the two logs 
# that I have right now can move, but it jut can't wrap around to the beginning 
# again  - it is something i'm working on right now!
#
# Also, I did my frog shape based on the project tutorial video - if that needs to be
# changed for next time i can change it!
#####################################################################


.data
displayAddress: .word 0x10008000
frog_x:		.word 16			# set frog position
frog_y:		.word 28 			# to (16,28) (placing FL leg)
vehicles_1: 	.space 512			# 4*32*4 bytes allocated for the first road
vehicles_2:     .space 512			# 4*32*4 bytes allocated for the second road
river_1: 	.space 512			# 4*32*4 bytes allocated for the first river
river_2:     	.space 512			# 4*32*4 bytes allocated for the second river

.text


###### DRAW SAFE SPACE LOCATIONS ####### 

# Destination safe space --

lw $t0, displayAddress 	# $t0 stores the base address for display
li $t3, 0x4dad53 	# $t3 stores the green colour code
addi $t0, $t0, 0	# start drawing at the start of the display. (basic pixel num)

# $a0 and $a1 are the height and the width of the rectangle, respectively 
addi $a0, $zero, 8	# set height = 6
addi $a1, $zero, 32	# set width = 10

jal draw_safe_space

# Middle safe space --

lw $t0, displayAddress 	# $t0 stores the base address for display
li $t3, 0xc2b280 	# $t3 stores the green colour code
addi $t0, $t0, 2048	# start drawing at the start of the display. (basic pixel num)

# $a0 and $a1 are the height and the width of the rectangle, respectively 
addi $a0, $zero, 4	# set height = 6
addi $a1, $zero, 32	# set width = 10
jal draw_safe_space

# Beginning safe space --

lw $t0, displayAddress 	# $t0 stores the base address for display
li $t3, 0x4dad53 	# $t3 stores the green colour code
addi $t0, $t0, 3584	# start drawing at the start of the display. (basic pixel num)

# $a0 and $a1 are the height and the width of the rectangle, respectively 
addi $a0, $zero, 4	# set height = 6
addi $a1, $zero, 32	# set width = 10
jal draw_safe_space

j skip_draw_safe_space_function 	# Skip the function so that it doesn't run again

# FUNCTION: Draw rectangle for safe space

draw_safe_space:
	# Draw a rectangle:
	add $t1, $zero, $zero	# Set index value ($t1) to zero
	draw_rect_loop:
	beq $t1, $a0, done_draw # If $t1 == height ($a0), jump to end

	# Draw a line:
	add $t2, $zero, $zero	# Set index value ($t2) to zero
	draw_line_loop:
	beq $t2, $a1, end_draw_line  # If $t2 == width ($a1), jump to end
	sw $t3, 0($t0)		#   Draw a pixel at memory location $t0
	addi $t0, $t0, 4	#   Increment $t0 by 4
	addi $t2, $t2, 1	#   Increment $t2 by 1
	j draw_line_loop	#   Jump to start of line drawing loop
	end_draw_line:

	# addi $t0, $t0, 128	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
	addi $t1, $t1, 1	#   - Increment $t1 by 1
	j draw_rect_loop	#   - Jump to start of rectangle drawing loop

	done_draw:		# When $t1 == height ($a0), the drawing is done.
jr $ra

skip_draw_safe_space_function:	# Skip the function

###### DRAW RIVERS AND LOGS ####### 

# ---- STORE all the pixels in the .space array ----

# $a0 and $a1 are the height and the width of the river/log, respectively 
addi $a0, $zero, 4	# set height = 4
addi $a1, $zero, 32	# set width = 32

# $a1 and $a2 are the locations of the two logs/cars
addi $a2, $zero, 0 	# set the x location of the first vehicle ($a0 < $a1)
addi $a3, $zero, 16 	# set the x location of the second vehicle

# Set some values
lw $t0, displayAddress	# $t0 stores the base address for display
li $t7, 0x808080 	# $t7 stores the grey colour used for the road
li $t8, 0xffff00	# $t8 stores the yellow colour for cars
la $t9, vehicles_1	# $t9 holds address of array vehicles
add $t6, $zero, $zero 	# Set index value ($t6) to zero. This will be index i for storing into the array.
# addi $t5, $zero, 128	# $t5 will be the terminating condition for the index (needed? i mean you have height and 
			# width of rectangle already)

# -------

# Draw a rectangle
 
add $t1, $zero, $zero			# Set index value ($t1) to zero. This will be a counter for the height.

draw_obstacle_rectangle_loop:
beq $t1, $a0, done_obstacle_draw 	# If $t1 == height ($a0), jump to end

# Draw line
add $t2, $zero, $zero			# Set index value ($t2) to zero. This will be a counter for width.

draw_obstacle_line_loop:
beq $t2, $a1, end_draw_obstacle_line 	# If $t2 == width ($a1), jump to end

sll $t3, $t6, 2 	   		# $t3 = $t6 * 4 = i * 4 = offset 
add $t4, $t9, $t3 	   		# $t4 = addr(A) + i * 4 = addr(A[i]) 

# Check if $t3 >= $a2
bge $t2, $a2, double_check_range_1	# if $t3 >= $a2, check if the value is within $a2 + 8 before assigning colour.
j colour_grey				# if $t3 <= $a2, it is a road pixel

# Check if $t3 <= $a2 + 8
double_check_range_1:
addi $t5, $a2, 8			# add 8 to the x position of car, getting the full width of the car1
ble $t2, $t5, colour_yellow 		# if $t3 <= $a2 + 8, that means it is a car1 pixel.
j check_next				# if $t3 >= $a2 + 8, check if it passes the x position of car2

# Check if $t3 >= $a3
check_next: 
bge $t2, $a3, double_check_range_2 	# if $t3 >= $a3, check if the value is within $a3 + 8 before assigning colour.
j colour_grey				# if $t3 <= $a3, it is a road pixel

double_check_range_2:
addi $t5, $a3, 8			# add 8 to the x position of car2, getting the full width of the car
ble $t2, $t5, colour_yellow 		# if $t3 <= $a3 + 8, that means it is a car pixel.
j colour_grey				# if $t3 >= $a3 + 8, it is a road pixel
		
colour_yellow:	
sw $t8, 0($t4) 		   		# assign yellow (A[i] = 0xffff00)		   			  	   			   
j done_colouring

colour_grey:
sw $t7, 0($t4) 		   		# assign grey (A[i] = 0x808080)

done_colouring:	   				   			  		   			   			   			   			   			   				   			  		   			   			   			   			   		   				   			  		   			   			   			   			   			   				   			  		   			   			   			   			   
addi $t2, $t2, 1 	   		# increment width by 1 
addi $t6, $t6, 1			# increment array counter by 1
j draw_obstacle_line_loop	   	# Finish drawing line
end_draw_obstacle_line:

addi $t1, $t1, 1			#   Increment $t1 by 1
j draw_obstacle_rectangle_loop		#   Jump to start of rectangle drawing loop

done_obstacle_draw:		# When $t1 == height ($a0), the drawing is done.
######


# ---- PAINT all the pixels in the .space array ----

# Set some values 
lw $t0, displayAddress	# set $t0 as the base address for the display
li $a1, 2560		# $a1 determines where the road/river should start(each row is 128)
add $t0, $t0, $a1 	# Set $t0 to the pixel indicated by $a1
li $t1, 0		# $t1 (represents index i) and $t2 determine how many 
li $t2, 128		# rows to paint (each row is 32). 

paint_loop:
beq $t1, $t2, finish_paint_loop 	# Branch to Exit if $t1 == $t2
sll $t3, $t1, 2 	   		# $t3 = $t4 * 4 = i * 4 = offset
add $t4, $t9, $t3 	   		# $t4 = addr(A) + i * 4 = addr(A[i])
lw $t5, 0($t4)				# load the value of $t4 into register $t5
sw $t5, 0($t0)				# paint the first unit on the first row green. 
addi $t1, $t1, 1 	  		# increment i 
addi $t0, $t0, 4			# increment $t0 by 4
j paint_loop

finish_paint_loop:

######## DRAW FROG ########

# Set some values 
lw $t0, displayAddress 		# $t0 stores the base address for display
li $t4, 0x967bb8		# Lavender colour for frogs

# Determine the position of the frog 
la $t1, frog_x 			# $t1 has the same address as frog_x
lw $t2, 0($t1)			# Fetch x position of frog
la $t1, frog_y 			# $t2 has the same address as frog_y
lw $t3, 0($t1)			# Fetch y position of frog
sll $t2, $t2, 2			# Multiply $t2 (frog x position) by 4
sll $t3, $t3, 7			# Multiply $t3 (frog y position) by 128
add $t0, $t0, $t2		# Add x offset to $t0
add $t0, $t0, $t3		# Add y offset to $t0

# Paint the frog 
sw $t4, 0($t0) 		# draw the front left leg at the specified frog_x and frog_y coordinates. 
sw $t4, 12($t0) 	# draw the front right leg
addi $t0, $t0, 132 	# Second Row of frog (upper half of body)
sw $t4, 0($t0) 		# 
sw $t4, 4($t0) 		#
addi $t0, $t0, 128 	# Third Row of frog (lower half of body) 
sw $t4, 0($t0) 		# 
sw $t4, 4($t0) 		# 
addi $t0, $t0, 124 	# Lower legs of frog 
sw $t4, 0($t0) 		# 
sw $t4, 12($t0) 	# 


Exit:
li $v0, 10 # terminate the program gracefully
syscall
