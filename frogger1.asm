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
keyboard: 	.word 0xffff0000		# Memory address of keyboard		
frog_x:		.word 16			# set frog position
frog_y:		.word 28 			# to (16,28) (placing FL leg)
vehicles_1: 	.space 512			# 4*32*4 bytes allocated for the first road
vehicles_2:     .space 512			# 4*32*4 bytes allocated for the second road
river_1: 	.space 512			# 4*32*4 bytes allocated for the first river
river_2:     	.space 512			# 4*32*4 bytes allocated for the second river

car1_x:		.word 0 
car2_x: 	.word 16
car3_x:		.word 4
car4_x:		.word 20
log1_x:		.word 0
log2_x:		.word 16
log3_x:		.word 4
log4_x:		.word 20
green:		.word 0x4dad53
lavendar:	.word 0x967bb8
grey:		.word 0x808080 	
yellow:		.word 0xffff00
blue: 		.word 0x00008b
red: 		.word 0x8B0000
black: 		.word 0x000000
white: 		.word 0xffffff
pause_colour:	.word 0xD3D3D3
goal_empty:     .word 0xf8C8DC
goal_filled: 	.word 0xcd5e77

goal_1:		.word 0
goal_2:		.word 0
goal_3:		.word 0

game_x: 	.word 4
game_y:		.word 4
over_x:		.word 4 
over_y: 	.word 13
yes_x:		.word 10
yes_y:		.word 21

facing_left:	.word 0
facing_forward: .word 1
facing_right:   .word 0
facing_back:  	.word 0

river2_speed: 		.word 0
river2_speed_set: 	.word 2
road1_speed: 		.word 0
road1_speed_set: 	.word 6
road2_speed: 		.word 0
road2_speed_set: 	.word 3

lives_left: 	.word 3 			# How many lives the frog has left 
lives_display: 	.space 24 			# 6*4 bytes allocated for lives display

.text

play:						# When game ends, keystroke Y jumps here to play again

##### INITIAL ROAD PAINT #####

# Road 1 -----
# Set parameters for allocate_memory
addi $a2, $zero, 0 	# set the x location of the first car 
addi $a3, $zero, 16 	# set the x location of the second car


li $t7, 0x808080 	# $t7 stores the grey colour used for the road 
li $t8, 0xffff00	# $t8 stores the yellow colour for cars 

la $t9, vehicles_1	# $t9 holds address of array vehicles_1 

jal allocate_memory


# Road 2 -----
# Set parameters for allocate_memory
addi $a2, $zero, 4 	# set the x location of the first car 
addi $a3, $zero, 20 	# set the x location of the second car

li $t7, 0x808080 	# $t7 stores the grey colour used for the road 
li $t8, 0xffff00	# $t8 stores the yellow colour for cars 

la $t9, vehicles_2	# $t9 holds address of array vehicles_2

jal allocate_memory

# River 1 -----
# Set parameters for allocate_memory
addi $a2, $zero, 0 	# set the x location of the first log 
addi $a3, $zero, 16 	# set the x location of the second log

li $t7, 0x00008b 	# $t7 stores the blue colour used for the river 
li $t8, 0x964b00	# $t8 stores the brown colour for logs 

la $t9, river_1		# $t9 holds address of array river_1 

jal allocate_memory


# River 2 -----
# Set parameters for allocate_memory
addi $a2, $zero, 4 	# set the x location of the first log 
addi $a3, $zero, 20 	# set the x location of the second log

li $t7, 0x00008b 	# $t7 stores the blue colour used for the river 
li $t8, 0x964b00	# $t8 stores the brown colour for logs 

la $t9, river_2		# $t9 holds address of array river_2 

jal allocate_memory

j skip_allocate_memory_func
# FUNCTION: Store all the pixels in the .space array
allocate_memory:
	# $a0 and $a1 are the height and the width of the river/log, respectively 
	addi $a0, $zero, 4		# set height = 4
	addi $a1, $zero, 32		# set width = 32

	# Set some values
	lw $t0, displayAddress		# $t0 stores the base address for display
	add $t6, $zero, $zero 		# Set index value ($t6) to zero. This will be index i for storing into the array.

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

	# Check if $t2 >= $a2
	bge $t2, $a2, double_check_range_1	# if $t2 >= $a2, check if the value is within $a2 + 8 before assigning colour.
	j colour_grey				# if $t2 <= $a2, it is a road pixel

	# Check if $t2 <= $a2 + 8
	double_check_range_1:
	addi $t5, $a2, 8			# add 8 to the x position of car, getting the full width of the car1
	
	# bge $t5, 32, overflow_control		# If the car drawing overflows out of display, go to overflow_control
	ble $t2, $t5, colour_yellow 		# if $t2 <= $a2 + 8, that means it is a car1 pixel.
	j check_next				# if $t2 >= $a2 + 8, check if it passes the x position of car2

	# Check if $t2 >= $a3
	check_next: 
	bge $t2, $a3, double_check_range_2 	# if $t2 >= $a3, check if the value is within $a3 + 8 before assigning colour.
	j colour_grey				# if $t2 <= $a3, it is a road pixel

	double_check_range_2:
	addi $t5, $a3, 8			# add 8 to the x position of car2, getting the full width of the car
	ble $t2, $t5, colour_yellow 		# if $t2 <= $a3 + 8, that means it is a car pixel.
	j colour_grey				# if $t2 >= $a3 + 8, it is a road pixel
		
	colour_yellow:	
	sw $t8, 0($t4) 		   		# assign yellow (A[i] = 0xffff00)		   			  	   			   
	j done_colouring

	colour_grey:
	sw $t7, 0($t4) 		   		# assign grey (A[i] = 0x808080)

	done_colouring:	
   			  		   			   			   			   			   			   				   			  		   			   			   			   			   		   				   			  		   			   			   			   			   			   				   			  		   			   			   			   			   
	addi $t2, $t2, 1 	   		# increment width by 1 
	addi $t6, $t6, 1			# increment array counter by 1
	j draw_obstacle_line_loop	   	
	end_draw_obstacle_line:			# Finish drawing line
	


	addi $t1, $t1, 1			# Increment $t1 （height）by 1
	j draw_obstacle_rectangle_loop		#  Jump to start of rectangle drawing loop

	done_obstacle_draw:			# When $t1 == height ($a0), the drawing is done.
jr $ra

skip_allocate_memory_func:


############################
######### MAIN LOOP ########
############################

repaint:

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

###### DRAW GOALS ###### 

lw $s0, goal_1
lw $s1, goal_2
lw $s2, goal_3


