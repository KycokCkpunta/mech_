extends Node2D

var mouse_pos = Vector2(0,0)

func _ready():
	set_process(true)

func _process(delta):
	mouse_pos = get_local_mouse_pos()
	pass
