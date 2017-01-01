
extends KinematicBody2D

onready var top = get_node("top")
onready var base = get_node("base")
onready var anim = get_node("base_anim")
onready var lhand = get_node("top/lhand")
onready var rhand = get_node("top/rhand")
onready var lfwpoint = get_node("top/lhand_fw")
onready var rfwpoint = get_node("top/rhand_fw")

onready var lhandlook = lhand.get_node("look")
onready var rhandlook = rhand.get_node("look")

var aim_ev = true
var aim = true
var shoot = true

export var MOTION_SPEED = 16
var ROTATION_SPEED = 4
var SMOOTH_SPEED = 8.0

var moveVector = Vector2()

var base_rot_target = 0 #target in radians

var base_walk_rot = 0
var base_last_rot = 0

var move_h = Vector2(0,0) #added speed forward-back
var move_v = Vector2(0,0) #added speed left-right
var top_h = Vector2(0,0)
var top_v = Vector2(0,0)

var current_anim = "idle"
var new_anim = "idle"

export var debug = false

##Debug
var move_line = Vector2()

func _ready():
	set_fixed_process(true)

func _draw():
	if debug:
		draw_line(base.get_pos(), move_line, Color (0,1,0), 2.0)
	

func _fixed_process(delta):
	#######
	top_h = get_node("top/point_h")
	top_v = get_node("top/point_v")
	#####
	if Input.is_action_pressed("walk_fw"):
		moveVector += Vector2(0, -1)
	if Input.is_action_pressed("walk_bk"):
		moveVector += Vector2(0, 1)
	if Input.is_action_pressed("walk_l"):
		moveVector += Vector2(-1, 0)
	if Input.is_action_pressed("walk_r"):
		moveVector += Vector2(1, 0)
	#####mouse_ev
	if Input.is_action_pressed("aim_ev") and not aim_ev:
		aim_ev = true
	if not Input.is_action_pressed("aim_ev") and aim_ev:
		aim_ev = false
		
	if Input.is_action_pressed("aim") and not aim:
		aim = true
	if not Input.is_action_pressed("aim") and aim:
		aim = false
		
	if Input.is_action_pressed("shoot") and not shoot:
		shoot = true
	if not Input.is_action_pressed("shoot") and shoot:
		shoot = false
	#####
	var mpos = get_global_mouse_pos()
	
	var ang = top.get_angle_to(mpos)
	var s = sign(ang)
	ang = abs(ang)
	
	top.rotate(min(ang, ROTATION_SPEED*delta)*s)
	
	if aim_ev == true:
		var ang = lhand.get_angle_to(mpos)
		var s = sign(ang)
		ang = abs(ang)
		lhand.rotate(min(ang, ROTATION_SPEED/2*delta)*s)
		var ang = rhand.get_angle_to(mpos)
		var s = sign(ang)
		ang = abs(ang)
		rhand.rotate(min(ang, ROTATION_SPEED/2*delta)*s)
	else:
		var ang = lhand.get_angle_to(lfwpoint.get_global_pos())
		var s = sign(ang)
		ang = abs(ang)
		lhand.rotate(min(ang, ROTATION_SPEED/2*delta)*s)
		var ang = rhand.get_angle_to(rfwpoint.get_global_pos())
		var s = sign(ang)
		ang = abs(ang)
		rhand.rotate(min(ang, ROTATION_SPEED/2*delta)*s)
	
		
	if (moveVector == Vector2 (0,0)):
		
		if ( (rad2deg(base.get_rot()) - rad2deg(top.get_rot()) ) > 65 ):
			base_rot_target = top.get_rot()
		elif ( (rad2deg(base.get_rot()) - rad2deg(top.get_rot()) ) < -65 ):
			base_rot_target = top.get_rot()
		base.set_rot(lerp (base.get_rot(), base_rot_target, 0.05))
		new_anim = "idle"
		move_line = Vector2()
		
	elif (moveVector != Vector2 (0,0)):
		
		base_rot_target = top.get_rot()
		if not aim:
			if (moveVector.y < 0):
				move_v = top_v.get_global_pos() - base.get_global_pos()
				base_walk_rot = top.get_rot()
			elif (moveVector.y > 0):
				move_v = base.get_global_pos() - top_v.get_global_pos()
				base_walk_rot = top.get_rot()
			if (moveVector.x < 0):
				move_h = top_h.get_global_pos() - base.get_global_pos()
				if moveVector.y > 0:
					base_walk_rot = top.get_rot()-deg2rad(45)
				elif moveVector.y < 0:
					base_walk_rot = top.get_rot()+deg2rad(45)
				else:
					base_walk_rot = top.get_rot()+deg2rad(90)
			elif (moveVector.x > 0):
				move_h = base.get_global_pos() - top_h.get_global_pos()
				if moveVector.y > 0:
					base_walk_rot = top.get_rot()+deg2rad(45)
				elif moveVector.y < 0:
					base_walk_rot = top.get_rot()-deg2rad(45)
				else:
					base_walk_rot = top.get_rot()-deg2rad(90)
			base.set_rot(lerp (base.get_rot(), base_walk_rot, 0.05))
			new_anim = "walk"
			moveVector = move_h + move_v
			base_last_rot = base_walk_rot
		else:
			get_node("base_rot").set_rot(base_last_rot)
			if (moveVector.y < 0):
				base_walk_rot = base_last_rot
				move_v = get_node("base_rot/point_v").get_global_pos() - base.get_global_pos()
			elif (moveVector.y > 0):
				base_walk_rot = base_last_rot
				move_v =  base.get_global_pos() - get_node("base_rot/point_v").get_global_pos()
			if (moveVector.x < 0):
				move_h = get_node("base_rot/point_h").get_global_pos() - base.get_global_pos()
				if moveVector.y > 0:
					base_walk_rot = base_last_rot-deg2rad(45)
				elif moveVector.y < 0:
					new_anim = "walk"
					base_walk_rot = base_last_rot+deg2rad(45)
				else:
					base_walk_rot = base_last_rot+deg2rad(90)
			if (moveVector.x > 0):
				move_h = base.get_global_pos() - get_node("base_rot/point_h").get_global_pos()
				if moveVector.y > 0:
					base_walk_rot = base_last_rot+deg2rad(45)
				elif moveVector.y < 0:
					base_walk_rot = base_last_rot-deg2rad(45)
				else:
					base_walk_rot = base_last_rot-deg2rad(90)
			new_anim = "walk"
			base.set_rot(lerp (base.get_rot(), base_walk_rot, 0.05))
			moveVector = move_h + move_v
	
	moveVector = moveVector.normalized()*MOTION_SPEED*delta
	
	if debug:
		move_line = moveVector*200
		update()
	
	moveVector= move(moveVector)
	var slide_attempts = 4
	while(is_colliding() and slide_attempts > 0):
		moveVector = get_collision_normal().slide(moveVector)
		moveVector = move(moveVector)
		slide_attempts -= 1
	move_h = Vector2()
	move_v = Vector2()
	
	if current_anim != new_anim:
		current_anim = new_anim
		anim.play(current_anim)
	