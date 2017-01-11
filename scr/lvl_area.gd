extends Area2D

var size = Vector2()
var room = ""

var isIn = false

func _ready():
	var shape = RectangleShape2D.new()
	shape.set_name(room+"_col")
	shape.set_extents(size)
	add_shape(shape)
	get_node("col").set_shape(shape)
	set_name(room)

func _on_box_body_enter( body ):
	if body.get_name() in ["gg","mech"] and not isIn:
		print(room)
		isIn = true

func _on_box_body_exit( body ):
	if body.get_name() in ["gg","mech"]:
		isIn = false
