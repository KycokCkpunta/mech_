extends Camera2D

func _ready():
	set_process(true)
	pass

func _process(delta):
	set_pos(get_local_mouse_pos()+get_pos())