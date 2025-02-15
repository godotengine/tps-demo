extends Label

@export var debug_container : Container

func _process(_delta):
	if Input.is_action_just_pressed("toggle_debug"):
		debug_container.visible = not debug_container.visible

	text = "FPS: " + str(Engine.get_frames_per_second())
	text += "\nVSync: " + ("Enabled" if DisplayServer.window_get_vsync_mode() else "Disabled")
	text += "\nMemory: " + "%3.2f" % (OS.get_static_memory_usage() / 1048576.0) + " MiB"

	var online := not multiplayer.multiplayer_peer is OfflineMultiplayerPeer
	text += "\nOnline: " + ("Yes" if online else "No")
	if online:
		text += "\nMultiplayer ID: " + str(multiplayer.get_unique_id())
