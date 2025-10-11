extends CharacterBody3D


const BULLET_VELOCITY: float = 20.0

var time_alive: float = 5.0
var hit: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var omni_light: OmniLight3D = $OmniLight3D


func _ready() -> void:
	if not multiplayer.is_server():
		set_physics_process(false)
		collision_shape.disabled = true


func _physics_process(delta: float) -> void:
	if hit:
		return
	time_alive -= delta
	if time_alive < 0.0:
		hit = true
		explode.rpc()
	var displacement: Vector3 = -delta * BULLET_VELOCITY * transform.basis.z
	var col: KinematicCollision3D = move_and_collide(displacement)
	if col:
		var collider: Node3D = col.get_collider() as Node3D
		if collider and collider.has_method(&"hit"):
			collider.hit.rpc()
		collision_shape.disabled = true
		explode.rpc()
		hit = true


@rpc("call_local")
func explode() -> void:
	animation_player.play(&"explode")

	# Only enable shadows for the explosion, as the moving light
	# is very small and doesn't noticeably benefit from shadow mapping.
	if Settings.config_file.get_value("rendering", "shadow_mapping"):
		omni_light.shadow_enabled = true


func destroy() -> void:
	if not multiplayer.is_server():
		return
	queue_free()
