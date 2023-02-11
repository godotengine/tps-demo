extends Node3D

const RedRobot = preload("res://enemies/red_robot/red_robot.tscn")
const PlayerScene = preload("res://player/player.tscn")

signal quit
#warning-ignore:unused_signal
signal replace_main_scene # Useless, but needed as there is no clean way to check if a node exposes a signal

@onready var world_environment = $WorldEnvironment
@onready var robot_spawn_points = $RobotSpawnpoints
@onready var player_spawn_points = $PlayerSpawnpoints
@onready var spawn_node = $SpawnedNodes

func _ready():
	if Settings.gi_quality == Settings.GIQuality.HIGH:
		RenderingServer.voxel_gi_set_quality(RenderingServer.VOXEL_GI_QUALITY_HIGH)
	elif Settings.gi_quality == Settings.GIQuality.LOW:
		RenderingServer.voxel_gi_set_quality(RenderingServer.VOXEL_GI_QUALITY_LOW)
	else:
		$VoxelGI.hide()
		$ReflectionProbes.show()

	if Settings.aa_quality == Settings.AAQuality.AA_8X:
		get_viewport().msaa_3d = SubViewport.MSAA_8X
	elif Settings.aa_quality == Settings.AAQuality.AA_4X:
		get_viewport().msaa_3d = SubViewport.MSAA_4X
	elif Settings.aa_quality == Settings.AAQuality.AA_2X:
		get_viewport().msaa_3d = SubViewport.MSAA_2X
	else:
		get_viewport().msaa_3d = SubViewport.MSAA_DISABLED

	if not Settings.shadow_enabled:
		# Disable shadows checked all lights present checked level load,
		# reducing the number of draw calls significantly.
		propagate_call("set", ["shadow_enabled", false])

	if Settings.fxaa:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

	if Settings.ssao_quality == Settings.SSAOQuality.HIGH:
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
	elif Settings.ssao_quality == Settings.SSAOQuality.LOW:
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	else:
		world_environment.environment.ssao_enabled = false

	if Settings.bloom_quality == Settings.BloomQuality.HIGH:
		world_environment.environment.glow_enabled = true
	elif Settings.bloom_quality == Settings.BloomQuality.LOW:
		world_environment.environment.glow_enabled = true
	else:
		world_environment.environment.glow_enabled = false

	var window_size = get_window().get_size_with_decorations()
	if Settings.resolution == Settings.Resolution.NATIVE:
		pass
	elif Settings.resolution == Settings.Resolution.RES_1080:
		var minsize = Vector2(window_size.x * 1080 / window_size.y, 1080.0)
		get_window().set_content_scale_mode(Window.CONTENT_SCALE_MODE_VIEWPORT)
		get_window().set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_EXPAND)
		get_window().set_content_scale_size(minsize)
	elif Settings.resolution == Settings.Resolution.RES_720:
		var minsize = Vector2(window_size.x * 720 / window_size.y, 720.0)
		get_window().set_content_scale_mode(Window.CONTENT_SCALE_MODE_VIEWPORT)
		get_window().set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_EXPAND)
		get_window().set_content_scale_size(minsize)
	elif Settings.resolution == Settings.Resolution.RES_540:
		var minsize = Vector2(window_size.x * 540 / window_size.y, 540.0)
		get_window().set_content_scale_mode(Window.CONTENT_SCALE_MODE_VIEWPORT)
		get_window().set_content_scale_aspect(Window.CONTENT_SCALE_ASPECT_EXPAND)
		get_window().set_content_scale_size(minsize)

	if multiplayer.is_server():
		# Server will spawn the red robots
		for c in robot_spawn_points.get_children():
			spawn_robot(c)

		# Then spawn already connected players at random location
		randomize()
		var spawn_points = player_spawn_points.get_children()
		spawn_points.shuffle()
		add_player(1, spawn_points.pop_front())
		for id in multiplayer.get_peers():
			add_player(id, spawn_points.pop_front())

		# Then spawn/despawn players as they connect/disconnect
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(del_player)


func spawn_robot(spawn_point):
	var robot = RedRobot.instantiate()
	robot.transform = spawn_point.transform
	robot.exploded.connect(_respawn_robot.bind(spawn_point))
	spawn_node.add_child(robot, true)


func _respawn_robot(spawn_point):
	await get_tree().create_timer(15.0).timeout
	spawn_robot(spawn_point)


func del_player(id: int):
	if not spawn_node.has_node(str(id)):
		return
	spawn_node.get_node(str(id)).queue_free()


func add_player(id: int, spawn_point: Marker3D = null):
	if spawn_point == null:
		spawn_point = player_spawn_points.get_child(randi() % player_spawn_points.get_child_count())
	var player = PlayerScene.instantiate()
	player.name = str(id)
	player.player_id = id
	player.transform = spawn_point.transform
	spawn_node.add_child(player)


func _input(event):
	if event.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("quit")
