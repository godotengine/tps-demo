extends RigidBody

var puff_effect = preload("res://enemies/red_robot/parts/part_disappear_effect/part_disappear.tscn")

export(float) var lifetime = 3.0
export(float) var lifetime_random = 3.0
export(float) var disappearing_time = 0.5

var _lifetime
var _disappearing_counter = 0.0
var _is_disappearing = false
var _mat

onready var _mesh = $Model.get_child(0)


func _ready():
	_mat = _mesh.mesh.surface_get_material(0).duplicate()
	_mesh.mesh.surface_set_material(0, _mat)
	_mat.next_pass = _mat.next_pass.duplicate()
	randomize()
	_lifetime = lifetime + lifetime_random * randf()


func start_disappear_countdown():
	yield(get_tree().create_timer(_lifetime), "timeout")
	_is_disappearing = true


func _process(delta):
	if not _is_disappearing:
		return
	var curve_val = pow(_disappearing_counter / disappearing_time, 2.0)
	_mat.next_pass.set_shader_param("emission_cutout", curve_val)
	_disappearing_counter += delta
	if _disappearing_counter >= disappearing_time - 0.2:
		var puff = puff_effect.instance()
		get_parent().add_child(puff)
		puff.global_transform.origin = global_transform.origin
		_is_disappearing = false
		yield(get_tree().create_timer(0.2), "timeout")
		queue_free()
