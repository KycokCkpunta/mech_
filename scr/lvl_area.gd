extends Area2D

onready var mapE = get_node("map_expl")

var size = Vector2()
var room = ""
var connected_rooms = []
var end_point = Vector2()
var start_point = Vector2()
var is_horz = true


var isIn = false
var explored = false

var isStart = false

func _ready():
	var shape = RectangleShape2D.new()
	shape.set_name(room+"_col")
	shape.set_extents(size)
	add_shape(shape)
	get_node("col").set_shape(shape)
	mapE.set_scale(size/16)
	set_name(room)
	
	if is_horz:
		start_point = Vector2(-size.x/1.1,0)
		end_point = Vector2(size.x/1.1,0)
	else:
		start_point = Vector2(0,-size.y/1.1)
		end_point = Vector2(0,size.y/1.1)
		
func _manage_lights():
	for k in get_parent().get_children():
		if k.get_name() in get_tree().get_current_scene().near_rooms:
			k._on()
		else:
			k._off()

func _on_box_body_enter( body ):
	if body.get_name() in ["gg","mech"] and not isIn:
		print(room)
		get_tree().get_current_scene().near_rooms.clear()
		isIn = true
		get_tree().get_current_scene().near_rooms.append(room)
		for j in connected_rooms:
			get_tree().get_current_scene().near_rooms.append(j)
		_manage_lights()
		if not explored:
			explored = true
			get_node("map_expl").show()
		for i in get_parent().get_children():
			if i.explored == false:
				for j in connected_rooms:
					if i.get_name() == j and i.get_name().find("tunnel") != -1:
						i.explored = true
						i.get_node("map_expl").show()
			

func _on():
	for i in get_children():
		if i.has_method("on") and not i.isOn:
			i.on()

func _off():
	for i in get_children():
		if i.has_method("off"):
			i.off()

func _on_box_body_exit( body ):
	if body.get_name() in ["gg","mech"]:
		isIn = false
		
