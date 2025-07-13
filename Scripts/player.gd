extends CharacterBody3D

@export var animation_tree : AnimationTree
@export var animation_player : AnimationPlayer
@onready var animation_state = animation_tree.get("parameters/playback")
@export var camera: Camera3D 

var inputdir = Vector3()

var anim_canmove = bool()

var direction = Vector3()
var vertical_velocity = Vector3()
var turn_speed = 2
var root_velocity = Vector3()
var Cooldown = 0
var SprintCooldown = 0
var AttackCooldown = 0
var AttackCooldownStack = 0

var horizontal = float()
var vertical = float()

@export var gravity: float = 9
@export var max_fall_speed: float = 9
var cam_speed = 5
func _process(delta):
	horizontal = Input.get_axis("stepleft","stepright")
	vertical = Input.get_axis("run","backward")
	
	var root_pos = animation_tree.get_root_motion_position()
	
	#var current_rotation = (animation_tree.get_root_motion_rotation_accumulator().inverse() * get_quaternion())
	var current_rotation = (animation_tree.get_root_motion_rotation_accumulator().inverse())
	root_velocity = current_rotation * root_pos * (global_transform.basis).inverse() / delta
	#root_velocity = root_pos * global_transform.basis / delta
	var root_rotation = animation_tree.get_root_motion_rotation()
	#set_quaternion(get_quaternion() * root_rotation)

func _physics_process(delta):
	
	$AnimationTree.set("parameters/conditions/idle", !anim_canmove && Cooldown == 0)
	$AnimationTree.set("parameters/conditions/backflip", Input.is_action_just_pressed("backflip"))
	$AnimationTree.set("parameters/conditions/dodge", Input.is_action_just_pressed("dodge"))
	$AnimationTree.set("parameters/conditions/stepleft", Input.is_action_just_pressed("stepleft"))
	$AnimationTree.set("parameters/conditions/stepright", Input.is_action_just_pressed("stepright"))
	$AnimationTree.set("parameters/conditions/backpedal", Input.is_action_just_pressed("backward"))
	$AnimationTree.set("parameters/conditions/run", Input.is_action_pressed("run"))
	$AnimationTree.set("parameters/conditions/action1", Input.is_action_just_pressed("button1") && AttackCooldown == 0)
	$AnimationTree.set("parameters/conditions/action2", Input.is_action_just_pressed("button2") && AttackCooldown == 0)
	
	if Input.is_action_pressed("run") and SprintCooldown == 0 :
		Cooldown = 5
	if Input.is_action_just_pressed("run") :
		SprintCooldown = 15 
	
	if Input.is_action_just_pressed("button1") :
		Cooldown = 15
		AttackCooldown = 8 + AttackCooldownStack
		AttackCooldownStack += 4
	
	if Input.is_action_just_pressed("button2"):
		AttackCooldown = 8 + AttackCooldownStack
		AttackCooldownStack += 4
		
	if SprintCooldown > 0:
		SprintCooldown -= 1
		if SprintCooldown <=0.0:
			pass
	if Cooldown > 0:
		Cooldown -= 1
		if Cooldown <= 0.0:
			pass
	
	if AttackCooldown > 0:
		AttackCooldown -= 1
		if AttackCooldown <= 0.0:
			AttackCooldownStack = 0
	
	var cam_basis = camera.global_transform.basis
	var cam_forward = -cam_basis.z
	var cam_right = cam_basis.x
	
	inputdir = (cam_forward * vertical + cam_right * horizontal).normalized()
	
	var turn_direction = 0
	if Input.is_action_pressed("turnleft"):
		turn_direction -= 1
	if Input.is_action_pressed("turnright"):
		turn_direction += 1
	rotation.y -= turn_direction * turn_speed * delta
	if not is_on_floor():
		vertical_velocity.y += gravity * delta
		vertical_velocity.y = min(vertical_velocity.y, max_fall_speed)
	else:
		vertical_velocity.y = 0
	
	if inputdir != Vector3.ZERO:
		anim_canmove = true
	else:
		anim_canmove = false
	velocity = root_velocity
	velocity.y = -vertical_velocity.y
	
	move_and_slide()
