extends Spatial


func _ready():
	# Randomize the forklift model.
	# We have 3 models, may as well use them.
	randomize()
	var children = get_child(0).get_children()
	var child_count = children.size()
	var which_enabled = floor(randf() * child_count)
	for i in range(child_count):
		children[i].visible = i == which_enabled

	# Make sure shows up when portals are on.
	Portals.change_portal_mode_recursive(self, CullInstance.PORTAL_MODE_ROAMING)


# TODO: We can maybe implement func hit():
