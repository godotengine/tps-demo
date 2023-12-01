extends Node3D

@onready var spot_light = $SpotLight3D

func _ready():
	if not Settings.config_file.get_value("rendering", "shadow_mapping"):
		spot_light.shadow_enabled = false

	# Randomize the forklift model.
	# We have 3 models, may as well use them.
	randomize()
	var children = get_child(0).get_children()
	var child_count = children.size()
	var which_enabled = floor(randf() * child_count)
	for i in range(child_count):
		children[i].visible = i == which_enabled


# TODO: We can maybe implement func hit():
