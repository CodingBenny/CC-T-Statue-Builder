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
head_only = {
	head = {{2,1,2}},
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
	},
raised_pick_right = {
	head = {{24,14,4}},
	torso = {{12,16,4}},
	right_leg = {{0,16,4}},
	left_leg = {{0,16,8}},
	right_arm_small = {{20,8,1},{0,0,-math.pi/2}},
	right_arm_big = {{20,8,0},{0,0,-math.pi/2}},
	left_arm_big = {{12,16,12}},
	assets={
		{"https://assets.mcasset.cloud/1.13/assets/minecraft/textures/item/diamond_pickaxe.png",{18,14,2},{math.pi/2,0,0}}
	}},
raised_pick_left = {
	head = {{24,14,4}},
	torso = {{12,16,4}},
	right_leg = {{0,16,4}},
	left_leg = {{0,16,8}},
	right_arm_small = {{12,16,1}},
	right_arm_big = {{12,16,0}},
	left_arm_big = {{20,8,12},{0,0,-math.pi/2}},
	assets={
		{"https://assets.mcasset.cloud/1.13/assets/minecraft/textures/item/diamond_pickaxe.png",{18,14,13},{math.pi/2,0,0}}
	}},
raised_sword_right = {
	head = {{24,17,4}},
	torso = {{12,19,4}},
	right_leg = {{0,19,4}},
	left_leg = {{0,19,8}},
	right_arm_small = {{20,11,1},{0,0,-math.pi/2}},
	right_arm_big = {{20,11,0},{0,0,-math.pi/2}},
	left_arm_big = {{12,19,12}},
	assets={
		{"https://assets.mcasset.cloud/1.13/assets/minecraft/textures/item/diamond_sword.png",{19,15,2},{math.pi/2,0,0}}
		--{"https://assets.mcasset.cloud/1.13/assets/minecraft/textures/item/diamond_sword.png",{19,13,2},{math.pi/2,0,-math.pi/3}}
	}},
raised_sword_left = {
	head = {{24,17,4}},
	torso = {{12,19,4}},
	right_leg = {{0,19,4}},
	left_leg = {{0,19,8}},
	right_arm_small = {{12,19,1}},
	right_arm_big = {{12,19,0}},
	left_arm_big = {{20,11,12},{0,0,-math.pi/2}},
	assets={
		{"https://assets.mcasset.cloud/1.13/assets/minecraft/textures/item/diamond_sword.png",{19,15,13},{math.pi/2,0,0}}
	}},
kneeling_sword_right = {
	head = {{18,17,4}},
	torso = {{6,19,4}},
	lower_right_leg = {{0,23,4},{0,0,math.pi/2}},
	lower_left_leg = {{0,13,8}},
	upper_right_leg = {{0,19,4}},
	upper_left_leg = {{6,13,8},{0,0,-math.pi/2}},
	right_arm_small = {{14,11,1},{0,0,-math.pi/2}},
	right_arm_big = {{14,11,0},{0,0,-math.pi/2}},
	left_arm_big = {{6,19,12}},
	assets={
		{"https://assets.mcasset.cloud/1.13/assets/minecraft/textures/item/diamond_sword.png",{13,15,2},{math.pi/2,0,0}}
	}},
kneeling_sword_left = {
	head = {{18,17,4}},
	torso = {{6,19,4}},
	lower_right_leg = {{0,13,4}},
	lower_left_leg = {{0,23,8},{0,0,math.pi/2}},
	upper_right_leg = {{6,13,4},{0,0,-math.pi/2}},
	upper_left_leg = {{0,19,8}},
	right_arm_small = {{6,19,1}},
	right_arm_big = {{6,19,0}},
	left_arm_big = {{14,11,12},{0,0,-math.pi/2}},
	assets={
		{"https://assets.mcasset.cloud/1.13/assets/minecraft/textures/item/diamond_sword.png",{13,15,13},{math.pi/2,0,0}}
	}},
sitting_low = {
	head = {{12,10,4}},
	torso = {{0,12,4}},
	right_leg = {{0,0,4},{0,0,-math.pi/2}},
	left_leg = {{0,0,8},{0,0,-math.pi/2}},
	right_arm_small = {{0,12,1}},
	right_arm_big = {{0,12,0}},
	left_arm_big = {{0,12,12}},
	},
sitting = {
	head = {{16,6,4}},
	torso = {{4,8,4}},
	right_leg = {{0,0,4},{0,0,-math.pi/2}},
	left_leg = {{0,0,8},{0,0,-math.pi/2}},
	right_arm_small = {{4,8,1}},
	right_arm_big = {{4,8,0}},
	left_arm_big = {{4,8,12}},
	},
bow = {
	head = {{10,0,4},{0,0,math.pi/2}},
	torso = {{12,8,4},{0,0,math.pi/2}},
	right_leg = {{0,16,4}},
	left_leg = {{0,16,8}},
	right_arm_small = {{12,8,1},{0,0,math.pi/2}},
	right_arm_big = {{12,8,0},{0,0,math.pi/2}},
	left_arm_big = {{12,8,12},{0,0,math.pi/2}},
	},
ringer= {
	head = {{18,1,10}},
	torso = {{6,3,10}},
	lower_right_leg = {{0,3,4},{math.pi/2,0,0}},
	lower_left_leg = {{0,3,20},{-math.pi/2,0,0}},
	upper_right_leg = {{6,3,4},{0,math.pi/2,-math.pi/2}},
	upper_left_leg = {{6,3,18},{0,-math.pi/2,-math.pi/2}},
	upper_right_arm_small = {{12,4,4},{0,math.pi/2,-math.pi/2}},
	lower_right_arm_small = {{12,-2,4},{0,0,-math.pi/2}},
	upper_left_arm_small = {{12,4,18},{0,-math.pi/2,-math.pi/2}},
	lower_left_arm_small = {{12,-2,21},{0,0,-math.pi/2}},
	upper_right_arm_big = {{12,3,4},{0,math.pi/2,-math.pi/2}},
	lower_right_arm_big = {{12,-3,4},{0,0,-math.pi/2}},
	upper_left_arm_big = {{12,3,18},{0,-math.pi/2,-math.pi/2}},
	lower_left_arm_big = {{12,-3,20},{0,0,-math.pi/2}},
	},
kick = {
	head = {{24,10,12}},
	torso = {{12,12,12}},
	right_leg = {{12,0,12},{0,0,-math.pi/2}},
	left_leg = {{0,12,16}},
	right_arm_small = {{21,12,0},{0,math.pi/2,0}},
	right_arm_big = {{20,12,0},{0,math.pi/2,0}},
	left_arm_small = {{21,12,20},{0,-math.pi/2,0}},
	left_arm_big = {{20,12,20},{0,-math.pi/2,0}},
	},
sunbath = {
	head = {{0,24,4},{0,0,-math.pi/2}},
	torso = {{0,12,4},{0,0,-math.pi/2}},
	right_leg = {{0,0,4},{0,0,-math.pi/2}},
	left_leg = {{0,0,8},{0,0,-math.pi/2}},
	right_arm_small = {{0,12,1},{0,0,-math.pi/2}},
	right_arm_big = {{0,12,0},{0,0,-math.pi/2}},
	left_arm_big = {{0,12,12},{0,0,-math.pi/2}},
	},
}
