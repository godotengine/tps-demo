extends KinematicBody

const BULLET_VELOCITY = 20

var time_alive = 5
var direction = Vector3()
var hit = false

func _process(delta):
	if hit:
		return
	
	time_alive -= delta
	if time_alive < 0:
		hit = true
		$AnimationPlayer.play("explode")
	var col = move_and_collide(delta * direction * BULLET_VELOCITY)
	if col:
		if col.collider and col.collider.has_method("hit"):
			col.collider.hit()
		$CollisionShape.disabled = true
		$AnimationPlayer.play("explode")
		hit = true


func _on_bullet_body_entered():
	print("got into body")