# Goal 1 
lw $t0, displayAddress 			# $t0 stores the base address for display
beq $s0, 0, empty_colour1		# Check if goal is filled or not
lw $t3, goal_filled 			# $t3 stores the pink goal filled colour
j skip_other1				# Skip implementation below 
empty_colour1:
lw $t3, goal_empty 	# $t3 stores the pink goal empty colour
skip_other1:
addi $t0, $t0, 8	# start drawing at the start of the display. (basic pixel num)

# $a0 and $a1 are the height and the width of the rectangle, respectively 
addi $a0, $zero, 2	# set height = 6
addi $a1, $zero, 3	# set width = 10
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space

# Goal 2 
lw $t0, displayAddress 			# $t0 stores the base address for display
beq $s1, 0, empty_colour2		# Check if goal is filled or not
lw $t3, goal_filled 			# $t3 stores the pink goal filled colour
j skip_other2				# Skip implementation below 
empty_colour2:
lw $t3, goal_empty 	# $t3 stores the pink goal empty colour
skip_other2:
addi $t0, $t0, 40	# start drawing at the start of the display. (basic pixel num)

# $a0 and $a1 are the height and the width of the rectangle, respectively 
addi $a0, $zero, 2	# set height = 6
addi $a1, $zero, 3	# set width = 10
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space


# Goal 3 
lw $t0, displayAddress 			# $t0 stores the base address for display
beq $s2, 0, empty_colour3		# Check if goal is filled or not
lw $t3, goal_filled 			# $t3 stores the pink goal filled colour
j skip_other3				# Skip implementation below 
empty_colour3:
lw $t3, goal_empty 	# $t3 stores the pink goal empty colour
skip_other3:
addi $t0, $t0, 72	# start drawing at the start of the display. (basic pixel num)

# $a0 and $a1 are the height and the width of the rectangle, respectively 
addi $a0, $zero, 2	# set height = 6
addi $a1, $zero, 3	# set width = 10
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space
addi $t0, $t0, 104
jal draw_safe_space

###### FILLING IN GOALS #######
# Add frog_x and frog_y. It it is within some range, change goal_1... to 1 

# Set some values 
lw $t0, displayAddress 		# $t0 stores the base address for display

# Determine the position of the frog 
la $t1, frog_x 			# $t1 has the same address as frog_x
lw $t2, 0($t1)			# Fetch x position of frog
la $t1, frog_y 			# $t2 has the same address as frog_y
lw $t3, 0($t1)			# Fetch y position of frog
sll $t2, $t2, 2			# Multiply $t2 (frog x position) by 4
sll $t3, $t3, 7			# Multiply $t3 (frog y position) by 128
add $t0, $t0, $t2		# Add x offset to $t0
add $t0, $t0, $t3		# Add y offset to $t0

# Goal 1 
lw $t9, displayAddress 		# $t0 stores the base address for display
addi $t6, $t9, 8
beq $t0, $t6, fill_goal1
addi $t6, $t6, 4
beq $t0, $t6, fill_goal1
addi $t6, $t6, 4
beq $t0, $t6, fill_goal1
j skip_fill_goal1
fill_goal1:
la $t4, goal_1
addi $t5, $zero, 1
sw $t5, 0($t4)

jal after_goal_filled
skip_fill_goal1:


j skip_after_goal

after_goal_filled:
li $v0, 32		# Sleep so that it pauses for a bt
li $a0, 500
syscall

la $t2, frog_x
la $t3, frog_y

# Reset frog's position to start 
addi $t9, $zero, 16 		# Reset x position
sw $t9, 0($t2)			# Store this reset position to frog_x
addi $t9, $zero, 28 		# Reset y position
sw $t9, 0($t3)			# Store this reset position to frog_y

addi $t8, $zero, 0
addi $t7, $zero, 1
la $t9, facing_forward			# Get the (1/0) value of facing_forward
sw $t7, 0($t9) 				# Set it to 0.
la $t9, facing_left			# Get the (1/0) value of facing_left
sw $t8, 0($t9) 				# Set it to 1.
la $t9, facing_right			# Get the (1/0) value of facing_right
sw $t8, 0($t9) 				# Set it to 0.
la $t9, facing_back			# Get the (1/0) value of facing_back
sw $t8, 0($t9) 				# Set it to 0.

jr $ra

skip_after_goal:


###### DRAW RIVERS AND LOGS ####### 
# River 1 
la $t9, river_1		# $t9 holds address of array river_1 
li $a1, 1024		# $a1 determines where road1 should start(each row is 128) 
jal paint_pixels
jal shift_array_left


# Road 1 
la $t9, vehicles_1	# $t9 holds address of array vehicles_1 
li $a1, 2560		# $a1 determines where road1 should start(each row is 128) 
jal paint_pixels

lw $t1, road1_speed 	# Load the value/word into $t1
la $t2, road1_speed  	# Load the address
lw $t3, road1_speed_set # This is the condition for the loop
beq $t1, $t3, road1_speed_loop

j skip_road1_loop
road1_speed_loop:

jal shift_array_left

addi $t3, $zero, 0
la $t2, road1_speed  	# Load the address
sw $t3, 0($t2) 		# Reset it back to zero 

j road1_loop_exit

skip_road1_loop:
lw $t1, road1_speed 	# Load the value/word into $t1
addi $t1, $t1, 1	# Increment 
sw $t1, 0($t2)		# Store this value to river2_s

road1_loop_exit:


# Road 2 
la $t9, vehicles_2	# $t9 holds address of array vehicles_1 
li $a1, 3072		# $a1 determines where road1 should start(each row is 128) 
jal paint_pixels

lw $t1, road2_speed 	# Load the value/word into $t1
la $t2, road2_speed  	# Load the address
lw $t3, road2_speed_set # This is the condition for the loop
beq $t1, $t3, road2_speed_loop

j skip_road2_loop
road2_speed_loop:

jal shift_array_right

addi $t3, $zero, 0
la $t2, road2_speed  	# Load the address
sw $t3, 0($t2) 		# Reset it back to zero 

j road2_loop_exit

skip_road2_loop:
lw $t1, road2_speed 	# Load the value/word into $t1
addi $t1, $t1, 1	# Increment 
sw $t1, 0($t2)		# Store this value to river2_s

road2_loop_exit:

# River 2

la $t9, river_2		# $t9 holds address of array vehicles_1 
li $a1, 1536		# $a1 determines where road1 should start(each row is 128) 
jal paint_pixels

lw $t1, river2_speed 	# Load the value/word into $t1
la $t2, river2_speed  	# Load the address
lw $t3, river2_speed_set # This is the condition for the loop
beq $t1, $t3, river2_speed_loop

j skip_river2_loop
river2_speed_loop:

jal shift_array_right

addi $t3, $zero, 0
la $t2, river2_speed  	# Load the address
sw $t3, 0($t2) 		# Reset it back to zero 

j river2_loop_exit

