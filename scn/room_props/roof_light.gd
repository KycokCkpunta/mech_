extends Light2D

var isOn = false

func off():
	isOn = false
	set_energy(0)
	set_enabled(false)

func on():
	isOn = true
	set_enabled(true)
	get_node("AnimationPlayer").play("in")