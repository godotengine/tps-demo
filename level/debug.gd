extends Label

func _process(_delta):
	if Input.is_action_just_pressed("toggle_debug"):
		visible = !visible

	text = "FPS: " + str(Engine.get_frames_per_second())
	text += "\nVSync: " + ("checked" if ProjectSettings.get_setting("display/window/vsync/vsync_mode") else "unchecked")
	text += "\nMemory: " + "%3.2f" % (OS.get_static_memory_usage() / 1048576.0) + " MiB"
	text += "\nOnline: " + ("false" if multiplayer.multiplayer_peer is OfflineMultiplayerPeer else "true")
	text += "\nMultiplayer ID: " + str(multiplayer.get_unique_id())