skip_river2_loop:
lw $t1, river2_speed 	# Load the value/word into $t1
addi $t1, $t1, 1	# Increment 
sw $t1, 0($t2)		# Store this value to river2_s

river2_loop_exit:


j skip_memory_and_pixels_functions	# Skip the functions below

# FUNCTION: paint all the pixels in the .space array 
paint_pixels:
	# Set some values 
	lw $t0, displayAddress	# set $t0 as the base address for the display
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
jr $ra

skip_memory_and_pixels_functions:

######## DRAW FROG ########

# FUNCTION: Draw frog
li $t4, 0x967bb8				# Lavender colour for frogs
jal draw_frog					# Call the draw frog function

j skip_function					# Skip over the draw frog implementation

draw_frog:
# Set some values 
lw $t0, displayAddress 		# $t0 stores the base address for display

# Determine the position of the frog 
la $t1, frog_x 			# $t1 has the same address as frog_x
lw $t2, 0($t1)			# Fetch x position of frog
la $t1, frog_y 			# $t2 has the same address as frog_y
lw $t3, 0($t1)			# Fetch y position of frog
sll $t2, $t2, 2			# Multiply $t2 (frog x position) by 4
sll $t3, $t3, 7			# Multiply $t3 (frog y position) by 128
add $t0, $t0, $t2		# Add x offset to $t0
add $t0, $t0, $t3		# Add y offset to $t0

# Orientation of frog 
lw $s0, facing_left
lw $s1, facing_forward
lw $s2, facing_right
lw $s3, facing_back



# WHEN FROG MOVES FORWARD ---------
beq $s1, 1, facing_forward_paint		# If facing_left is true, paint a left facing frog 
j skip_facing_forward_paint		# If not, then skip the implementation
facing_forward_paint:

sw $t4, 0($t0) 		# draw the front left leg at the specified frog_x and frog_y coordinates. 
sw $t4, 12($t0) 	# draw the front right leg
addi $t0, $t0, 128 	# Second Row of frog (upper half of body)
sw $t4, 0($t0) 		# 
sw $t4, 4($t0) 		#
sw $t4, 8($t0) 		#
sw $t4, 12($t0) 	#
addi $t0, $t0, 132 	# Third Row of frog (lower half of body) 
sw $t4, 0($t0) 		# 
sw $t4, 4($t0) 		# 
addi $t0, $t0, 124 	# Second Row of frog (upper half of body)
sw $t4, 0($t0) 		# 
sw $t4, 4($t0) 		#
sw $t4, 8($t0) 		#
sw $t4, 12($t0) 	#

skip_facing_forward_paint:

# WHEN FROG MOVES LEFT -------
beq $s0, 1, facing_left_paint		# If facing_left is true, paint a left facing frog 
j skip_facing_left_paint		# If not, then skip the implementation
facing_left_paint:
# Row 1 
sw $t4, 0($t0) 		 
sw $t4, 4($t0) 	
sw $t4, 12($t0) 

# Row 2 
addi $t0, $t0, 128 
sw $t4, 4($t0) 		 
sw $t4, 8($t0) 	
sw $t4, 12($t0) 

# Row 3
addi $t0, $t0, 128 
sw $t4, 4($t0) 		 
sw $t4, 8($t0) 	
sw $t4, 12($t0) 

# Row 4 
addi $t0, $t0, 128 
sw $t4, 0($t0) 		 
sw $t4, 4($t0) 	
sw $t4, 12($t0) 

skip_facing_left_paint:


# WHEN FROG MOVES RIGHT -------
beq $s2, 1, facing_right_paint		# If facing_left is true, paint a left facing frog 
j skip_facing_right_paint		# If not, then skip the implementation
facing_right_paint:
# Row 1 
sw $t4, 0($t0) 		 
sw $t4, 8($t0) 	
sw $t4, 12($t0) 

# Row 2 
addi $t0, $t0, 128 
sw $t4, 0($t0) 		 
sw $t4, 4($t0) 	
sw $t4, 8($t0) 

# Row 3
addi $t0, $t0, 128 
sw $t4, 0($t0) 		 
sw $t4, 4($t0) 	
sw $t4, 8($t0) 

# Row 4 
addi $t0, $t0, 128 
sw $t4, 0($t0) 		 
sw $t4, 8($t0) 	
sw $t4, 12($t0) 

skip_facing_right_paint:


# WHEN FROG MOVES RIGHT -------
beq $s3, 1, facing_back_paint		# If facing_left is true, paint a left facing frog 
j skip_facing_back_paint		# If not, then skip the implementation
facing_back_paint:
# Row 1 
sw $t4, 0($t0) 		 
sw $t4, 4($t0) 	
sw $t4, 8($t0) 
sw $t4, 12($t0) 

# Row 2 
addi $t0, $t0, 128 		 
sw $t4, 4($t0) 	
sw $t4, 8($t0) 

# Row 3
addi $t0, $t0, 128 
sw $t4, 0($t0) 		 
sw $t4, 4($t0) 	
sw $t4, 8($t0) 
sw $t4, 12($t0) 

# Row 4 
addi $t0, $t0, 128 
sw $t4, 0($t0) 		 
sw $t4, 12($t0) 

skip_facing_back_paint:

jr $ra

skip_function:



### LIVES REMAINING ##### 

lw $t1, red
lw $t2, black

# Set the display to start at 26 pixels from the left 
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 232
lw $t9, lives_left

# If you have three lives remaining, load three req squares 
beq $t9, 3, three_lives
j not_three_lives
three_lives:
sw $t1, 0($t0) 
addi $t0, $t0, 8
sw $t1, 0($t0) 
addi $t0, $t0, 8
sw $t1, 0($t0) 
addi $t0, $t0, 8
not_three_lives:

# If you have two lives remaining, load two red squares, and one black square
beq $t9, 2, two_lives
j not_two_lives
two_lives:
sw $t1, 0($t0) 
addi $t0, $t0, 8
sw $t1, 0($t0) 
addi $t0, $t0, 8
sw $t2, 0($t0) 
addi $t0, $t0, 8
not_two_lives:

# If you have one lives remaining, load 1 red squares, and two black square
beq $t9, 1, one_lives
j not_one_lives
one_lives:
sw $t1, 0($t0) 
addi $t0, $t0, 8
sw $t2, 0($t0) 
addi $t0, $t0, 8
sw $t2, 0($t0) 
addi $t0, $t0, 8
not_one_lives:

# If you have zero lives remaining, load three black squares and jump to the terminate game function 
beq $t9, 0, no_lives
j not_no_lives
no_lives:
sw $t2, 0($t0) 
addi $t0, $t0, 8
sw $t2, 0($t0) 
addi $t0, $t0, 8
sw $t2, 0($t0) 
addi $t0, $t0, 8


