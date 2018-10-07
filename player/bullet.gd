extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var time_alive=5
var direction = Vector3()

const BULLET_VELOCITY = 20
var hit=false

func _process(delta):
	if (hit):
		return
		
	time_alive-=delta
	if (time_alive<0):
		hit=true
		$anim.play("explode")
	var col = move_and_collide(delta * direction * BULLET_VELOCITY)
	if (col):
		if (col.collider and col.collider.has_method("hit")):
			col.collider.hit()
		$CollisionShape.disabled=true
		$anim.play("explode")
		hit=true
	


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here.
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_bullet_body_entered():
	print("got into body")
