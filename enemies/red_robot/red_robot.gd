extends CharacterBody3D

enum State {
	APPROACH = 0,
	AIM = 1,
	SHOOTING = 2,
}

const PLAYER_AIM_TOLERANCE_DEGREES = deg_to_rad(15)

const SHOOT_WAIT = 6.0
const AIM_TIME = 1

const AIM_PREPARE_TIME = 0.5
const BLEND_AIM_SPEED = 0.05

signal exploded()

@export var test_shoot: bool = false

@export var target_position := Vector3()
@export var health: int = 5
@export var state : State = State.APPROACH
@export var dead = false
@export var aim_preparing = AIM_PREPARE_TIME

var shoot_countdown = SHOOT_WAIT
var aim_countdown = AIM_TIME

var player = null
var orientation = Transform3D()

var blast_scene = preload("res://enemies/red_robot/laser/impact_effect/impact_effect.tscn")

@onready var animation_tree = $AnimationTree
@onready var shoot_animation = $ShootAnimation

@onready var model = $RedRobotModel
@onready var ray_from = model.get_node("Armature/Skeleton3D/RayFrom")
@onready var ray_mesh = ray_from.get_node("RayMesh")
@onready var laser_raycast = ray_from.get_node("RayCast")
@onready var collision_shape = $CollisionShape3D

@onready var explosion_sound = $SoundEffects/Explosion
@onready var hit_sound = $SoundEffects/Hit

@onready var death = $Death
@onready var death_shield1 = death.get_node("PartShield1")
@onready var death_shield2 = death.get_node("PartShield2")
@onready var death_head = death.get_node("PartHead")
@onready var death_detach_spark1 = death.get_node("DetachSpark1")
@onready var death_detach_spark2 = death.get_node("DetachSpark2")

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func _ready():
	orientation = global_transform
	orientation.origin = Vector3()
	$AnimationTree.active = true
	if test_shoot:
		shoot_countdown = 0.0

	if dead:
		model.visible = false
		collision_shape.disabled = true
		animation_tree.active = false

	animate()

func resume_approach():
	state = State.APPROACH
	aim_preparing = AIM_PREPARE_TIME
	shoot_countdown = SHOOT_WAIT


@rpc("call_local")
func hit():
	if dead:
		return
	var param = "parameters/hit" + str(randi() % 3 + 1) + "/request"
	animation_tree[param] = 1
	hit_sound.play()
	health -= 1
	if health == 0:
		dead = true
		animation_tree.active = false
		model.visible = false
		death.visible = true
		collision_shape.disabled = true

		death_detach_spark1.emitting = true
		death_detach_spark2.emitting = true

		death_shield1.explode()
		death_shield2.explode()
		death_head.explode()

		explosion_sound.play()
		exploded.emit()

		if multiplayer.is_server():
			await get_tree().create_timer(10.0).timeout
			queue_free()


func shoot():
	var gt = ray_from.global_transform
	var ray_origin = ray_from.global_transform.origin
	var ray_dir = -gt.basis.z
	var max_dist = 1000

	var col = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * max_dist, 0xFFFFFFFF, [self] ))
	if not col.is_empty():
		max_dist = ray_origin.distance_to(col.position)
		if col.collider == player:
			pass # Kill.
	# Clip ray in shader.
	_clip_ray(max_dist)
	# Position laser ember particles
	var mesh_offset = ray_mesh.position.z
	var laser_ember = $RedRobotModel/Armature/Skeleton3D/RayFrom/LaserEmber
	laser_ember.position = Vector3(0.0, 0.0, -max_dist / 2.0 - mesh_offset)
	laser_ember.emission_box_extents.z = (max_dist - abs(mesh_offset)) / 2.0
	if not col.is_empty():
		var blast = blast_scene.instantiate()
		get_tree().get_root().add_child(blast)
		blast.global_transform.origin = col.position
		if col.collider == player and player is Player:
			await get_tree().create_timer(0.1).timeout
			player.add_camera_shake_trauma(13)