j game_over					# After all lives, jump to game_over
not_no_lives:
# draw function: draw out the lives remaining 
# Set parameters for allocate_memory


j skip_shift				# Skip the code that shifts the array

### Shift ###
shift_array_left:
 
addi $s0, $t9, 0			# Find the address of the first pixel of one row
lw $s1, 0($s0)				# load the value of $s0 into register $s1

add $t1, $zero, $zero 		# Set index value ($t1) to zero. This will be index i for storing into the array.

# $a0 and $a1 are the height and the width of the river/road, respectively 
addi $a0, $zero, 4		# set height = 4
addi $a1, $zero, 32		# set width = 32

# Draw a rectangle:
add $t4, $zero, $zero		# Set index value ($t4) to zero
draw_rect_loop_shift:
beq $t4, $a0, exit_shift  	# If $t4 == height ($a0), jump to end

# Draw a line:
add $t5, $zero, $zero		# Set index value ($t5) to zero
draw_line_loop_shift:
beq $t5, $a1, end_draw_line_shift  	# If $t5 == width ($a1), jump to end

sll $t2, $t1, 2 	   	# $t2 = $t1 * 4 = i * 4 = offset 
add $t3, $t9, $t2 	   	# $t3 = addr(A) + i * 4 = addr(A[i]) 

# Store the value of the next pixel
addi $t6, $t1, 1		# -> Store the value of index $t1, incremented by one, to another register ($t6)
sll $t6, $t6, 2			# Offset
add $t7, $t9, $t6		# -> Add this to $t9 store to register $t7
lw $t8, 0($t7)			# -> Load word from $t7 to $t8
sw $t8, 0($t3)			# -> Store this word into $t3


addi $t5, $t5, 1 		# Increment index ($t5)
addi $t1, $t1, 1		# increment array counter by 1

j draw_line_loop_shift	#   - Jump to start of line drawing loop
end_draw_line_shift:

# Store the value of the first pixel to the last pixel
sw $s1, 0($t3)

addi $t4, $t4, 1	#   - Increment $t6 by 1
j draw_rect_loop_shift	#   - Jump to start of rectangle drawing loop
 
exit_shift:

jr $ra

### 


shift_array_right:
 
addi $s0, $t9, 508			# Find the address of the last pixel of one row
lw $s1, 0($s0)				# load the value of the last address of $t9 into register $s1

add $t1, $zero, $zero 		# Set index value ($t1) to zero. This will be index i for storing into the array.

# $a0 and $a1 are the height and the width of the river/road, respectively 
addi $a0, $zero, 4		# set height = 4
addi $a1, $zero, 32		# set width = 32

# Draw a rectangle:
add $t4, $zero, $zero		# Set index value ($t4) to zero
draw_rect_loop_shift_r:
beq $t4, $a0, exit_shift_r  	# If $t4 == height ($a0), jump to end

# Draw a line:
add $t5, $zero, $zero		# Set index value ($t5) to zero
draw_line_loop_shift_r:
beq $t5, $a1, end_draw_line_shift_r  	# If $t5 == width ($a1), jump to end

sll $t2, $t1, 2 	   	# $t2 = $t1 * 4 = i * 4 = offset 
sub $t3, $s0, $t2 	   	# $t3 = addr(A) - i * 4 = addr(A[i]) 

# Store the value of the next pixel
addi $t6, $t1, 1		# -> Store the value of index $t1, incremented by one, to another register ($t6)
sll $t6, $t6, 2			# Offset
sub $t7, $s0, $t6		# -> Sub $t6 from $t9 and store this address value to $t7
lw $t8, 0($t7)			# -> Load word from $t7 to $t8
sw $t8, 0($t3)			# -> Store this word into $t3


addi $t5, $t5, 1 		# Increment index ($t5)
addi $t1, $t1, 1		# increment array counter by 1

j draw_line_loop_shift_r	#   - Jump to start of line drawing loop
end_draw_line_shift_r:

# Store the value of the last pixel to the first pixel
sw $s1, 0($t3)

addi $t4, $t4, 1	#   - Increment $t6 by 1
j draw_rect_loop_shift_r	#   - Jump to start of rectangle drawing loop
 
exit_shift_r:

jr $ra

skip_shift:					# Skips the code that shifts the array

### FROG MOVEMENT ###
lw $t0, 0xffff0000				# Memory address of keyboard
beq $t0, 1, keyboard_input			# If there is a keystroke event, go to keyboard_input
j skip_keyboard_input				# If not, skip the keyboard_input function
keyboard_input:
lw $t1, 0xffff0004				# Load the value of the keystroke event
beq $t1, 0x61, respond_to_A			# If the keystroke was A, then go to respond_to_A
j skip_A					# If not, skip the implementation and check if it is W 
	respond_to_A: 				# Move frog left
	
	addi $t8, $zero, 0
	addi $t7, $zero, 1
	la $t9, facing_forward			# Get the (1/0) value of facing_forward
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_left			# Get the (1/0) value of facing_left
	sw $t7, 0($t9) 				# Set it to 1.
	la $t9, facing_right			# Get the (1/0) value of facing_right
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_back			# Get the (1/0) value of facing_back
	sw $t8, 0($t9) 				# Set it to 0.
	
	# Draw in new frog 
	la $t2, frog_x 				# $t1 has the same address as frog_x
	lw $t3, 0($t2)				# Fetch x position of frog
	addi $t5, $zero, 4 			# Assign the value of 4 
	sub $t6, $t3, $t5			# Original x position minus 16 (moves one frog left)
	sw $t6, 0($t2)
	li $t4, 0x967bb8			# Lavender colour for frogs
	jal draw_frog

skip_A:
beq $t1, 0x77, respond_to_W			# If the keystroke was W, then go to respond_to_W
j skip_W					# If not, skip the implementation and check if it is S 
	respond_to_W: 				# Move frog forward
	
	addi $t8, $zero, 0
	addi $t7, $zero, 1
	la $t9, facing_forward			# Get the (1/0) value of facing_forward
	sw $t7, 0($t9) 				# Set it to 0.
	la $t9, facing_left			# Get the (1/0) value of facing_left
	sw $t8, 0($t9) 				# Set it to 1.
	la $t9, facing_right			# Get the (1/0) value of facing_right
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_back			# Get the (1/0) value of facing_back
	sw $t8, 0($t9) 				# Set it to 0.
	
	# Draw in new frog 
	la $t2, frog_y 				# $t2 has the same address as frog_y
	lw $t3, 0($t2)				# Fetch y position of frog
	addi $t5, $zero, 4 			# Assign the value of 4 
	sub $t6, $t3, $t5			# Original y position minus 4 (moves one frog forward)
	sw $t6, 0($t2)
	li $t4, 0x967bb8			# Lavender colour for frogs
	jal draw_frog



