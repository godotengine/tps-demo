extends MultiplayerSynchronizer

const CAMERA_CONTROLLER_ROTATION_SPEED := 3.0
const CAMERA_MOUSE_ROTATION_SPEED := 0.001
# A minimum angle lower than or equal to -90 breaks movement if the player is looking upward.
const CAMERA_X_ROT_MIN := deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX := deg_to_rad(70)

# Release aiming if the mouse/gamepad button was held for longer than 0.4 seconds.
# This works well for trackpads and is more accessible by not making long presses a requirement.
# If the aiming button was held for less than 0.4 seconds, keep aiming until the aiming button is pressed again.
const AIM_HOLD_THRESHOLD = 0.4

# If `true`, the aim button was toggled checked by a short press (instead of being held down).
var toggled_aim := false

# The duration the aiming button was held for (in seconds).
var aiming_timer := 0.0

# Synchronized controls
@export var aiming := false
@export var shoot_target := Vector3()
@export var motion := Vector2()
@export var shooting := false
# This is handled via RPC for now
@export var jumping := false

# Camera and effects
@export var camera_animation : AnimationPlayer
@export var crosshair : TextureRect
@export var camera_base : Node3D
@export var camera_rot : Node3D
@export var camera_camera : Camera3D
@export var color_rect : ColorRect


func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera_camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		set_process(false)
		set_process_input(false)
		color_rect.hide()

func _process(delta):
	motion = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
	var camera_move = Vector2(
			Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
			Input.get_action_strength("view_up") - Input.get_action_strength("view_down"))
	var camera_speed_this_frame = delta * CAMERA_CONTROLLER_ROTATION_SPEED
	if aiming:
		camera_speed_this_frame *= 0.5
	rotate_camera(camera_move * camera_speed_this_frame)
	var current_aim = false

	# Keep aiming if the mouse wasn't held for long enough.
	if Input.is_action_just_released("aim") and aiming_timer <= AIM_HOLD_THRESHOLD:
		current_aim = true
		toggled_aim = true
	else:
		current_aim = toggled_aim or Input.is_action_pressed("aim")
		if Input.is_action_just_pressed("aim"):
			toggled_aim = false

	if current_aim:
		aiming_timer += delta
	else:
		aiming_timer = 0.0

	if aiming != current_aim:
		aiming = current_aim
		if aiming:
			camera_animation.play("shoot")
		else:
			camera_animation.play("far")

	if Input.is_action_just_pressed("jump"):
		jump.rpc()

	shooting = Input.is_action_pressed("shoot")
	if shooting:
		var ch_pos = crosshair.position + crosshair.size * 0.5
		var ray_from = camera_camera.project_ray_origin(ch_pos)
		var ray_dir = camera_camera.project_ray_normal(ch_pos)

		var col = get_parent().get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from, ray_from + ray_dir * 1000, 0b11, [self]))
		if col.is_empty():
			shoot_target = ray_from + ray_dir * 1000
		else:
			shoot_target = col.position

	# Fade out to black if falling out of the map. -17 is lower than
	# the lowest valid position checked the map (which is a bit under -16).
	# At 15 units below -17 (so -32), the screen turns fully black.
	var tr : Transform3D = get_parent().global_transform
	if tr.origin.y < -17:
		color_rect.modulate.a = min((-17 - tr.origin.y) / 15, 1)
	else:
		# Fade out the black ColorRect progressively after being teleported back.
		color_rect.modulate.a *= 1.0 - delta * 4


func _input(event):
	# Make mouse aiming speed resolution-independent
	# (required when using the `canvas_items` stretch mode).
	var scale_factor: float = min(
			(float(get_viewport().size.x) / get_viewport().get_visible_rect().size.x),
			(float(get_viewport().size.y) / get_viewport().get_visible_rect().size.y)
	)

	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
		if aiming:
			camera_speed_this_frame *= 0.75
		rotate_camera(event.relative * camera_speed_this_frame * scale_factor)


func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	camera_base.orthonormalize()
	camera_rot.rotation.x = clamp(camera_rot.rotation.x + move.y, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)


func get_aim_rotation():
	var camera_x_rot = clamp(camera_rot.rotation.x, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)
	# Change aim according to camera rotation.
	if camera_x_rot >= 0: # Aim up.
		return -camera_x_rot / CAMERA_X_ROT_MAX
	else: # Aim down.
		return camera_x_rot / CAMERA_X_ROT_MIN


func get_camera_base_quaternion() -> Quaternion:
	return camera_base.global_transform.basis.get_rotation_quaternion()


func get_camera_rotation_basis() -> Basis:
	return camera_rot.global_transform.basis


@rpc("call_local")
func jump():
	jumping = true
