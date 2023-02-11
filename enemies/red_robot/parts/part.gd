extends RigidBody3D

var puff_effect = preload("res://enemies/red_robot/parts/part_disappear_effect/part_disappear.tscn")

var _mat : Material = null

@export var lifetime: float = 3.0
@export var lifetime_random: float = 3.0
@export var disappearing_time: float = 0.5
@export var fade_value : float = 0.0 :
	set(value):
		fade_value = value
		if _mat:
			_mat.next_pass.set_shader_parameter("emission_cutout", fade_value)

var _disappearing_counter = 0.0

func _ready():
	set_process(false)
	if not OS.has_feature("dedicated_server"):
		var mesh := $Model.get_child(0) as MeshInstance3D
		_mat = mesh.mesh.surface_get_material(0).duplicate()
		mesh.mesh.surface_set_material(0, _mat)
		_mat.next_pass = _mat.next_pass.duplicate()


func explode():
	# Start synching.
	$MultiplayerSynchronizer.public_visibility = true
	freeze = false
	if not multiplayer.is_server():
		return
	get_node("Col1").disabled = false
	get_node("Col2").disabled = false
	linear_velocity = 3 * (Vector3.UP).normalized()
	angular_velocity = (Vector3(randf(), randf(), randf()).normalized() * 2 - Vector3.ONE) * 10
	await get_tree().create_timer(lifetime + lifetime_random * randf()).timeout
	set_process(true)


func _process(delta):
	fade_value = pow(_disappearing_counter / disappearing_time, 2.0)
	_disappearing_counter += delta
	if _disappearing_counter >= disappearing_time - 0.2:
		destroy.rpc()
		set_process(false)


@rpc("call_local")
func destroy():
	var puff = puff_effect.instantiate()
	get_parent().add_child(puff)
	puff.global_transform.origin = global_transform.origin
	await get_tree().create_timer(0.2).timeout
	queue_free()
