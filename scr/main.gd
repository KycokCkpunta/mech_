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
var map_zoom = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process(true)

func _process(delta):
	mouse_pos = get_local_mouse_pos()
	
	if mech.isActive == true:
		pl_pos = mech.get_pos()
	if gg.isActive == true:
		pl_pos = gg.get_pos()
	#camera
	camera.set_pos(Vector2(lerp(pl_pos.x,(mouse_pos.x+pl_pos.x)/2,0.5),lerp(pl_pos.x,(mouse_pos.y+pl_pos.y)/2,0.5)))
	cam_zoom = clamp(0.5+pl_pos.distance_to(mouse_pos)/5000,0.5,2)
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
	cur.get_node("bb").set_opacity(2-map_zoom)
	if Input.is_action_pressed("map"):
		map_zoom=lerp(map_zoom,8,delta*5)
	else:
		map_zoom=lerp(map_zoom,camera.get_zoom().x,delta*5)