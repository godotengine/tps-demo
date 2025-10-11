extends Area3D


var open: bool = false

@onready var animation_player: AnimationPlayer = $DoorModel/AnimationPlayer


func _on_door_body_entered(body: Node3D) -> void:
	if not open and body is Player:
		animation_player.play(&"doorsimple_opening")
		open = true
