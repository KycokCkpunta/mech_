extends KinematicBody2D

onready var head = get_node("head")
onready var base = get_node("base")

var mouse_pos = Vector2(0,0)
var move_vector = Vector2(0,0)
var base_move_vector = Vector2(0,1)
var base_new_pos = Vector2(0,0)

var isActive = true
var alive = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	mouse_pos = get_parent().mouse_pos
	if isActive:
		show()
		get_node("CollisionShape2D").set_trigger(false)
		get_node("Light2D").set_enabled(true)
		head.look_at(mouse_pos)
		
		if Input.is_action_just_pressed("mount") and get_parent().get_node("mech").canEnter:
			if alive:
				get_parent().get_node("mech").isActive = true
				isActive = false
			alive = true
		
	else:
		set_pos(get_parent().get_node("mech").get_pos())
		get_node("CollisionShape2D").set_trigger(true)
		get_node("Light2D").set_enabled(false)
		hide()
		alive = false
		
	base.set_rot(lerp(base.get_rot(),head.get_rot(),delta*10))
	
	if Input.is_action_pressed("walk_fw"):
		base_new_pos+=Vector2(0,1)
		base_move_vector+=Vector2(0,1)
	if Input.is_action_pressed("walk_bk"):
		base_new_pos+=Vector2(0,1)
		base_move_vector+=Vector2(0,-1)
	if Input.is_action_pressed("walk_l"):
		if base_move_vector.y >= 0:
			base_new_pos+=Vector2(1,0)
		else:
			base_new_pos+=Vector2(-1,0)
		base_move_vector+=Vector2(-1,0)
	if Input.is_action_pressed("walk_r"):
		if base_move_vector.y >= 0:
			base_new_pos+=Vector2(-1,0)
		else:
			base_new_pos+=Vector2(1,0)
		base_move_vector+=Vector2(1,0)
	base_new_pos=base_new_pos.normalized()
	base_move_vector=base_move_vector.normalized()
	
	if (Input.is_action_pressed("walk_fw") or
	Input.is_action_pressed("walk_bk") or
	Input.is_action_pressed("walk_l") or
	Input.is_action_pressed("walk_r")) and isActive:
		if base_move_vector.y >= 0:
			move_vector=Vector2(0,-1).rotated(base.get_rot()).rotated(Vector2(0,0).angle_to_point(base_new_pos))
		else:
			move_vector=Vector2(0,1).rotated(base.get_rot()).rotated(Vector2(0,0).angle_to_point(base_new_pos))
	else:
		move_vector=Vector2(0,0)
	
	move(move_vector*delta*36)
	var slide_attempts = 4
	while(is_colliding() and slide_attempts > 0):
		move_vector = get_collision_normal().slide(move_vector)
		move_vector = move(move_vector*delta*16)
		slide_attempts -= 1