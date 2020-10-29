extends Label

func _process(_delta):
	if Input.is_action_just_pressed("toggle_debug"):
		visible = !visible

	text = "FPS: " + str(Engine.get_frames_per_second())
	text += "\nVSync: " + ("on" if ProjectSettings.get_setting("display/window/vsync/use_vsync") else "off")
	text += "\nMemory: " + "%3.2f" % (OS.get_static_memory_usage() / 1048576.0) + " MiB"
