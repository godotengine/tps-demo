extends Node

func change_portal_mode_recursive(node : Node, portal_mode):
	if node is MeshInstance:
		node.portal_mode = portal_mode
	if node is CPUParticles:
		node.portal_mode = portal_mode
	if node is Particles:
		node.portal_mode = portal_mode
	if node is Light:
		node.portal_mode = portal_mode
		
	for i in range (0, node.get_child_count()):
		change_portal_mode_recursive(node.get_child(i), portal_mode)