skip_W:
beq $t1, 0x73, respond_to_S			# If the keystroke was S, then go to respond_to_S
j skip_S					# If not, skip the implementation and check if it is D
	respond_to_S: 				# Move frog back
	
	addi $t8, $zero, 0
	addi $t7, $zero, 1
	la $t9, facing_forward			# Get the (1/0) value of facing_forward
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_left			# Get the (1/0) value of facing_left
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_right 			# Get the (1/0) value of facing_right
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_back			# Get the (1/0) value of facing_back
	sw $t7, 0($t9) 				# Set it to 1.
	
	# Draw in new frog 
	la $t2, frog_y 				# $t2 has the same address as frog_y
	lw $t3, 0($t2)				# Fetch y position of frog
	addi $t5, $zero, 4 			# Assign the value of 32 
	add $t6, $t3, $t5			# Original y position minus 32 (moves one frog forward)
	sw $t6, 0($t2)
	li $t4, 0x967bb8			# Lavender colour for frogs
	jal draw_frog

skip_S:
beq $t1, 0x64, respond_to_D			# If the keystroke was D, then go to respond_to_D
j skip_D					# If not, skip the implementation 
	respond_to_D: 				# Move frog right

	addi $t8, $zero, 0
	addi $t7, $zero, 1
	la $t9, facing_forward			# Get the (1/0) value of facing_forward
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_left			# Get the (1/0) value of facing_left
	sw $t8, 0($t9) 				# Set it to 0.
	la $t9, facing_right			# Get the (1/0) value of facing_right
	sw $t7, 0($t9) 				# Set it to 0.
	la $t9, facing_back			# Get the (1/0) value of facing_back
	sw $t8, 0($t9) 				# Set it to 1.
	
	# Draw in new frog 
	la $t2, frog_x 				# $t2 has the same address as frog_x
	lw $t3, 0($t2)				# Fetch y position of frog
	addi $t5, $zero, 4 			# Assign the value of 32 
	add $t6, $t3, $t5			# Original y position minus 32 (moves one frog forward)
	sw $t6, 0($t2)
	li $t4, 0x967bb8			# Lavender colour for frogs
	jal draw_frog
skip_D:
beq $t1, 0x70, respond_to_P			# If the keystroke was P, then go to respond_to_P
j skip_P					# If not, skip the implementation 
	respond_to_P: 				# Pause screen
	la $t9, keyboard				# Load the memory address of the keyboard
	addi $t7, $zero, 0				# Assign $t7 the value of 0
	sw $t7, 0($t9) 					# Assign the value of the memory address to zero to get ready for 
	
	# Pause the game 
	pause_loop:
	lw $t1, 0xffff0000
	beq $t1, 1, check_p			# If there is a keystroke event (p is pressed again), break the loop and resume
	j skip_check_p
	check_p:
	lw $t2, 0xffff0004
	beq $t2, 0x70, break_pause
	skip_check_p:
	
	# Draw a pause button 
	lw $t0, displayAddress
	lw $t1, pause_colour
	addi $t0, $t0, 1920			# 15 rows from top (128 each row)
	addi $t0, $t0, 64			# 16 pixels from the right (4 each shift)
	
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	addi $a0, $zero, 1		# Height of stroke
	addi $a1, $zero, 2		# width of stroke
	jal letter_horizontal_line
	addi $t0, $t0, 120
	addi $a0, $zero, 1		# Height of stroke
	addi $a1, $zero, 3		# width of stroke
	jal letter_horizontal_line
	addi $t0, $t0, 116
	addi $a0, $zero, 1		# Height of stroke
	addi $a1, $zero, 2		# width of stroke
	jal letter_horizontal_line
	addi $t0, $t0, 120
	sw $t1, 0($t0)
	j pause_loop
	
	
	break_pause:	
	
	
skip_P:

skip_keyboard_input:

la $t9, keyboard				# Load the memory address of the keyboard
add $t8, $t9, $zero 				# Assign $t8 the keyboard address
addi $t7, $zero, 0				# Assign $t7 the value of 0
sw $t7, 0($t9) 					# Assign the value of the memory address to zero to get ready for next keystroke event

#### FROG DEATH #####
# If the position of the frog is on a pixel that has a value of the yellow or blue, frog restarts 

addi $t1, $zero, 0 				# Assign $t1 to be zero. We will add to it to make it the frog's position

# Get the frog's position
la $t2, frog_x 			# $t2 has the same address as frog_x
lw $t3, 0($t2)			# Fetch x position of frog
la $t2, frog_y 			# $t2 has the same address as frog_y
lw $t4, 0($t2)			# Fetch y position of frog
sll $t3, $t3, 2			# Multiply $t3 (frog x position) by 4
sll $t4, $t4, 7			# Multiply $t4 (frog y position) by 128
add $t1, $t1, $t3		# Add x offset to $t1
addi $t1, $t1, 4		# To ensure sensitivity is not at the edges, but rather when frog is ON something
addi $s2, $zero, 8		# Gets the width of the frog (3*8 because you are looking at hte 4th pixel)

lw $t7, blue
lw $t8, yellow

# Road 2
addi $s1, $zero, 3072		# Y position of the road
beq $t4, $s1, assess_road2	# If the frog's y position is at the line of vehicle_2, go to assess_road2. 

j skip_assess_road2		# If not, skip over assess_road2
assess_road2:
la $t0, vehicles_2 		# $t0 stores the base address for vehicles2
add $t5, $t0, $zero 		# Store the memory address to $t5
add $t5, $t5, $t1		# Add frog's x position offset to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 

beq $t8, $t6, crash_car2	# If the frog's position is on a car (yellow), it returns to the start 

add $t5, $t5, $s2		# Add frog's width to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 
beq $t8, $t6, crash_car2	# If the frog's position is on a car (yellow), frog returns to the start 

j skip_crash_car2		# If the pixel colors are not the same, then skip crash_car

crash_car2:
li $t4, 0x8b0000				# Colour for draw_frog when frog dies
jal draw_frog
jal crash_func
skip_crash_car2:
skip_assess_road2:		# Skips assess_raod (when y position of frog is not the same as the road2



# Road 1 
addi $s1, $zero, 2560		# Y position of the road
beq $t4, $s1, assess_road1	# If the frog's y position is at the line of vehicle_1, go to assess_road1. 

j skip_assess_road1		# If not, skip over assess_road2
assess_road1:
la $t0, vehicles_1 		# $t0 stores the base address for vehicles2
add $t5, $t0, $zero 		# Store the memory address to $t5
add $t5, $t5, $t1		# Add frog's x position offset to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 

