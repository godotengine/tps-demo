extends Area

var open = false

func _on_door_body_entered(body):
	if not open and body is preload("res://player/player.gd"):
		$"Scene Root/AnimationPlayer".play("doorsimple_opening")
		open = true
