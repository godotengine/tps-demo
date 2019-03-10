extends KinematicBody


var aiming = false
const CAMERA_ROTATION_SPEED = 0.001
const GRAVITY = Vector3(0,-9.8, 0)
const DIRECTION_INTERPOLATE_SPEED = 1

const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10
var motion = Vector2()

const CAMERA_X_ROT_MIN = -40
const CAMERA_X_ROT_MAX = 30

var camera_x_rot = 0.0

var velocity = Vector3()

var orientation = Transform()

var airborne_time = 100
const MIN_AIRBORNE_TIME = 0.1

const JUMP_SPEED = 5

var root_motion = Transform()

var fade_in_frame_counter = 60

func _enter_tree():
	$fade_in.show()

func _ready():
	#pre initialize orientation transform
	orientation=$"Scene Root".global_transform
	orientation.origin = Vector3()
#	$camera_base/camera_rot/Camera.add_exception(self)

func _input(event):
	if event is InputEventMouseMotion:
		$camera_base.rotate_y( -event.relative.x * CAMERA_ROTATION_SPEED )
		$camera_base.orthonormalize() # after relative transforms, camera needs to be renormalized
		camera_x_rot = clamp(camera_x_rot + event.relative.y * CAMERA_ROTATION_SPEED,deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX) )
		$camera_base/camera_rot.rotation.x =  camera_x_rot

func _physics_process(delta):
	# Fade-in progressively to hide initial artifacts
	if fade_in_frame_counter > 0:
		if fade_in_frame_counter == 50:
			# Hide ShaderCache after a few frames to be sure the shaders compiled
			$camera_base/camera_rot/Camera/ShaderCache.hide()
		$fade_in.modulate.a = lerp(1.0, 0.0, 1.0 - fade_in_frame_counter / 60.0)
		fade_in_frame_counter -= 1
		if fade_in_frame_counter == 0:
			$fade_in.hide()

	# Character controller
	
	var motion_target = Vector2( 	Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
									Input.get_action_strength("move_forward") - Input.get_action_strength("move_back") )
			
	motion = motion.linear_interpolate(motion_target, MOTION_INTERPOLATE_SPEED * delta)
	
	var cam_z = - $camera_base/camera_rot/Camera.global_transform.basis.z			
	var cam_x = $camera_base/camera_rot/Camera.global_transform.basis.x
	
	cam_z.y=0
	cam_z = cam_z.normalized()
	cam_x.y=0
	cam_x = cam_x.normalized()
	
	var current_aim = Input.is_action_pressed("aim")
	
	if (aiming != current_aim):
			aiming = current_aim
			if (aiming):
				$camera_base/animation.play("shoot")
			else:
				$camera_base/animation.play("far")
	
	# jump/air logic
	airborne_time += delta
	if (is_on_floor()):
		if (airborne_time>0.5):
			$sfx/land.play()
		airborne_time = 0
		
	var on_air = airborne_time > MIN_AIRBORNE_TIME
	
	if (not on_air and Input.is_action_just_pressed("jump")):
		velocity.y = JUMP_SPEED
		on_air = true
		$animation_tree["parameters/state/current"]=2
		$sfx/jump.play()							


	if (on_air):
		
		if (velocity.y > 0):
			$animation_tree["parameters/state/current"]=2
		else:
			$animation_tree["parameters/state/current"]=3
	
	elif (aiming):
		
		# change state to strafe
		$animation_tree["parameters/state/current"]=0

		#change aim according to camera rotation
				
		if (camera_x_rot >= 0): # aim up		
			$animation_tree["parameters/aim/add_amount"]=-camera_x_rot / deg2rad(CAMERA_X_ROT_MAX)
		else: # aim down
			$animation_tree["parameters/aim/add_amount"] = camera_x_rot / deg2rad(CAMERA_X_ROT_MIN)
					
		# convert orientation to quaternions for interpolating rotation
		var q_from = Quat(orientation.basis)
		var q_to = Quat( $camera_base.global_transform.basis )	
		# interpolate current rotation with desired one
		orientation.basis = Basis(q_from.slerp(q_to,delta*ROTATION_INTERPOLATE_SPEED))
			

		$animation_tree["parameters/strafe/blend_position"]=motion


		# get root motion transform
		root_motion = $animation_tree.get_root_motion_transform()		

		if (Input.is_action_just_pressed("shoot")):
			var shoot_from = $"Scene Root/Robot_Skeleton/Skeleton/gun_bone/shoot_from".global_transform.origin
			var cam = $camera_base/camera_rot/Camera
			
			var ch_pos = $crosshair.rect_position + $crosshair.rect_size * 0.5
			var ray_from = cam.project_ray_origin(ch_pos)
			var ray_dir = cam.project_ray_normal(ch_pos)
			var shoot_target
			
			var col = get_world().direct_space_state.intersect_ray( ray_from, ray_from + ray_dir * 1000, [self] )
			if (col.empty()):
				shoot_target = ray_from + ray_dir * 1000
			else:
				shoot_target = col.position
				
			var shoot_dir = (shoot_target - shoot_from).normalized()
			
			var bullet = preload("res://player/bullet.tscn").instance()

			get_parent().add_child(bullet)
			bullet.global_transform.origin = shoot_from
			bullet.direction = shoot_dir 	
			bullet.add_collision_exception_with(self)
			$sfx/shoot.play()							
			
	else: 		
		# convert orientation to quaternions for interpolating rotation
		
		var target = - cam_x * motion.x -  cam_z * motion.y
		if (target.length() > 0.001):
			var q_from = Quat(orientation.basis)
			var q_to = Quat(Transform().looking_at(target,Vector3(0,1,0)).basis)
	
			# interpolate current rotation with desired one
			orientation.basis = Basis(q_from.slerp(q_to,delta*ROTATION_INTERPOLATE_SPEED))
		
		#aim to zero (no aiming while walking
		
		$animation_tree["parameters/aim/add_amount"]=0
		# change state to walk
		$animation_tree["parameters/state/current"]=1
		# blend position for walk speed based on motion
		$animation_tree["parameters/walk/blend_position"]=Vector2(motion.length(),0 ) 
		
		# get root motion transform
		root_motion = $animation_tree.get_root_motion_transform()		

	
	# apply root motion to orientation
	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z		
	velocity += GRAVITY * delta
	velocity = move_and_slide(velocity,Vector3(0,1,0))

	orientation.origin = Vector3() #clear accumulated root motion displacement (was applied to speed)
	orientation = orientation.orthonormalized() # orthonormalize orientation
	
	$"Scene Root".global_transform.basis = orientation.basis
	
	
		
		
	
	
func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
