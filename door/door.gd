extends Area3D


@export var open: bool = false
@export var is_locked: bool = false

@onready var animation_player: AnimationPlayer= $DoorModel2/AnimationPlayer

@onready var _door_skeleton: Skeleton3D = $"DoorModel2/armature-doorsimple/Skeleton3D"
@onready var left_collision: CollisionShape3D = _door_skeleton.get_node(^"doorleft/CollisionShape3D")
@onready var right_collision: CollisionShape3D = _door_skeleton.get_node(^"doorright/CollisionShape3D")
@onready var upper_collision: CollisionShape3D = _door_skeleton.get_node(^"doorupper/CollisionShape3D")
@onready var lower_collision: CollisionShape3D = _door_skeleton.get_node(^"doorlower/CollisionShape3D")
@onready var lock_indicator_mesh: MeshInstance3D = _door_skeleton.get_node(^"doorsimple")

var override_material := StandardMaterial3D.new()


func _ready():
	lock_indicator_mesh.set_surface_override_material(1, override_material)
	if is_locked:
		override_material.albedo_color = Color.RED
	elif not is_locked:
		override_material.albedo_color = Color.GREEN


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


func _on_door_body_entered(body):
	if not open and body is Player and not is_locked:
		animation_player.play("doorsimple_opening")
		open = true


func _on_body_exited(body):
	if open and body is Player and not is_locked:
		animation_player.play_backwards("doorsimple_opening")
		open = false
