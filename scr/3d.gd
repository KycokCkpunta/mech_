extends Viewport

onready var walls = get_node("../walls")

func _ready():
	for cell in walls.get_used_cells():
		var cube = TestCube.new()
		cube.set_scale(Vector3(0.5,6,0.5))
		cube.set_translation(Vector3(cell.x,6,cell.y))
		cube.set_name("cell_"+str(cell))
		add_child(cube)
	set_fixed_process(true)

func _fixed_process(delta):
	var pos2d = get_node("../gg").get_pos()/16
	get_node("Camera").set_translation(Vector3(pos2d.x-0.5,12,pos2d.y-0.5))