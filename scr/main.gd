extends Node2D

var mouse_pos = Vector2(0,0)
var pl_pos = Vector2(0,0)

onready var cur = get_node("cur")
onready var camera = get_node("Camera2D")
onready var map_camera = get_node("Camera2D/map_cam")
onready var mech = get_node("mech")
onready var gg = get_node("gg")
var cur_scale = 2
var old_pos = Vector2()
var cam_zoom = 0
var map_zoom = 8
var far_zoom = 4096

var near_rooms = []

var isScnReady = false

func _ready():
	#init
	get_node("floor").optimize()
	if mech.isActive == true:
		mech.get_node("3d_view").hide()
		mech.get_node("Light2D").hide()
	if gg.isActive == true:
		gg.get_node("3d_view").hide()
		gg.get_node("Light2D").hide()
	get_tree().set_pause(true)
	
	#1-st lvl scenery
	var gg_start_pos = get_node("floor").get_start_pos()
	var mech_end_pos = get_node("floor").get_end_pos()
	gg.set_pos(gg_start_pos)
	camera.set_pos(gg.get_pos())
	mech.set_pos(mech_end_pos)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process(true)

func _process(delta):
	mouse_pos = get_global_mouse_pos()
	
	if mech.isActive == true:
		pl_pos = mech.get_pos()
	if gg.isActive == true:
		pl_pos = gg.get_pos()
	#camera
	camera.set_pos(pl_pos.linear_interpolate((mouse_pos+pl_pos)/2,0.75))
	cam_zoom = clamp(0.5+pl_pos.distance_to(mouse_pos)/far_zoom,0.5,2)
	camera.set_zoom(Vector2(cam_zoom,cam_zoom))
	
	#cursor
	cur_scale+=Vector2(0,0).distance_to(mouse_pos-old_pos)/25
	old_pos=mouse_pos
	cur.set_pos(mouse_pos)
	cur_scale=clamp(cur_scale,1,1.5)
	cur_scale=lerp(cur_scale,cur_scale-0.1,delta*25)
	cur.set_scale(Vector2(cur_scale,cur_scale))
	
	#map
	map_camera.set_zoom(Vector2(map_zoom,map_zoom))
	if Input.is_action_pressed("map"):
		map_zoom=lerp(map_zoom,8,delta*5)
		get_node("floor").optimize()
		if mech.isActive == true:
			mech.get_node("3d_view").hide()
			mech.get_node("Light2D").hide()
		if gg.isActive == true:
			gg.get_node("3d_view").hide()
			gg.get_node("Light2D").hide()
		get_tree().set_pause(true)
	else:
		map_zoom=lerp(map_zoom,camera.get_zoom().x,delta*5)
		if map_zoom < 2:
			get_node("floor").deoptimize()
			if mech.isActive == true:
				mech.get_node("3d_view").show()
				mech.get_node("Light2D").show()
			if gg.isActive == true:
				gg.get_node("3d_view").show()
				gg.get_node("Light2D").show()
			get_tree().set_pause(false)