beq $t8, $t6, crash_car1	# If the frog's position is on a car (yellow), it returns to the start 

add $t5, $t5, $s2		# Add frog's width to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 
beq $t8, $t6, crash_car1	# If the frog's position is on a car (yellow), frog returns to the start 

j skip_crash_car1		# If the pixel colors are not the same, then skip crash_car

crash_car1:
li $t4, 0x8b0000				# Colour for draw_frog when frog dies
jal draw_frog
jal crash_func
skip_crash_car1:
skip_assess_road1:		# Skips assess_raod (when y position of frog is not the same as the road2

# River 2 
addi $s1, $zero, 1536		# Y position of the road
beq $t4, $s1, assess_river2	# If the frog's y position is at the line of vehicle_1, go to assess_road1. 

j skip_assess_river2		# If not, skip over assess_road2
assess_river2:
la $t0, river_2			# $t0 stores the base address for vehicles2
add $t5, $t0, $zero 		# Store the memory address to $t5
add $t5, $t5, $t1		# Add frog's x position offset to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 

beq $t7, $t6, crash_river2	# If the frog's position is on a car (yellow), it returns to the start 

add $t5, $t5, $s2		# Add frog's width to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 
beq $t7, $t6, crash_river2	# If the frog's position is on a car (yellow), frog returns to the start 


# FUNCTION: move_with_log

move_with_log:			# If the pixel colors are not the same, then move with the log.
la $t2, frog_x 			# $t2 has the same address as frog_x
lw $t3, 0($t2)			# Fetch x position of frog
beq $t3, 28, hit_edge2		# Do not move if you are already at the end of display

lw $t6, river2_speed 		# Load the value/word into $t1
la $t7, river2_speed  		# Load the address
lw $t8, river2_speed_set 	# This is the condition for the loop

beq $t6, $t8, move_slow_loop

j skip_move_slow_loop

move_slow_loop:
addi $t3, $t3, 1		# Move the frog to the right 
sw $t3, 0($t2)			# Store the new frog x position to frog_x
li $t4, 0x967bb8		# Lavender colour for frogs
jal draw_frog			# Call the draw frog function

skip_move_slow_loop:
hit_edge2:			# Skip over all the movement stuff because you are at the edge of display

j skip_crash_river2		# Skip implementation of crash function
crash_river2:
li $t4, 0x8b0000				# Colour for draw_frog when frog dies
jal draw_frog
jal crash_func
skip_crash_river2: 		# Skips implementation of crash function (frog was on log)
skip_assess_river2:		# Skip implementation of assess_river2 (frog was not on the same y position as this river)

# River 1 
addi $s1, $zero, 1024		# Y position of the road
beq $t4, $s1, assess_river1	# If the frog's y position is at the line of vehicle_1, go to assess_road1. 

j skip_assess_river1		# If not, skip over assess_road2
assess_river1:
la $t0, river_1			# $t0 stores the base address for vehicles2
add $t5, $t0, $zero 		# Store the memory address to $t5
add $t5, $t5, $t1		# Add frog's x position offset to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 

beq $t7, $t6, crash_river1	# If the frog's position is on a river (blue), it returns to the start 

add $t5, $t5, $s2		# Add frog's width to $t5 
lw $t6, 0($t5)			# Load the colour from memory address indicated by $t5 into $t6 
beq $t7, $t6, crash_river1	# If the frog's position is on a car (yellow), frog returns to the start 


move_with_log2:			# If the pixel colors are not the same, then move with the log.
la $t2, frog_x 			# $t2 has the same address as frog_x
lw $t3, 0($t2)			# Fetch x position of frog
beq $t3, 0, hit_edge		# Do not move if you are already at the end of display
addi $t7, $zero, 1
sub $t3, $t3, $t7		# Move the frog to the left 
sw $t3, 0($t2)			# Store the new frog x position to frog_x
li $t4, 0x967bb8		# Lavender colour for frogs
jal draw_frog			# Call the draw frog function
hit_edge:

j skip_crash_river1		# Skip implementation of crash function
crash_river1:
li $t4, 0x8b0000				# Colour for draw_frog when frog dies
jal draw_frog
jal crash_func
skip_crash_river1:
skip_assess_river1:		# Skips assess_river2 (when y position of frog is not the same as the road2)

j skip_crash_func		# Skip the crash_func implementation

# FUNCTION: reset frog's position after dying AND delete a life
crash_func:
la $t2, frog_x 			# $t2 has the same address as frog_x
lw $t3, 0($t2)			# Fetch x position of frog
la $t2, frog_y 			# $t2 has the same address as frog_y
lw $t4, 0($t2)			# Fetch y position of frog
sll $t3, $t3, 2			# Multiply $t3 (frog x position) by 4
sll $t4, $t4, 7			# Multiply $t4 (frog y position) by 128
add $t1, $t1, $t3		# Add x offset to $t1
#add $t1, $t1, $t4		# Add y offset to $t1

# Reset frog's position to start 
addi $t9, $zero, 16 		# Reset x position
sw $t9, 0($t2)			# Store this reset position to frog_x
addi $t9, $zero, 28 		# Reset y position
sw $t9, 0($t2)			# Store this reset position to frog_y

addi $t8, $zero, 0
addi $t7, $zero, 1
la $t9, facing_forward			# Get the (1/0) value of facing_forward
sw $t7, 0($t9) 				# Set it to 0.
la $t9, facing_left			# Get the (1/0) value of facing_left
sw $t8, 0($t9) 				# Set it to 1.
la $t9, facing_right			# Get the (1/0) value of facing_right
sw $t8, 0($t9) 				# Set it to 0.
la $t9, facing_back			# Get the (1/0) value of facing_back
sw $t8, 0($t9) 				# Set it to 0.


# Delete a life 
la $t1, lives_left		# Load the address of lives_left
lw $t2, 0($t1) 			# Load the value of lives_left (0, 1, 2, 3)
addi $t3, $zero, 1		# Assgin $t3 the value of 1 
sub $t3, $t2, $t3 		# Use another register to minus one from the above value 
sw $t3, 0($t1) 			# Store this new value to lives_left 


# Generate sound tone  
li $v0, 31
li $a0, 39
li $a1, 500
li $a2, 65
li $a3, 110
syscall

li $v0, 32		# Sleep so that it pauses for a bt
li $a0, 500
syscall

jr $ra
skip_crash_func: 		# Skips the crash_func implementation



### FROG REACHES GOAL ###
# Check the frog position
la $t2, frog_y 					# $t2 has the same address as frog_y
lw $t4, 0($t2)					# Fetch y position of frog
sll $t4, $t4, 7					# Multiply $t4 (frog y position) by 128
addi $s1, $zero, 512				# Y position of the end goal (MAYBE CHANGE TO INCLUDE BOTH Y POSITIONS?
ble $t4, $s1, goal_reached			# If the frog's y position is smaller than the y position  of the end goal rectangle, go change target reached
# If the frog is at the end goal, then continue to change the memory address
j goal_not_reached
goal_reached:

