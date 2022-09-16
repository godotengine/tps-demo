extends KinematicBody

enum State {
	APPROACH = 0,
	AIM = 1,
	SHOOTING = 2,
}

const PLAYER_AIM_TOLERANCE_DEGREES = 15

const SHOOT_WAIT = 6.0
const AIM_TIME = 1

const AIM_PREPARE_TIME = 0.5
const BLEND_AIM_SPEED = 0.05

export(int) var health = 5
export(bool) var test_shoot = false

var state = State.APPROACH

var shoot_countdown = SHOOT_WAIT
var aim_countdown = AIM_TIME
var aim_preparing = AIM_PREPARE_TIME
var dead = false

var player = null
var velocity = Vector3()
var orientation = Transform()

var blast_scene = preload("res://enemies/red_robot/laser/impact_effect/impact_effect.tscn")

onready var animation_tree = $AnimationTree
onready var shoot_animation = $ShootAnimation

onready var model = $RedRobotModel
onready var ray_from = model.get_node(@"Armature/Skeleton/RayFrom")
onready var ray_mesh = ray_from.get_node(@"RayMesh")
onready var laser_raycast = ray_from.get_node(@"RayCast")
onready var collision_shape = $CollisionShape

onready var explosion_sound = $SoundEffects/Explosion
onready var hit_sound = $SoundEffects/Hit

onready var death = $Death
onready var death_shield1 = death.get_node(@"PartShield1")
onready var death_shield2 = death.get_node(@"PartShield2")
onready var death_head = death.get_node(@"PartHead")
onready var death_detach_spark1 = death.get_node(@"DetachSpark1")
onready var death_detach_spark2 = death.get_node(@"DetachSpark2")

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func _ready():
	orientation = global_transform
	orientation.origin = Vector3()
	$AnimationTree.active = true
	if test_shoot:
		shoot_countdown = 0.0


func resume_approach():
	state = State.APPROACH
	aim_preparing = AIM_PREPARE_TIME
	shoot_countdown = SHOOT_WAIT


func hit():
	if dead:
		return
	animation_tree["parameters/hit" + str(randi() % 3 + 1) + "/active"] = true
	hit_sound.play()
	health -= 1
	if health == 0:
		dead = true
		var base_xf = global_transform.basis
		animation_tree.active = false
		model.visible = false
		death.visible = true
		collision_shape.disabled = true

		death_shield1.get_node(@"Col1").disabled = false
		death_shield1.get_node(@"Col2").disabled = false
		death_shield1.mode = RigidBody.MODE_RIGID
		death_shield2.get_node(@"Col1").disabled = false
		death_shield2.get_node(@"Col2").disabled = false
		death_shield2.mode = RigidBody.MODE_RIGID
		death_head.get_node(@"Col1").disabled = false
		death_head.get_node(@"Col2").disabled = false
		death_head.mode = RigidBody.MODE_RIGID

		death_detach_spark1.emitting = true
		death_detach_spark2.emitting = true

		death_shield1.linear_velocity = 3 * (Vector3.UP - base_xf.x).normalized()
		death_shield2.linear_velocity = 3 * (Vector3.UP + base_xf.x).normalized()
		death_head.linear_velocity = 3 * (Vector3.UP).normalized()
		death_shield1.angular_velocity = (Vector3(randf(), randf(), randf()).normalized() * 2 - Vector3.ONE) * 10
		death_shield2.angular_velocity = (Vector3(randf(), randf(), randf()).normalized() * 2 - Vector3.ONE) * 10
		death_head.angular_velocity = (Vector3(randf(), randf(), randf()).normalized() * 2 - Vector3.ONE) * 10

		death_shield1.start_disappear_countdown()
		death_shield2.start_disappear_countdown()
		death_head.start_disappear_countdown()

		explosion_sound.play()


