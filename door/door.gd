extends Area3D

@export var open = false
@export var is_locked = false

@onready var animation_player :AnimationPlayer= $DoorModel2/AnimationPlayer

@onready var left_collision = $"DoorModel2/armature-doorsimple/Skeleton3D/doorleft/CollisionShape3D"
@onready var right_collision =$"DoorModel2/armature-doorsimple/Skeleton3D/doorright/CollisionShape3D"
@onready var upper_collision =$"DoorModel2/armature-doorsimple/Skeleton3D/doorupper/CollisionShape3D"
@onready var lower_collision =$"DoorModel2/armature-doorsimple/Skeleton3D/doorlower/CollisionShape3D"
@onready var lock_indicator_mesh = $"DoorModel2/armature-doorsimple/Skeleton3D/doorsimple"

var override_material : StandardMaterial3D = StandardMaterial3D.new()

func _ready():
	lock_indicator_mesh.set_surface_override_material(1, override_material)
	if is_locked:
		override_material.albedo_color = Color(1,0,0)
	elif not is_locked:
		override_material.albedo_color = Color(0,1,0)

func _on_door_body_entered(body):
	if not open and body is Player and not is_locked:
		animation_player.play("doorsimple_opening")
		open = true

func _process(_delta):
	if float(animation_player.current_animation_position) < 1.9:
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
	if open and body is Player and not is_locked:
		animation_player.play_backwards("doorsimple_opening")
		open = false
