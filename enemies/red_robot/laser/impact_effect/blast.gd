extends Spatial

onready var light_rays = $LightRays
onready var camera = get_tree().get_root().get_camera()

func _ready():
	yield($AnimationPlayer, "animation_finished")
	queue_free()


func _process(_delta):
	if is_instance_valid(camera):
		light_rays.look_at(camera.global_transform.origin, Vector3.UP)
