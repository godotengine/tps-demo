extends CharacterBody3D

const BULLET_VELOCITY = 20

var time_alive = 5
var hit = false

@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D

func _physics_process(delta):
	if hit:
		return
	time_alive -= delta
	if time_alive < 0:
		hit = true
		animation_player.play("explode")
	var col = move_and_collide(-delta * BULLET_VELOCITY * transform.basis.z)
	if col:
		var collider = col.get_collider()
		if collider and collider.has_method("hit"):
			collider.hit()
		collision_shape.disabled = true
		animation_player.play("explode")
		hit = true
