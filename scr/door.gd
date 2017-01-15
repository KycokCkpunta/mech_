extends Area2D

onready var anim = get_node("anim")
onready var main_node = get_tree().get_current_scene()
onready var par_name = get_parent().get_name()
var door_opened = false
var boxes = []

var next_anim = ""

func _ready():
	if get_parent().is_horz:
		set_rotd(0)
	else:
		set_rotd(90)
	if get_name() == "door_0":
		set_pos(get_parent().start_point)
	elif get_name() == "door_1":
		set_pos(get_parent().end_point)
	
	var spat = Spatial.new()
	var par_pos = get_parent().get_pos()
	
	spat.set_name(par_name)
	spat.set_translation(Vector3(par_pos.x/16,0,par_pos.y/16))
	main_node.get_node("3d").add_child(spat)
	for c in range(2):
		var door3d = load("res://scn/3d_door.tscn").instance()
		door3d.set_name("door_"+str(c))
		if door3d.get_name() == "door_0":
			door3d.set_translation(Vector3(get_parent().start_point.x/16-0.5,0,get_parent().start_point.y/16-0.5))
		elif door3d.get_name() == "door_1":
			door3d.set_translation(Vector3(get_parent().end_point.x/16-0.5,0,get_parent().end_point.y/16-0.5))
			
		if get_parent().is_horz:
			door3d.set_rotation(Vector3(0,0,0))
		else:
			door3d.set_rotation(Vector3(0,deg2rad(90),0))
		main_node.get_node("3d/"+par_name).add_child(door3d)
		
	main_node.get_node("3d").get_node(par_name+"/"+get_name()+"/anim").play("close")
	
	set_process(true)

func _process(delta):
	if not anim.is_playing() and anim.get_current_animation() != next_anim:
		anim.play(next_anim)
		main_node.get_node("3d").get_node(par_name+"/"+get_name()+"/anim").play(next_anim)

func _on_door_body_enter( body ):
	if body.get_name() in ["gg","mech"] and not door_opened:
		door_opened = true
		next_anim = "open"


func _on_door_body_exit( body ):
	if body.get_name() in ["gg","mech"] and door_opened:
		door_opened = false
		next_anim = "close"
