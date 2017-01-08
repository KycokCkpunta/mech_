extends KinematicBody2D

onready var base = get_node("base")
onready var base_pos = get_node("base/base_pos")
onready var top = get_node("top")
onready var _pos = get_node("pos")
onready var _rot = get_node("rot")
onready var anim = get_node("anim")
onready var l_arm = get_node("top/l_arm")
onready var r_arm = get_node("top/r_arm")
onready var l_arm_rot = get_node("top/l_arm_rot")
onready var r_arm_rot = get_node("top/r_arm_rot")

var move_vector = Vector2(0,0)
var base_move_vector = Vector2(0,0)
var base_new_pos = Vector2(0,1)
var mouse_pos = Vector2(0,0)

var walk_v = true

var new_anim = "idle"

var isActive = false
var canEnter = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	#base-top
	mouse_pos=get_parent().mouse_pos
	l_arm.set_rot(lerp(l_arm.get_rot(),l_arm_rot.get_rot(),delta*15))
	r_arm.set_rot(lerp(r_arm.get_rot(),r_arm_rot.get_rot(),delta*15))
	if isActive:
		_rot.look_at(mouse_pos)
		l_arm_rot.look_at(mouse_pos)
		r_arm_rot.look_at(mouse_pos)
		top.set_rot(lerp(top.get_rot(),_rot.get_rot(),delta*10))
		base.set_rot(lerp(base.get_rot(),top.get_rot()+_pos.get_angle_to(base_pos.get_pos()+get_pos()),delta*5))
		base_pos.set_pos(base_pos.get_pos().linear_interpolate(base_new_pos,delta*10))
		get_node("Light2D").set_enabled(true)
		
		if Input.is_action_just_pressed("mount"):
			isActive = false
			get_parent().mech_mount()
	else:
		get_node("Light2D").set_enabled(false)
		
#	#input
	if Input.is_action_pressed("walk_fw"):
		base_new_pos+=Vector2(0,1)
		base_move_vector+=Vector2(0,-1)
		walk_v = true
	if Input.is_action_pressed("walk_bk"):
		base_new_pos+=Vector2(0,1)
		base_move_vector+=Vector2(0,1)
		walk_v = false
	if Input.is_action_pressed("walk_l"):
		if walk_v:
			base_new_pos+=Vector2(1,0)
		else:
			base_new_pos+=Vector2(-1,0)
		base_move_vector+=Vector2(-1,0)
	if Input.is_action_pressed("walk_r"):
		if walk_v:
			base_new_pos+=Vector2(-1,0)
		else:
			base_new_pos+=Vector2(1,0)
		base_move_vector+=Vector2(1,0)
	base_new_pos=base_new_pos.normalized()
	base_move_vector=base_move_vector.normalized()
	#global_move_vector
	if walk_v:
		move_vector=Vector2(0,1).rotated(base.get_rot())
	else:
		move_vector=Vector2(0,-1).rotated(base.get_rot())
	if (Input.is_action_pressed("walk_fw") or
	Input.is_action_pressed("walk_bk") or
	Input.is_action_pressed("walk_l") or
	Input.is_action_pressed("walk_r")) and isActive:
		if walk_v:
			move_vector=Vector2(0,1).rotated(base.get_rot())
		else:
			move_vector=Vector2(0,-1).rotated(base.get_rot())
		new_anim = "walk"
	else:
		move_vector=Vector2(0,0)
		new_anim = "idle"
	move(move_vector*delta*36)
	var slide_attempts = 4
	while(is_colliding() and slide_attempts > 0):
		move_vector = get_collision_normal().slide(move_vector)
		move_vector = move(move_vector*delta*16)
		slide_attempts -= 1
	#animating
	if anim.get_current_animation() != new_anim:
		anim.play(new_anim)

func _on_mount_area_body_enter( body ):
	if body.get_name() == "gg":
		canEnter = true


func _on_mount_area_body_exit( body ):
	if body.get_name() == "gg":
		canEnter = false
