extends Spatial


signal quit
#warning-ignore:unused_signal
signal replace_main_scene # Useless, but needed as there is no clean way to check if a node exposes a signal

onready var world_environment = $WorldEnvironment

func _ready():
	if Settings.gi_quality == Settings.GIQuality.HIGH:
		ProjectSettings["rendering/quality/voxel_cone_tracing/high_quality"] = true
	elif Settings.gi_quality == Settings.GIQuality.LOW:
		ProjectSettings["rendering/quality/voxel_cone_tracing/high_quality"] = false
	else:
		$GIProbe.hide()
		$ReflectionProbes.show()

	if Settings.aa_quality == Settings.AAQuality.AA_8X:
		get_viewport().msaa = Viewport.MSAA_8X
	elif Settings.aa_quality == Settings.AAQuality.AA_4X:
		get_viewport().msaa = Viewport.MSAA_4X
	elif Settings.aa_quality == Settings.AAQuality.AA_2X:
		get_viewport().msaa = Viewport.MSAA_2X
	else:
		get_viewport().msaa = Viewport.MSAA_DISABLED

	if not Settings.shadow_enabled:
		# Disable shadows on all lights present on level load,
		# reducing the number of draw calls significantly.
		propagate_call("set", ["shadow_enabled", false])

	if Settings.fxaa:
		get_viewport().fxaa = true

	if Settings.ssao_quality == Settings.SSAOQuality.HIGH:
		world_environment.environment.ssao_enabled = true
		world_environment.environment.ssao_quality = world_environment.environment.SSAO_QUALITY_HIGH
	elif Settings.ssao_quality == Settings.SSAOQuality.LOW:
		world_environment.environment.ssao_enabled = true
		world_environment.environment.ssao_quality = world_environment.environment.SSAO_QUALITY_LOW
	else:
		world_environment.environment.ssao_enabled = false

	if Settings.bloom_quality == Settings.BloomQuality.HIGH:
		world_environment.environment.glow_enabled = true
		world_environment.environment.glow_bicubic_upscale = true
	elif Settings.bloom_quality == Settings.BloomQuality.LOW:
		world_environment.environment.glow_enabled = true
		world_environment.environment.glow_bicubic_upscale = false
	else:
		world_environment.environment.glow_enabled = false
		world_environment.environment.glow_bicubic_upscale = false

	var window_size = OS.window_size
	if Settings.resolution == Settings.Resolution.NATIVE:
		pass
	elif Settings.resolution == Settings.Resolution.RES_1080:
		var minsize = Vector2(window_size.x * 1080 / window_size.y, 1080.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_EXPAND, minsize)
	elif Settings.resolution == Settings.Resolution.RES_720:
		var minsize = Vector2(window_size.x * 720 / window_size.y, 720.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_EXPAND, minsize)
	elif Settings.resolution == Settings.Resolution.RES_540:
		var minsize = Vector2(window_size.x * 540 / window_size.y, 540.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_EXPAND, minsize)


func _input(event):
	if event.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("quit")
