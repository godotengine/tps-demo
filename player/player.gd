extends KinematicBody

const CAMERA_MOUSE_ROTATION_SPEED = 0.001
const CAMERA_CONTROLLER_ROTATION_SPEED = 1.0
const CAMERA_X_ROT_MIN = -40
const CAMERA_X_ROT_MAX = 30

const DIRECTION_INTERPOLATE_SPEED = 1
const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10

const MIN_AIRBORNE_TIME = 0.1
const JUMP_SPEED = 5

var airborne_time = 100

var orientation = Transform()
var root_motion = Transform()
var motion = Vector2()
var velocity = Vector3()

var aiming = false
var camera_x_rot = 0.0

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _ready():
	# Pre-initialize orientation transform.
	orientation = $"Scene Root".global_transform
	orientation.origin = Vector3()

func rotate_camera(move):
	$camera_base.rotate_y(-move.x)
	$camera_base.orthonormalize() # After relative transforms, camera needs to be renormalized.
	camera_x_rot += move.y
	camera_x_rot = clamp(camera_x_rot, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	$camera_base/camera_rot.rotation.x = camera_x_rot

func _physics_process(delta):
	var camera_move = Vector2(Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
								Input.get_action_strength("view_up") - Input.get_action_strength("view_down"))
	rotate_camera(camera_move * delta * CAMERA_CONTROLLER_ROTATION_SPEED)
	var motion_target = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 
								Input.get_action_strength("move_forward") - Input.get_action_strength("move_back"))
	motion = motion.linear_interpolate(motion_target, MOTION_INTERPOLATE_SPEED * delta)
	
	var camera_basis = $camera_base/camera_rot/Camera.global_transform.basis
	var camera_z = camera_basis.z
	var camera_x = camera_basis.x
	
	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	var current_aim = Input.is_action_pressed("aim")
	
	if aiming != current_aim:
			aiming = current_aim
			if (aiming):
				$camera_base/animation.play("shoot")
			else:
				$camera_base/animation.play("far")
	
	# Jump/in-air logic.
	airborne_time += delta
	if is_on_floor():
		if airborne_time > 0.5:
			$sfx/land.play()
		airborne_time = 0
	
	var on_air = airborne_time > MIN_AIRBORNE_TIME
	
	if not on_air and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED
		on_air = true
		$animation_tree["parameters/state/current"] = 2
		$sfx/jump.play()
	
	if on_air:
		if (velocity.y > 0):
			$animation_tree["parameters/state/current"] = 2
		else:
			$animation_tree["parameters/state/current"] = 3
	elif aiming:
		# Change state to strafe.
		$animation_tree["parameters/state/current"] = 0
		
		# Change aim according to camera rotation.
		if camera_x_rot >= 0: # Aim up.
			$animation_tree["parameters/aim/add_amount"] = -camera_x_rot / deg2rad(CAMERA_X_ROT_MAX)
		else: # Aim down.
			$animation_tree["parameters/aim/add_amount"] = camera_x_rot / deg2rad(CAMERA_X_ROT_MIN)
		
		# Convert orientation to quaternions for interpolating rotation.
		var q_from = orientation.basis.get_rotation_quat()
		var q_to = $camera_base.global_transform.basis.get_rotation_quat()
		# Interpolate current rotation with desired one.
		orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
		
		
		$animation_tree["parameters/strafe/blend_position"] = motion
		
		root_motion = $animation_tree.get_root_motion_transform()
		
		if Input.is_action_pressed("shoot") and $FireCooldown.time_left == 0:
			var shoot_from = $"Scene Root/Robot_Skeleton/Skeleton/gun_bone/shoot_from".global_transform.origin
			var cam = $camera_base/camera_rot/Camera
			
			var ch_pos = $crosshair.rect_position + $crosshair.rect_size * 0.5
			var ray_from = cam.project_ray_origin(ch_pos)
			var ray_dir = cam.project_ray_normal(ch_pos)
			
			var shoot_target
			var col = get_world().direct_space_state.intersect_ray(ray_from, ray_from + ray_dir * 1000, [self])
			if col.empty():
				shoot_target = ray_from + ray_dir * 1000
			else:
				shoot_target = col.position
			var shoot_dir = (shoot_target - shoot_from).normalized()
			
			var bullet = preload("res://player/bullet.tscn").instance()
			get_parent().add_child(bullet)
			bullet.global_transform.origin = shoot_from
			bullet.direction = shoot_dir
			bullet.add_collision_exception_with(self)
			$FireCooldown.start()
			$sfx/shoot.play()
	else: # Not in air or aiming, idle.
		# Convert orientation to quaternions for interpolating rotation.
		var target = camera_z * motion.y - camera_x * motion.x
		if target.length() > 0.001:
			var q_from = orientation.basis.get_rotation_quat()
			var q_to = Quat(Transform().looking_at(target, Vector3.UP).basis)
			# Interpolate current rotation with desired one
			orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
		
		# Aim to zero (no aiming while walking).
		$animation_tree["parameters/aim/add_amount"] = 0
		# Change state to walk.
		$animation_tree["parameters/state/current"] = 1
		# Blend position for walk speed based on motion.
		$animation_tree["parameters/walk/blend_position"] = Vector2(motion.length(), 0) 
		
		root_motion = $animation_tree.get_root_motion_transform()
	
	# Apply root motion to orientation.
	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	velocity += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.
	
	$"Scene Root".global_transform.basis = orientation.basis


func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative * CAMERA_MOUSE_ROTATION_SPEED)
