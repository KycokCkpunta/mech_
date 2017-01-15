extends CanvasLayer

onready var lbl_dbg = get_node("dbg")

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	lbl_dbg.set_text("FPS: "+str(OS.get_frames_per_second()))