# Make sound
li $v0, 33
li $a0, 69
li $a1, 100
li $a2, 16
li $a3, 110
syscall

goal_not_reached:


#### GAME OVER SCREEN #### 

j skip_game_over		# Skip over implementation of game_over
# Display game over screen

game_over:

# Set some values 
lw $t0, displayAddress
addi $a0, $zero, 32	# set height = 6
addi $a1, $zero, 32	# set width = 10
lw $t9, black 		# Get the colour black

# Paint screen black 
draw_black_screen:
	# Draw a rectangle:
	add $t1, $zero, $zero		# Set index value ($t1) to zero
	draw_black_rect_loop:
	beq $t1, $a0, done_draw_black 	# If $t1 == height ($a0), jump to end

	# Draw a line:
	add $t2, $zero, $zero		# Set index value ($t2) to zero
	draw_black_line_loop:
	beq $t2, $a1, end_draw_black_line  	# If $t2 == width ($a1), jump to end
	sw $t9, 0($t0)			#   Draw a pixel at memory location $t0
	addi $t0, $t0, 4		#   Increment $t0 by 4
	addi $t2, $t2, 1	#   Increment $t2 by 1
	j draw_black_line_loop	#   Jump to start of line drawing loop
	end_draw_black_line:

	addi $t1, $t1, 1	#   - Increment $t1 by 1
	j draw_black_rect_loop	#   - Jump to start of rectangle drawing loop

done_draw_black:		# When $t1 == height ($a0), the drawing is done.

# ---------
lw $t0, displayAddress
lw $t1, white			# Get the white colour and store to $t1

# Write the word game
lw $t2, game_x			# Get the x position of the word game
lw $t3, game_y			# Get the y position fo the word game 
sll $t2, $t2, 2			# Time game_x by 4
sll $t3, $t3, 7			# Time game_y by 128
add $t0, $t0, $t2		# Add the x position
add $t0, $t0, $t3		# Add the y position

# Row 1 
# G -
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Space between G and A 
addi $t0, $t0, 12		# End of letter_horizontal_line already goes forward 4 pixels

# A - 
sw $t1, 0($t0)

# Space between A and M 
addi $t0, $t0, 16

# M - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between M and E 
addi $t0, $t0, 8

# E - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Set up for the next row 
addi $t0, $t0, 36

# Row 2 
# G -
sw $t1, 0($t0)

# Space between G and A 
addi $t0, $t0, 28

# A - 
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)

# Space between A and M 
addi $t0, $t0, 12

# M - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 2		# width of stroke
jal letter_horizontal_line
addi $t0, $t0, 4
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 2		# width of stroke
jal letter_horizontal_line

# Space between M and E 
addi $t0, $t0, 4

# E - 
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 56

# Row 3
# G -
sw $t1, 0($t0)

# Space between G and A 
addi $t0, $t0, 24

# A - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between A and M 
addi $t0, $t0, 8

# M - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 2		# width of stroke
jal letter_horizontal_line
addi $t0, $t0, 4
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 2		# width of stroke
jal letter_horizontal_line

# Space between M and E 
addi $t0, $t0, 4

# E - 
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 56

# Row 4
# G -
sw $t1, 0($t0)
addi $t0, $t0, 8
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 3		# width of stroke
jal letter_horizontal_line

# Space between G and A 
addi $t0, $t0, 4

# A - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between A and M 
addi $t0, $t0, 8

# M - 
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)

# Space between M and E 
addi $t0, $t0, 8

# E - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Set up for the next row 
addi $t0, $t0, 36

# Row 5
# G -
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between G and A 
addi $t0, $t0, 8

# A - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Space between A and M 
addi $t0, $t0, 4

# M - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between M and E 
addi $t0, $t0, 8

# E - 
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 56

# Row 6
# G -
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between G and A 
addi $t0, $t0, 8

# A - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between A and M 
addi $t0, $t0, 8

# M - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between M and E 
addi $t0, $t0, 8

# E - 
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 56

# Row 7
# G -
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Space between G and A 
addi $t0, $t0, 4		# End of letter_horizontal_line already goes forward 4 pixels

# A - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between A and M 
addi $t0, $t0, 8

# M - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between M and E 
addi $t0, $t0, 8

# E -  
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Take to the end of the of display
addi $t0, $t0, 36



# Write the word over
lw $t0, displayAddress
lw $t2, over_x			# Get the x position of the word game
lw $t3, over_y			# Get the y position fo the word game 
sll $t2, $t2, 2			# Time game_x by 4
sll $t3, $t3, 7			# Time game_y by 128 
add $t0, $t0, $t2		# Add the x position
add $t0, $t0, $t3		# Add the y position


# Row 1 
# O -
addi $t0, $t0, 4
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 3		# width of stroke
jal letter_horizontal_line

# Space between O and V
addi $t0, $t0, 8		# End of letter_horizontal_line already goes forward 4 pixels

# V - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between V and E 
addi $t0, $t0, 8

# E - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Space between E and R 
addi $t0, $t0, 4

# R - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Set up for the next row 
addi $t0, $t0, 36

# Row 2
# O -
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between O and V
addi $t0, $t0, 8		# End of letter_horizontal_line already goes forward 4 pixels

# V - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between V and E 
addi $t0, $t0, 8

# E - 
sw $t1, 0($t0)

# Space between E and R 
addi $t0, $t0, 24

# R - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 40

# Row 3
# O -
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between O and V
addi $t0, $t0, 8		# End of letter_horizontal_line already goes forward 4 pixels

# V - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between V and E 
addi $t0, $t0, 8

# E - 
sw $t1, 0($t0)

# Space between E and R 
addi $t0, $t0, 24

# R - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 40

# Row 4
# O -
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between O and V
addi $t0, $t0, 8		# End of letter_horizontal_line already goes forward 4 pixels

# V - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between V and E 
addi $t0, $t0, 8

# E - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Space between E and R 
addi $t0, $t0, 4

# R - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Set up for the next row 
addi $t0, $t0, 36

# Row 5
# O -
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between O and V
addi $t0, $t0, 8		# End of letter_horizontal_line already goes forward 4 pixels

# V - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between V and E 
addi $t0, $t0, 8

# E - 
sw $t1, 0($t0)

# Space between E and R 
addi $t0, $t0, 24

# R - 
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 48


# Row 6
# O -
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Space between O and V
addi $t0, $t0, 12		# End of letter_horizontal_line already goes forward 4 pixels

