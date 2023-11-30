extends Node3D

const RedRobot = preload("res://enemies/red_robot/red_robot.tscn")
const PlayerScene = preload("res://player/player.tscn")
var lightmap_gi = null

signal quit
#warning-ignore:unused_signal
signal replace_main_scene # Useless, but needed as there is no clean way to check if a node exposes a signal

@onready var world_environment = $WorldEnvironment
@onready var robot_spawn_points = $RobotSpawnpoints
@onready var player_spawn_points = $PlayerSpawnpoints
@onready var spawn_node = $SpawnedNodes

func _ready():
	Settings.apply_graphics_settings(get_window(), world_environment.environment, self)

	if Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.SDFGI:
		setup_sdfgi()
	elif Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.VOXEL_GI:
		setup_voxelgi()
	else:
		setup_lightmapgi()

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


func setup_sdfgi():
	world_environment.environment.sdfgi_enabled = true
	$VoxelGI.hide()
	$ReflectionProbes.hide()
	# LightmapGI nodes override SDFGI (even when hidden)
	# so we need to free the LightmapGI node if it exists
	if (lightmap_gi != null):
		lightmap_gi.queue_free()

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.HIGH:
		RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_96)
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.LOW:
		RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_32)
	else:
		world_environment.environment.sdfgi_enabled = false


func setup_voxelgi():
	world_environment.environment.sdfgi_enabled = false
	$VoxelGI.show()
	$ReflectionProbes.hide()
	# LightmapGI nodes override VoxelGI (even when hidden)
	# so we need to free the LightmapGI node if it exists
	if (lightmap_gi != null):
		lightmap_gi.queue_free()

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.HIGH:
		RenderingServer.voxel_gi_set_quality(RenderingServer.VOXEL_GI_QUALITY_HIGH)
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.LOW:
		RenderingServer.voxel_gi_set_quality(RenderingServer.VOXEL_GI_QUALITY_LOW)
	else:
		$VoxelGI.hide()


func setup_lightmapgi():
	world_environment.environment.sdfgi_enabled = false
	$VoxelGI.hide()
	$ReflectionProbes.show()
	# If no LightmapGI node, create one
	if (lightmap_gi == null):
		var new_gi = LightmapGI.new()
		new_gi.light_data = load("res://level/level.lmbake")
		new_gi.name = "LightmapGI"
		lightmap_gi = new_gi
		add_child(new_gi)

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.DISABLED:
		lightmap_gi.hide()
		$ReflectionProbes.hide()


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
