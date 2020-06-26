extends Node

func _ready():
	OS.window_fullscreen = Settings.fullscreen
	
	# Manage french and belgian keyboard layouts
	match OS.keyboard_get_layout_language(OS.keyboard_get_current_layout()):
		"fr","be":
			var ev_fr_forward = InputEventKey.new()
			ev_fr_forward.scancode = KEY_Z
			InputMap.action_add_event("move_forward", ev_fr_forward)
			
			var ev_fr_left = InputEventKey.new()
			ev_fr_left.scancode = KEY_Q
			InputMap.action_add_event("move_left", ev_fr_left)
			
	go_to_main_menu()


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
