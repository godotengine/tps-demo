extends Area3D

@export var open = false

@onready var animation_player :AnimationPlayer= $DoorModel2/AnimationPlayer

@onready var left_collision = $"DoorModel2/armature-doorsimple/Skeleton3D/doorleft/CollisionShape3D"
@onready var right_collision =$"DoorModel2/armature-doorsimple/Skeleton3D/doorright/CollisionShape3D"
@onready var upper_collision =$"DoorModel2/armature-doorsimple/Skeleton3D/doorupper/CollisionShape3D"
@onready var lower_collision =$"DoorModel2/armature-doorsimple/Skeleton3D/doorlower/CollisionShape3D"


func _on_door_body_entered(body):
	if not open and body is Player:
		animation_player.play("doorsimple_opening")
		open = true

func _process(delta):
	if float(animation_player.current_animation_position) < 1.9:
		print_debug("door closed")
		left_collision.disabled = false
		right_collision.disabled = false
		upper_collision.disabled = false
		lower_collision.disabled = false
	else:
		left_collision.disabled = true
		right_collision.disabled = true
		upper_collision.disabled = true
		lower_collision.disabled = true

func _on_body_exited(body):
	if open and body is Player:
		animation_player.play_backwards("doorsimple_opening")
		open = false
