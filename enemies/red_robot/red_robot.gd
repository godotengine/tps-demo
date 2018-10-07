extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const GRAVITY = Vector3(0,-9.8, 0)

const PLAYER_AIM_TOLERANCE_DEGREES = 15

const STATE_APPROACH = 0
const STATE_AIM = 1
const STATE_SHOOTING = 2

var state = STATE_APPROACH

const SHOOT_WAIT = 6.0
var shoot_countdown = SHOOT_WAIT
const AIM_TIME = 1
var aim_countdown = AIM_TIME

const AIM_PREPARE_TIME = 0.5
var aim_preparing = AIM_PREPARE_TIME

var player = null
var velocity = Vector3()

var orientation = Transform()

const MAX_ENERGY = 5

var energy = MAX_ENERGY


const BLEND_AIM_SPEED = 0.05

func _ready():
	orientation=$"Scene Root".global_transform
	orientation.origin = Vector3()
	
func resume_approach():
	state = STATE_APPROACH
	aim_preparing = AIM_PREPARE_TIME
	shoot_countdown = SHOOT_WAIT
	
var dead = false
	
func hit():
	if (dead):
		return
	$AnimationTree["parameters/hit"+["1","2","3"][randi()%3]+"/active"]=true
	$sfx/hit.play()
	energy-=1
	if (energy==0):
		dead=true
		var base_xf = global_transform.basis
		$AnimationTree.active=false
		#$death/explosion.play("kaboom")
		$"Scene Root".visible=false
		$death.visible=true
		$CollisionShape.disabled=true
		$death/particles.emitting=true
		$death/part_shield1/col1.disabled=false
		$death/part_shield1/col2.disabled=false
		$death/part_shield1.mode=RigidBody.MODE_RIGID
		$death/part_shield2/col1.disabled=false
		$death/part_shield2/col2.disabled=false
		$death/part_shield2.mode=RigidBody.MODE_RIGID
		$death/part_shield3/col1.disabled=false
		$death/part_shield3/col2.disabled=false		
		$death/part_shield3.mode=RigidBody.MODE_RIGID
		$death/part_shield2.linear_velocity = (base_xf.x+Vector3(0,1,0)).normalized() * 3
		$death/part_shield3.linear_velocity = (Vector3(0,1,0)).normalized() * 3
		$death/part_shield1.linear_velocity = (-base_xf.x+Vector3(0,1,0)).normalized() * 3
		$death/part_shield2.angular_velocity = (Vector3(randf(),randf(),randf()).normalized() * Vector3(2,2,2) - Vector3(1,1,1)) * 10
		$death/part_shield1.angular_velocity = (Vector3(randf(),randf(),randf()).normalized() * Vector3(2,2,2) - Vector3(1,1,1)) * 10
		$death/part_shield3.angular_velocity = (Vector3(randf(),randf(),randf()).normalized() * Vector3(2,2,2) - Vector3(1,1,1)) * 10
		$sfx/explosion.play()


func do_shoot():
	var gt = $"Scene Root/Armature/Skeleton/ray_from".global_transform
	var ray_from = gt.origin
	var ray_dir = -gt.basis.z
	var max_dist = 1000
	
	var col = get_world().direct_space_state.intersect_ray(ray_from,ray_from + ray_dir * max_dist,[self])
	if (not col.empty()):
		max_dist = ray_from.distance_to(col.position)
		if (col.collider == player):
			pass # kill
	#clip ray in shader
	$"Scene Root/Armature/Skeleton/ray_from/ray".get_surface_material(0).set_shader_param("clip",max_dist)
	#position explosion			
	$"Scene Root/Armature/Skeleton/ray_from/explosion".transform.origin.z = -max_dist
	
var test_shoot=false
func shoot_check():
	test_shoot=true
	
