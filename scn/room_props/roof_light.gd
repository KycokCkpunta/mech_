extends Light2D

func off():
	set_shadow_enabled(false)
	get_node("AnimationPlayer").play("out")

func on():
	set_enabled(true)
	set_shadow_enabled(true)
	get_node("AnimationPlayer").play("in")

func off_lt():
	set_enabled(false)