func shoot():
	var gt = ray_from.global_transform
	var ray_origin = ray_from.global_transform.origin
	var ray_dir = -gt.basis.z
	var max_dist = 1000

	var col = get_world().direct_space_state.intersect_ray(ray_origin, ray_origin + ray_dir * max_dist, [self])
	if not col.empty():
		max_dist = ray_origin.distance_to(col.position)
		if col.collider == player:
			pass # Kill.
	# Clip ray in shader.
	_clip_ray(max_dist)
	# Position laser ember particles
	var mesh_offset = ray_mesh.translation.z
	var laser_ember = $RedRobotModel/Armature/Skeleton/RayFrom/LaserEmber
	laser_ember.translation = Vector3(0.0, 0.0, -max_dist / 2.0 - mesh_offset)
	laser_ember.emission_box_extents.z = (max_dist - abs(mesh_offset)) / 2.0
	if not col.empty():
		var blast = blast_scene.instance()
		get_tree().get_root().add_child(blast)
		blast.global_transform.origin = col.position
		if col.collider == player and player is Player:
			yield(get_tree().create_timer(0.1), "timeout")
			player.add_camera_shake_trauma(13)


func _physics_process(delta):
	if test_shoot:
		shoot()
		test_shoot = false

	if dead:
		return

	if not player:
		animation_tree["parameters/state/current"] = 0 # Go idle.
		velocity = move_and_slide(gravity * delta, Vector3.UP)
		return

	if state == State.APPROACH:
		if aim_preparing > 0:
			aim_preparing -= delta
			if aim_preparing < 0:
				aim_preparing = 0
			animation_tree["parameters/aiming/blend_amount"] = aim_preparing / AIM_PREPARE_TIME

		var to_player_local = global_transform.xform_inv(player.global_transform.origin)
		# The front of the robot is +Z, and atan2 is zero at +X, so we need to use the Z for the X parameter (second one).
		var angle_to_player = atan2(to_player_local.x, to_player_local.z)
		var tolerance = deg2rad(PLAYER_AIM_TOLERANCE_DEGREES)
		if angle_to_player > tolerance:
			animation_tree["parameters/state/current"] = 1
		elif angle_to_player < -tolerance:
			animation_tree["parameters/state/current"] = 2
		else:
			animation_tree["parameters/state/current"] = 3
			# Facing player, try to shoot.
			shoot_countdown -= delta
			if shoot_countdown < 0:
				# See if player can be killed because in they're sight.
				var ray_origin = ray_from.global_transform.origin
				var ray_to = player.global_transform.origin + Vector3.UP # Above middle of player.
				var col = get_world().direct_space_state.intersect_ray(ray_origin, ray_to, [self])
				if not col.empty() and col.collider == player:
					state = State.AIM
					aim_countdown = AIM_TIME
					aim_preparing = 0
					animation_tree["parameters/state/current"] = 0
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

		animation_tree["parameters/aiming/blend_amount"] = clamp(aim_preparing / AIM_PREPARE_TIME, 0, 1)
		aim_countdown -= delta
		if aim_countdown < 0 and state == State.AIM:
			var ray_origin = ray_from.global_transform.origin
			var ray_to = player.global_transform.origin + Vector3.UP # Above middle of player.
			var col = get_world().direct_space_state.intersect_ray(ray_origin, ray_to, [self])
			if not col.empty() and col.collider == player:
				state = State.SHOOTING
				shoot_animation.play("shoot")
				shoot_countdown = SHOOT_WAIT
			else:
				resume_approach()

		if animation_tree.active:
			var to_cannon_local = ray_mesh.global_transform.xform_inv(player.global_transform.origin + Vector3.UP)
			var h_angle = rad2deg(atan2( to_cannon_local.x, -to_cannon_local.z ))
			var v_angle = rad2deg(atan2( to_cannon_local.y, -to_cannon_local.z ))
			var blend_pos = animation_tree.get("parameters/aim/blend_position")
			var h_motion = BLEND_AIM_SPEED * delta * -h_angle
			blend_pos.x += h_motion
			blend_pos.x = clamp(blend_pos.x, -1, 1)

			var v_motion = BLEND_AIM_SPEED * delta * v_angle
			blend_pos.y += v_motion
			blend_pos.y = clamp(blend_pos.y, -1, 1)

			animation_tree["parameters/aim/blend_position"] = blend_pos

	# Apply root motion to orientation.
	orientation *= animation_tree.get_root_motion_transform()

	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	velocity += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)

	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # orthonormalize orientation.

	global_transform.basis = orientation.basis


func shoot_check():
	test_shoot = true


func _clip_ray(length):
	var mesh_offset = ray_mesh.translation.z
	ray_mesh.get_surface_material(0).set_shader_param("clip", length + mesh_offset)


func _on_area_body_entered(body):
	if body is Player or body.name == "Target":
		player = body


func _on_area_body_exited(body):
	if body is Player:
		player = null