func _physics_process(delta):
	if (test_shoot):
		do_shoot()
		test_shoot=false
		
	if (dead):
		return
		
	if (not player):
		$AnimationTree["parameters/state/current"]=0 # go idle and good bye
		return
	var to_player_local = $"Scene Root".global_transform.affine_inverse().xform(player.global_transform.origin)
	var to_player_angle = atan2( to_player_local.x, to_player_local.z )
		
	if (state == STATE_APPROACH):
		
		
		if (aim_preparing > 0):
			aim_preparing-=delta
			if (aim_preparing<0):
				aim_preparing=0
			$AnimationTree["parameters/aiming/blend_amount"]= aim_preparing / AIM_PREPARE_TIME

		
		if (to_player_angle < -deg2rad(PLAYER_AIM_TOLERANCE_DEGREES)):
			$AnimationTree["parameters/state/current"]=2
		elif (to_player_angle > deg2rad(PLAYER_AIM_TOLERANCE_DEGREES)):
			$AnimationTree["parameters/state/current"]=1
		else:
			$AnimationTree["parameters/state/current"]=3
			# facing player, try to shoot		
			shoot_countdown-=delta
			if (shoot_countdown <0):
				#see if player can be killed because in sight		
				var ray_from = $"Scene Root/Armature/Skeleton/ray_from".global_transform.origin
				var ray_to = player.global_transform.origin + Vector3(0,1,0) # middle of player
				var col = get_world().direct_space_state.intersect_ray(ray_from,ray_to,[self])
				if (not col.empty() and col.collider == player):					
					state = STATE_AIM
					aim_countdown = AIM_TIME
					aim_preparing = 0
					$AnimationTree["parameters/state/current"]=0

				else:
					#player not in sight, do nothing
					shoot_countdown = SHOOT_WAIT
			
	elif (state==STATE_AIM or state==STATE_SHOOTING):
		
			
			if (aim_preparing<AIM_PREPARE_TIME):
				aim_preparing+=delta
				if (aim_preparing > AIM_PREPARE_TIME):
					aim_preparing = AIM_PREPARE_TIME
					
			$AnimationTree["parameters/aiming/blend_amount"]=clamp(aim_preparing / AIM_PREPARE_TIME,0,1)
		
			aim_countdown-=delta
			if (aim_countdown<0 and state==STATE_AIM):
				
				var ray_from = $"Scene Root/Armature/Skeleton/ray_from".global_transform.origin
				var ray_to = player.global_transform.origin + Vector3(0,1,0) # middle of player
				var col = get_world().direct_space_state.intersect_ray(ray_from,ray_to,[self])
				if (not col.empty() and col.collider == player):
					state = STATE_SHOOTING
					$shoot_anim.play("shoot")
				else:
					resume_approach()
	
			if ($AnimationTree.active):
				
				var to_cannon_local = $"Scene Root/Armature/Skeleton/ray_from/ray".global_transform.affine_inverse().xform(player.global_transform.origin + Vector3(0,1,0))
				var h_angle = rad2deg(atan2( to_cannon_local.x, -to_cannon_local.z ))
				var v_angle = rad2deg(atan2( to_cannon_local.y, -to_cannon_local.z ))
	

				var blend_pos = $AnimationTree["parameters/aim/blend_position"]
				var h_motion = BLEND_AIM_SPEED * delta * -h_angle
				blend_pos.x += h_motion
				blend_pos.x = clamp(blend_pos.x, -1 , 1 )
				
				var v_motion = BLEND_AIM_SPEED * delta * v_angle
				blend_pos.y += v_motion
				blend_pos.y = clamp(blend_pos.y, -1 , 1 )
					
				$AnimationTree["parameters/aiming/blend_amount"]= blend_pos

				
			

			
	var root_motion = $AnimationTree.get_root_motion_transform()
		
		
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


		
	
			

func _on_area_body_entered(body):
	if (body is preload("res://player/player.gd")):
		player = body
		shoot_countdown=SHOOT_WAIT


func _on_area_body_exited(body):
	if (body is preload("res://player/player.gd")):
		player = null
