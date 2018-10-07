extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var open = false
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here.
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_door_body_entered(body):
	if (not open and body is preload("res://player/player.gd")):
		$"Scene Root/AnimationPlayer".play("doorsimple_opening")
		open = true
