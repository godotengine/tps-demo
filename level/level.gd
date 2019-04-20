extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if (settings.gi_quality == settings.GI_QUALITY_HIGH):
		ProjectSettings["rendering/quality/voxel_cone_tracing/high_quality"]=true
	elif (settings.gi_quality == settings.GI_QUALITY_LOW):
		ProjectSettings["rendering/quality/voxel_cone_tracing/high_quality"]=false
	else:
		$GIProbe.hide()
		$refprobes.show()
		
	if (settings.aa_quality == settings.AA_8X):
		get_node("/root").msaa = Viewport.MSAA_8X
	elif (settings.aa_quality == settings.AA_4X):
		get_node("/root").msaa = Viewport.MSAA_4X
	elif (settings.aa_quality == settings.AA_2X):
		get_node("/root").msaa = Viewport.MSAA_2X
	else:
		get_node("/root").msaa = Viewport.MSAA_DISABLED
		
	if (settings.ssao_quality == settings.SSAO_QUALITY_HIGH):
		pass
	elif (settings.ssao_quality == settings.SSAO_QUALITY_LOW):
		pass
	else:
		$WorldEnvironment.environment.ssao_enabled = false
		
	if (settings.resolution == settings.RESOLUTION_NATIVE):
		pass
	elif (settings.resolution == settings.RESOLUTION_1080):
		var minsize=Vector2( OS.window_size.x * 1080 / OS.window_size.y, 1080.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,SceneTree.STRETCH_ASPECT_KEEP_HEIGHT,minsize)
	elif (settings.resolution == settings.RESOLUTION_720):
		var minsize=Vector2( OS.window_size.x * 720 / OS.window_size.y, 720.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,SceneTree.STRETCH_ASPECT_KEEP_HEIGHT,minsize)
	elif (settings.resolution == settings.RESOLUTION_576):
		var minsize=Vector2( OS.window_size.x * 576 / OS.window_size.y, 576.0)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,SceneTree.STRETCH_ASPECT_KEEP_HEIGHT,minsize)
		
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
