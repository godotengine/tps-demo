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

var state = State.APPROACH

var shoot_countdown = SHOOT_WAIT
var aim_countdown = AIM_TIME
var aim_preparing = AIM_PREPARE_TIME
var energy = 5
var dead = false
var test_shoot = false

var player = null
var velocity = Vector3()
var orientation = Transform()

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func _ready():
	orientation = global_transform
	orientation.origin = Vector3()


func resume_approach():
	state = State.APPROACH
	aim_preparing = AIM_PREPARE_TIME
	shoot_countdown = SHOOT_WAIT


func hit():
	if dead:
		return
	$AnimationTree["parameters/hit" + ["1", "2", "3"][randi() % 3] + "/active"] = true
	$sfx/hit.play()
	energy -= 1
	if energy == 0:
		dead = true
		var base_xf = global_transform.basis
		$AnimationTree.active = false
		#$death/explosion.play("kaboom")
		$"Scene Root".visible = false
		$death.visible = true
		$CollisionShape.disabled = true
		$death/particles.emitting = true
		
		$death/part_shield1/col1.disabled = false
		$death/part_shield1/col2.disabled = false
		$death/part_shield1.mode = RigidBody.MODE_RIGID
		$death/part_shield2/col1.disabled = false
		$death/part_shield2/col2.disabled = false
		$death/part_shield2.mode = RigidBody.MODE_RIGID
		$death/part_shield3/col1.disabled = false
		$death/part_shield3/col2.disabled = false
		$death/part_shield3.mode = RigidBody.MODE_RIGID
		
		$death/part_shield2.linear_velocity = 3 * (Vector3.UP + base_xf.x).normalized()
		$death/part_shield3.linear_velocity = 3 * (Vector3.UP).normalized()
		$death/part_shield1.linear_velocity = 3 * (Vector3.UP - base_xf.x).normalized()
		$death/part_shield2.angular_velocity = (Vector3(randf(), randf(), randf()).normalized() * 2 - Vector3.ONE) * 10
		$death/part_shield1.angular_velocity = (Vector3(randf(), randf(), randf()).normalized() * 2 - Vector3.ONE) * 10
		$death/part_shield3.angular_velocity = (Vector3(randf(), randf(), randf()).normalized() * 2 - Vector3.ONE) * 10
		$sfx/explosion.play()


func shoot():
	var gt = $"Scene Root/Armature/Skeleton/ray_from".global_transform
	var ray_from = gt.origin
	var ray_dir = -gt.basis.z
	var max_dist = 1000
	
	var col = get_world().direct_space_state.intersect_ray(ray_from, ray_from + ray_dir * max_dist, [self])
	if not col.empty():
		max_dist = ray_from.distance_to(col.position)
		if col.collider == player:
			pass # Kill.
	# Clip ray in shader.
	$"Scene Root/Armature/Skeleton/ray_from/ray".get_surface_material(0).set_shader_param("clip", max_dist)
	# Position explosion.
	$"Scene Root/Armature/Skeleton/ray_from/explosion".transform.origin.z = -max_dist


func _physics_process(delta):
	if (test_shoot):
		shoot()
		test_shoot = false
	
	if dead:
		return
	
	if not player:
		$AnimationTree["parameters/state/current"] = 0 # Go idle.
		return
	
	if (state == State.APPROACH):
		if (aim_preparing > 0):
			aim_preparing -= delta
			if (aim_preparing < 0):
				aim_preparing = 0
			$AnimationTree["parameters/aiming/blend_amount"] = aim_preparing / AIM_PREPARE_TIME
		
		var to_player_local = global_transform.xform_inv(player.global_transform.origin)
		# The front of the robot is +Z, and atan2 is zero at +X, so we need to use the Z for the X parameter (second one).
		var angle_to_player = atan2(to_player_local.x, to_player_local.z)
		var tolerance = deg2rad(PLAYER_AIM_TOLERANCE_DEGREES)
		if (angle_to_player > tolerance):
			$AnimationTree["parameters/state/current"] = 1
		elif (angle_to_player < -tolerance):
			$AnimationTree["parameters/state/current"] = 2
		else:
			$AnimationTree["parameters/state/current"] = 3
			# Facing player, try to shoot.
			shoot_countdown -= delta
			if (shoot_countdown < 0):
				# See if player can be killed because in they're sight.
				var ray_from = $"Scene Root/Armature/Skeleton/ray_from".global_transform.origin
				var ray_to = player.global_transform.origin + Vector3.UP # Above middle of player.
				var col = get_world().direct_space_state.intersect_ray(ray_from, ray_to, [self])
				if not col.empty() and col.collider == player:
					state = State.AIM
					aim_countdown = AIM_TIME
					aim_preparing = 0
					$AnimationTree["parameters/state/current"] = 0
				else:
					# Player not in sight, do nothing.
					shoot_countdown = SHOOT_WAIT
	
	elif state == State.AIM or state == State.SHOOTING:
			if (aim_preparing < AIM_PREPARE_TIME):
				aim_preparing += delta
				if (aim_preparing > AIM_PREPARE_TIME):
					aim_preparing = AIM_PREPARE_TIME
			
			$AnimationTree["parameters/aiming/blend_amount"] = clamp(aim_preparing / AIM_PREPARE_TIME, 0, 1)
			aim_countdown -= delta
			if aim_countdown < 0 and state == State.AIM:
				var ray_from = $"Scene Root/Armature/Skeleton/ray_from".global_transform.origin
				var ray_to = player.global_transform.origin + Vector3.UP # Above middle of player.
				var col = get_world().direct_space_state.intersect_ray(ray_from, ray_to, [self])
				if not col.empty() and col.collider == player:
					state = State.SHOOTING
					$shoot_anim.play("shoot")
				else:
					resume_approach()
			
			if $AnimationTree.active:
				var to_cannon_local = $"Scene Root/Armature/Skeleton/ray_from/ray".global_transform.xform_inv(player.global_transform.origin + Vector3.UP)
				var h_angle = rad2deg(atan2( to_cannon_local.x, -to_cannon_local.z ))
				var v_angle = rad2deg(atan2( to_cannon_local.y, -to_cannon_local.z ))
				var blend_pos = $AnimationTree["parameters/aim/blend_position"]
				var h_motion = BLEND_AIM_SPEED * delta * -h_angle
				blend_pos.x += h_motion
				blend_pos.x = clamp(blend_pos.x, -1, 1)
				
				var v_motion = BLEND_AIM_SPEED * delta * v_angle
				blend_pos.y += v_motion
				blend_pos.y = clamp(blend_pos.y, -1, 1)
					
				$AnimationTree["parameters/aim/blend_position"] = blend_pos
	
	# Apply root motion to orientation.
	orientation *= $AnimationTree.get_root_motion_transform()
	
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


func _on_area_body_entered(body):
	if body is preload("res://player/player.gd"):
		player = body
		shoot_countdown = SHOOT_WAIT


func _on_area_body_exited(body):
	if body is preload("res://player/player.gd"):
		player = null
