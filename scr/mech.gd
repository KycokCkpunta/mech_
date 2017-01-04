extends KinematicBody2D

onready var base = get_node("base")
onready var base_pos = get_node("base/base_pos")
onready var top = get_node("top")
onready var _pos = get_node("pos")

var move_vector = Vector2(0,0)
var base_move_vector = Vector2(0,0)
var base_new_pos = Vector2(0,1)
var mouse_pos = Vector2(0,0)


func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	mouse_pos=get_parent().mouse_pos
	top.look_at(mouse_pos)
	base.set_rot(lerp(base.get_rot(),top.get_rot()+_pos.get_angle_to(base_pos.get_pos()+get_pos()),delta*5))
	base_pos.set_pos(base_pos.get_pos().linear_interpolate(base_new_pos,delta*10))
#	#input
	if Input.is_action_pressed("walk_fw"):
		base_new_pos+=Vector2(0,1)
		base_move_vector+=Vector2(0,-1)
	if Input.is_action_pressed("walk_bk"):
		base_new_pos+=Vector2(0,1)
		base_move_vector+=Vector2(0,1)
	if Input.is_action_pressed("walk_l"):
		if base_move_vector.y < 0:
			base_new_pos+=Vector2(1,0)
		else:
			base_new_pos+=Vector2(-1,0)
		base_move_vector+=Vector2(-1,0)
	if Input.is_action_pressed("walk_r"):
		if base_move_vector.y < 0:
			base_new_pos+=Vector2(-1,0)
		else:
			base_new_pos+=Vector2(1,0)
		base_move_vector+=Vector2(1,0)
	base_new_pos=base_new_pos.normalized()
	base_move_vector=base_move_vector.normalized()
	#global_move_vector
	if base_move_vector.y < 0:
		move_vector=Vector2(0,1).rotated(base.get_rot())
	else:
		move_vector=Vector2(0,-1).rotated(base.get_rot())
	if (Input.is_action_pressed("walk_fw") or
	Input.is_action_pressed("walk_bk") or
	Input.is_action_pressed("walk_l") or
	Input.is_action_pressed("walk_r")):
		if base_move_vector.y < 0:
			move_vector=Vector2(0,1).rotated(base.get_rot())
		else:
			move_vector=Vector2(0,-1).rotated(base.get_rot())
	else:
		move_vector=Vector2(0,0)
	move(move_vector*delta*32)
	
	var slide_attempts = 4
	while(is_colliding() and slide_attempts > 0):
		move_vector = get_collision_normal().slide(move_vector)
		move_vector = move(move_vector*delta*16)
		slide_attempts -= 1
	update()

func _draw():
	draw_line(base.get_pos(),base.get_pos()+move_vector*25,Color(1,1,0),3,true)
