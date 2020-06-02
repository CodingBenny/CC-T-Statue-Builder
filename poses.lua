-- Each cube lower right front corner first with {height, depth, width} 

return {
default = {
	head = {{24,0,4}},
	torso = {{12,2,4}},
	right_leg = {{0,2,4}},
	left_leg = {{0,2,8}},
	right_arm_small = {{12,2,1}},
	right_arm_big = {{12,2,0}},
	left_arm_big = {{12,2,12}},
	},
head = {
	head = {{0,1,0}},
	},
in_chair = {
	lower_right_leg = {{0,1,4}},
	lower_left_leg = {{0,1,8}},
	upper_right_leg = {{6,1,4},{0,0,-math.pi/2}},
	upper_left_leg = {{6,1,8},{0,0,-math.pi/2}},
	torso = {{6,7,4}},
	lower_right_arm_big = {{12,1,0},{0,0,-math.pi/2}},
	lower_left_arm_big = {{12,1,12},{0,0,-math.pi/2}},
	upper_right_arm_big = {{12,7,0}},
	upper_left_arm_big = {{12,7,12}},
	head = {{18,5,4}}
	}
}