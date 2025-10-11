extends Node3D


@onready var light_rays: CPUParticles3D = $LightRays
@onready var camera: Camera3D = get_tree().get_root().get_camera_3d()


func _ready() -> void:
	await $AnimationPlayer.animation_finished
	queue_free()


func _process(_delta: float) -> void:
	if is_instance_valid(camera):
		light_rays.look_at(camera.global_transform.origin)