# V - 
sw $t1, 0($t0)
addi $t0, $t0, 8
sw $t1, 0($t0)

# Space between V and E 
addi $t0, $t0, 12

# E - 
sw $t1, 0($t0)

# Space between E and R 
addi $t0, $t0, 24

# R - 
sw $t1, 0($t0)
addi $t0, $t0, 12
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 44

# Row 7
# O -
addi $t0, $t0, 4
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 3		# width of stroke
jal letter_horizontal_line

# Space between O and V
addi $t0, $t0, 16		# End of letter_horizontal_line already goes forward 4 pixels

# V - 
sw $t1, 0($t0)

# Space between V and E 
addi $t0, $t0, 16

# E - 
addi $a0, $zero, 1		# Height of stroke
addi $a1, $zero, 5		# width of stroke
jal letter_horizontal_line

# Space between E and R 
addi $t0, $t0, 4

# R - 
sw $t1, 0($t0)
addi $t0, $t0, 16
sw $t1, 0($t0)

# Set up for the next row 
addi $t0, $t0, 40

# Write Y/N
lw $t0, displayAddress
li $t1, 0xADD8E6		# Make the Y/N another colour 
lw $t2, yes_x			# Get the x position of the word game
lw $t3, yes_y			# Get the y position fo the word game 
sll $t2, $t2, 2			# Time game_x by 4
sll $t3, $t3, 7			# Time game_y by 128 
add $t0, $t0, $t2		# Add the x position
add $t0, $t0, $t3		# Add the y position

# Row 1 
# Y - 
sw $t1, 0($t0)
sw $t1, 8($t0)

# Space between Y and /
addi $t0, $t0, 16

# / -
sw $t1, 8($t0)

# Space between / and N
addi $t0, $t0, 16

# N -
sw $t1, 0($t0)
sw $t1, 12($t0)

# Set up for the next row 
addi $t0, $t0, 96

# Row 2 
# Y - 
sw $t1, 0($t0)
sw $t1, 8($t0)

# Space between Y and /
addi $t0, $t0, 16

# / -
sw $t1, 4($t0)

# Space between / and N
addi $t0, $t0, 16

# N -
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 12($t0)

# Set up for the next row 
addi $t0, $t0, 96

# Row 3 
# Y - 
sw $t1, 4($t0)

# Space between Y and /
addi $t0, $t0, 16

# / -
sw $t1, 4($t0)

# Space between / and N
addi $t0, $t0, 16

# N -
sw $t1, 0($t0)
sw $t1, 8($t0)
sw $t1, 12($t0)

# Set up for the next row 
addi $t0, $t0, 96

# Row 4 
# Y - 
sw $t1, 4($t0)

# Space between Y and /
addi $t0, $t0, 16

# / -
sw $t1, 0($t0)

# Space between / and N
addi $t0, $t0, 16

# N -
sw $t1, 0($t0)
sw $t1, 12($t0)

# Set up for the next row 
addi $t0, $t0, 96


j ask_restart				# After writing 'Game over' end the game 

j skip_horizontal_line_func
letter_horizontal_line:
add $s1, $zero, $zero 		# Set index value ($s1) to zero
draw_stroke_rect_loop:
beq $s1, $a0, done_stroke 	# If $t1 == height ($a0), jump to end
# Draw a line:
add $s2, $zero, $zero		# Set index value ($s2) to zero
draw_stroke_line_loop:
beq $s2, $a1, end_stroke_line  	# If $t2 == width ($a1), jump to end
sw $t1, 0($t0)			#   Draw a pixel at memory location $t0
addi $t0, $t0, 4		#   Increment $t0 by 4
addi $s2, $s2, 1		#   Increment $t2 by 1
j draw_stroke_line_loop	#   Jump to start of line drawing loop
end_stroke_line:

addi $s1, $s1, 1	#   - Increment $t1 by 1
j draw_stroke_rect_loop	#   - Jum
done_stroke:
jr $ra 
skip_horizontal_line_func: 

skip_game_over:		# Skip over implementation of game_over

j skip_ask_restart				# Skip implementation of ask_restart
ask_restart:
# Key stroke event to start game again
lw $t0, 0xffff0000				# Memory address of keyboard
beq $t0, 1, keyboard_input_r			# If there is a keystroke event, go to keyboard_input_r

j skip_keyboard_input_r				# If not, skip the keyboard_input_r function
keyboard_input_r:
lw $t1, 0xffff0004				# Load the value of the keystroke event
beq $t1, 0x79, respond_to_Y			# If the keystroke was Y, then go to respond_to_Y
j skip_Y					# If not, skip the implementation and check if it is N
	respond_to_Y: 				# Restart game 
	la $t9, lives_left
	addi $t8, $zero, 3
	sw $t8, 0($t9)				# Restart so give back all three lives 
	j play 					

skip_Y:
beq $t1, 0x6E, respond_to_N			# If the keystroke was N, then go to respond_to_N
j skip_N					# If not, skip the implementation 
	respond_to_N: 				# Don't restart game 
	jal done_screen
	j Exit
skip_N:
skip_keyboard_input_r:
j ask_restart
la $t9, keyboard				# Load the memory address of the keyboard
add $t8, $t9, $zero 				# Assign $t8 the keyboard address
addi $t7, $zero, 0				# Assign $t7 the value of 0
sw $t7, 0($t9) 	

skip_ask_restart:

j skip_done_screen
done_screen:
	lw $t0, displayAddress
	addi $a0, $zero, 32	# set height = 6
	addi $a1, $zero, 32	# set width = 10
	lw $t9, black 		# Get the colour black

	# Draw a rectangle:
	add $t1, $zero, $zero		# Set index value ($t1) to zero
	draw_exit_rect_loop:
	beq $t1, $a0, done_draw_exit 	# If $t1 == height ($a0), jump to end

	# Draw a line:
	add $t2, $zero, $zero		# Set index value ($t2) to zero
	draw_exit_line_loop:
	beq $t2, $a1, end_draw_exit_line  	# If $t2 == width ($a1), jump to end
	sw $t9, 0($t0)			#   Draw a pixel at memory location $t0
	addi $t0, $t0, 4		#   Increment $t0 by 4
	addi $t2, $t2, 1	#   Increment $t2 by 1
	j draw_exit_line_loop	#   Jump to start of line drawing loop
	end_draw_exit_line:

	addi $t1, $t1, 1	#   - Increment $t1 by 1
	j draw_exit_rect_loop	#   - Jump to start of rectangle drawing loop
	done_draw_exit:
jr $ra 
skip_done_screen:
### Sleep ###
li $v0, 32
li $a0, 50
syscall


j repaint		# Loop up to the very top again for repainting
					
##### EXIT ######
						
Exit:
# ---
li $v0, 10 # terminate the program gracefully
syscall
