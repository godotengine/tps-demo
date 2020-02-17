extends Spatial


signal quit
#warning-ignore:unused_signal
signal replace_main_scene # Useless, but needed as there is no clean way to check if a node exposes a signal


func _ready():
	if settings.gi_quality == settings.GIQuality.HIGH:
		ProjectSettings["rendering/quality/voxel_cone_tracing/high_quality"] = true
	elif settings.gi_quality == settings.GIQuality.LOW:
		ProjectSettings["rendering/quality/voxel_cone_tracing/high_quality"] = false
	else:
		$GIProbe.hide()
		$refprobes.show()
	
	if settings.aa_quality == settings.AAQuality.AA_8X:
		get_node("/root").msaa = Viewport.MSAA_8X
	elif settings.aa_quality == settings.AAQuality.AA_4X:
		get_node("/root").msaa = Viewport.MSAA_4X
	elif settings.aa_quality == settings.AAQuality.AA_2X:
		get_node("/root").msaa = Viewport.MSAA_2X
	else:
		get_node("/root").msaa = Viewport.MSAA_DISABLED
	
	if settings.ssao_quality == settings.SSAOQuality.HIGH:
		$WorldEnvironment.environment.ssao_quality = $WorldEnvironment.environment.SSAO_QUALITY_HIGH
	elif settings.ssao_quality == settings.SSAOQuality.LOW:
		$WorldEnvironment.environment.ssao_quality = $WorldEnvironment.environment.SSAO_QUALITY_LOW
	else:
		$WorldEnvironment.environment.ssao_enabled = false
	
	if settings.resolution == settings.Resolution.NATIVE:
		pass
	elif settings.resolution == settings.Resolution.RES_1080:
		var minsize = Vector2(OS.window_size.x * 1080 / OS.window_size.y, 1080.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, minsize)
	elif settings.resolution == settings.Resolution.RES_720:
		var minsize = Vector2(OS.window_size.x * 720 / OS.window_size.y, 720.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, minsize)
	elif settings.resolution == settings.Resolution.RES_576:
		var minsize = Vector2(OS.window_size.x * 576 / OS.window_size.y, 576.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, minsize)


func _input(event):
	if event.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("quit")
