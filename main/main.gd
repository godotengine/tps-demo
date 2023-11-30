extends Node

func _ready():
	multiplayer.server_relay = false
	if DisplayServer.get_name() == "headless":
		Engine.max_fps = 60
	randomize()
	get_window().mode = Settings.config_file.get_value("video", "display_mode")
	go_to_main_menu()


func go_to_main_menu():
	var menu = ResourceLoader.load("res://menu/menu.tscn")
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	change_scene_to_file(menu)


func replace_main_scene(resource):
	call_deferred("change_scene_to_file", resource)


func change_scene_to_file(resource : Resource):
	var node = resource.instantiate()

	for child in get_children():
		remove_child(child)
		child.queue_free()
	add_child(node)

	node.connect("quit",Callable(self,"go_to_main_menu"))
	node.connect("replace_main_scene",Callable(self,"replace_main_scene"))
