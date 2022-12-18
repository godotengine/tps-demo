extends Node

func _ready():
	OS.window_fullscreen = Settings.fullscreen
	go_to_main_menu()

	var max_refresh_rate = 60.0
	for screen in OS.get_screen_count():
		 max_refresh_rate = max(max_refresh_rate, OS.get_screen_refresh_rate(screen))

	# Cap framerate to (roughly) the refresh rate of the monitor with the highest refresh rate.
	# This allows for smooth operation while reducing power usage when V-Sync is disabled.
	Engine.target_fps = max_refresh_rate + 1.0
	print("Limiting FPS to %d." % Engine.target_fps)


func go_to_main_menu():
	var menu = ResourceLoader.load("res://menu/menu.tscn")
	change_scene(menu)


func replace_main_scene(resource):
	call_deferred("change_scene", resource)


func change_scene(resource : Resource):
	var node = resource.instance()

	for child in get_children():
		remove_child(child)
		child.queue_free()
	add_child(node)

	node.connect("quit", self, "go_to_main_menu")
	node.connect("replace_main_scene", self, "replace_main_scene")