func animate(delta:=0.0):
	if state == State.APPROACH:
		var to_player_local = target_position * global_transform
		# The front of the robot is +Z, and atan2 is zero at +X, so we need to use the Z for the X parameter (second one).
		var angle_to_player = atan2(to_player_local.x, to_player_local.z)
		if angle_to_player > PLAYER_AIM_TOLERANCE_DEGREES:
			animation_tree["parameters/state/transition_request"] = "turn_left"
		elif angle_to_player < -PLAYER_AIM_TOLERANCE_DEGREES:
			animation_tree["parameters/state/transition_request"] = "turn_right"
		elif target_position == Vector3.ZERO:
			animation_tree["parameters/state/transition_request"] = "idle"
		else:
			animation_tree["parameters/state/transition_request"] = "walk"
	else:
		animation_tree["parameters/state/transition_request"] = "idle"

	# Aiming or shooting
	if target_position != Vector3.ZERO:
		animation_tree["parameters/aiming/blend_amount"] = clamp(aim_preparing / AIM_PREPARE_TIME, 0, 1)

		var to_cannon_local = (target_position + Vector3.UP) * ray_mesh.global_transform
		var h_angle = rad_to_deg(atan2( to_cannon_local.x, -to_cannon_local.z ))
		var v_angle = rad_to_deg(atan2( to_cannon_local.y, -to_cannon_local.z ))
		var blend_pos = animation_tree.get("parameters/aim/blend_position")
		var h_motion = BLEND_AIM_SPEED * delta * -h_angle
		blend_pos.x += h_motion
		blend_pos.x = clamp(blend_pos.x, -1, 1)

		var v_motion = BLEND_AIM_SPEED * delta * v_angle
		blend_pos.y += v_motion
		blend_pos.y = clamp(blend_pos.y, -1, 1)

		animation_tree["parameters/aim/blend_position"] = blend_pos


func _physics_process(delta):
	if dead:
		return

	if not multiplayer.is_server():
		animate(delta)
		return

	if test_shoot:
		shoot()
		test_shoot = false

	if not player:
		target_position = Vector3()
		animate(delta)
		set_velocity(gravity * delta)
		set_up_direction(Vector3.UP)
		move_and_slide()
		return

	target_position = player.global_transform.origin

	if state == State.APPROACH:
		if aim_preparing > 0:
			aim_preparing -= delta
			if aim_preparing < 0:
				aim_preparing = 0

		var to_player_local = target_position * global_transform
		# The front of the robot is +Z, and atan2 is zero at +X, so we need to use the Z for the X parameter (second one).
		var angle_to_player = atan2(to_player_local.x, to_player_local.z)
		if angle_to_player > -PLAYER_AIM_TOLERANCE_DEGREES and angle_to_player < PLAYER_AIM_TOLERANCE_DEGREES:
			# Facing player, try to shoot.
			shoot_countdown -= delta
			if shoot_countdown < 0:
				# See if player can be killed because in they're sight.
				var ray_origin = ray_from.global_transform.origin
				var ray_to = player.global_transform.origin + Vector3.UP # Above middle of player.
				var col = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_to, 0xFFFFFFFF, [self]))

				if not col.is_empty() and col.collider == player:
					state = State.AIM
					aim_countdown = AIM_TIME
					aim_preparing = 0
				else:
					# Player not in sight, do nothing.
					shoot_countdown = SHOOT_WAIT

	elif state == State.AIM or state == State.SHOOTING:
		var max_dist = 1000
		if laser_raycast.is_colliding():
			max_dist = (ray_from.global_transform.origin - laser_raycast.get_collision_point()).length()
		_clip_ray(max_dist)
		if aim_preparing < AIM_PREPARE_TIME:
			aim_preparing += delta
			if aim_preparing > AIM_PREPARE_TIME:
				aim_preparing = AIM_PREPARE_TIME

		aim_countdown -= delta
		if aim_countdown < 0 and state == State.AIM:
			var ray_origin = ray_from.global_transform.origin
			var ray_to = target_position + Vector3.UP
			var col = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_to, 0xFFFFFFFF, [self]))
			if not col.is_empty() and col.collider == player:
				state = State.SHOOTING
				shoot_countdown = SHOOT_WAIT
				play_shoot.rpc()
			else:
				resume_approach()

	animate(delta)
	# Apply root motion to orientation.
	orientation *= Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())

	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	velocity += gravity * delta
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()

	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # orthonormalize orientation.

	global_transform.basis = orientation.basis


@rpc("call_local")
func play_shoot():
	shoot_animation.play("shoot")


func shoot_check():
	test_shoot = true


func _clip_ray(length):
	var mesh_offset = ray_mesh.position.z
	if not OS.has_feature("dedicated_server"):
		ray_mesh.get_surface_override_material(0).set_shader_parameter("clip", length + mesh_offset)


func _on_area_body_entered(body):
	if body is Player or body.name == "Target":
		player = body


func _on_area_body_exited(body):
	if body is Player:
		player = null
