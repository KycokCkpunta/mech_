extends Light2D

func off():
	set_shadow_enabled(false)
	set_energy(0)
	set_enabled(false)

func on():
	set_enabled(true)
	set_shadow_enabled(true)
	get_node("AnimationPlayer").play("in")