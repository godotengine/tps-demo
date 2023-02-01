extends CPUParticles3D


func _ready():
	$MiniBlasts.emitting = true
	await get_tree().create_timer(0.2).timeout
	emitting = true
	await get_tree().create_timer(lifetime * 2.0).timeout
	queue_free()
