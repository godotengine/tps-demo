extends Node

var path = "res://level/level.tscn"

signal replace_main_scene
#warning-ignore:unused_signal
signal quit # Useless, but needed as there is no clean way to check if a node exposes a signal

var peer : MultiplayerPeer = OfflineMultiplayerPeer.new()

@onready var world_environment = $WorldEnvironment

@onready var ui = $UI
@onready var main = ui.get_node("Main")
@onready var online = ui.get_node("Online")
@onready var play_button = main.get_node("Play")
@onready var settings_button = main.get_node("Settings")
@onready var quit_button = main.get_node("Quit")

@onready var settings_menu = ui.get_node("Settings")
@onready var settings_actions = settings_menu.get_node("Actions")
@onready var settings_action_apply = settings_actions.get_node("Apply")
@onready var settings_action_cancel = settings_actions.get_node("Cancel")

@onready var display_mode_menu = settings_menu.get_node("DisplayMode")
@onready var display_mode_windowed = display_mode_menu.get_node("Windowed")
@onready var display_mode_fullscreen = display_mode_menu.get_node("Fullscreen")
@onready var display_mode_exclusive_fullscreen = display_mode_menu.get_node("ExclusiveFullscreen")

@onready var vsync_menu = settings_menu.get_node("VSync")
@onready var vsync_disabled = vsync_menu.get_node("Disabled")
@onready var vsync_enabled = vsync_menu.get_node("Enabled")
@onready var vsync_adaptive = vsync_menu.get_node("Adaptive")
@onready var vsync_mailbox = vsync_menu.get_node("Mailbox")

@onready var max_fps_menu = settings_menu.get_node("MaxFPS")
@onready var max_fps_30 = max_fps_menu.get_node("30")
@onready var max_fps_40 = max_fps_menu.get_node("40")
@onready var max_fps_60 = max_fps_menu.get_node("60")
@onready var max_fps_72 = max_fps_menu.get_node("72")
@onready var max_fps_90 = max_fps_menu.get_node("90")
@onready var max_fps_120 = max_fps_menu.get_node("120")
@onready var max_fps_144 = max_fps_menu.get_node("144")
@onready var max_fps_unlimited = max_fps_menu.get_node("Unlimited")

@onready var resolution_scale_menu = settings_menu.get_node("ResolutionScale")
@onready var resolution_scale_ultra_performance = resolution_scale_menu.get_node("UltraPerformance")
@onready var resolution_scale_performance = resolution_scale_menu.get_node("Performance")
@onready var resolution_scale_balanced = resolution_scale_menu.get_node("Balanced")
@onready var resolution_scale_quality = resolution_scale_menu.get_node("Quality")
@onready var resolution_scale_ultra_quality = resolution_scale_menu.get_node("UltraQuality")
@onready var resolution_scale_native = resolution_scale_menu.get_node("Native")

@onready var scale_filter_menu = settings_menu.get_node("ScaleFilter")
@onready var scale_filter_bilinear = scale_filter_menu.get_node("Bilinear")
@onready var scale_filter_fsr1 = scale_filter_menu.get_node("FSR1")
@onready var scale_filter_fsr2 = scale_filter_menu.get_node("FSR2")

@onready var taa_menu = settings_menu.get_node("TAA")
@onready var taa_disabled = taa_menu.get_node("Disabled")
@onready var taa_enabled = taa_menu.get_node("Enabled")

@onready var msaa_menu = settings_menu.get_node("MSAA")
@onready var msaa_disabled = msaa_menu.get_node("Disabled")
@onready var msaa_2x = msaa_menu.get_node("2X")
@onready var msaa_4x = msaa_menu.get_node("4X")
@onready var msaa_8x = msaa_menu.get_node("8X")

@onready var fxaa_menu = settings_menu.get_node("FXAA")
@onready var fxaa_disabled = fxaa_menu.get_node("Disabled")
@onready var fxaa_enabled = fxaa_menu.get_node("Enabled")

@onready var shadow_mapping_menu = settings_menu.get_node("ShadowMapping")
@onready var shadow_mapping_disabled = shadow_mapping_menu.get_node("Disabled")
@onready var shadow_mapping_enabled = shadow_mapping_menu.get_node("Enabled")

@onready var gi_type_menu = settings_menu.get_node("GIType")
@onready var gi_lightmapgi = gi_type_menu.get_node("LightmapGI")
@onready var gi_voxelgi = gi_type_menu.get_node("VoxelGI")
@onready var gi_sdfgi = gi_type_menu.get_node("SDFGI")

@onready var gi_quality_menu = settings_menu.get_node("GIQuality")
@onready var gi_disabled = gi_quality_menu.get_node("Disabled")
@onready var gi_low = gi_quality_menu.get_node("Low")
@onready var gi_high = gi_quality_menu.get_node("High")

@onready var ssao_menu = settings_menu.get_node("SSAO")
@onready var ssao_disabled = ssao_menu.get_node("Disabled")
@onready var ssao_medium = ssao_menu.get_node("Medium")
@onready var ssao_high = ssao_menu.get_node("High")

@onready var ssil_menu = settings_menu.get_node("SSIL")
@onready var ssil_disabled = ssil_menu.get_node("Disabled")
@onready var ssil_medium = ssil_menu.get_node("Medium")
@onready var ssil_high = ssil_menu.get_node("High")

@onready var bloom_menu = settings_menu.get_node("Bloom")
@onready var bloom_disabled = bloom_menu.get_node("Disabled")
@onready var bloom_enabled = bloom_menu.get_node("Enabled")

@onready var volumetric_fog_menu = settings_menu.get_node("VolumetricFog")
@onready var volumetric_fog_disabled = volumetric_fog_menu.get_node("Disabled")
@onready var volumetric_fog_enabled = volumetric_fog_menu.get_node("Enabled")

@onready var loading = ui.get_node("Loading")
@onready var loading_progress = loading.get_node("Progress")
@onready var loading_done_timer = loading.get_node("DoneTimer")

func _ready():
	# Apply relevant settings directly.
	Settings.apply_graphics_settings(get_window(), world_environment.environment, self)

	if DisplayServer.get_name() == "headless":
		_on_host_pressed.call_deferred()

	play_button.grab_focus()
	var sound_effects = $BackgroundCache/RedRobot/SoundEffects
	for child in sound_effects.get_children():
		child.volume_db = -INF
	for menu in [
		display_mode_menu, vsync_menu, max_fps_menu, resolution_scale_menu, scale_filter_menu,
		taa_menu, msaa_menu, fxaa_menu, shadow_mapping_menu, gi_type_menu, gi_quality_menu,
		ssao_menu, ssil_menu, bloom_menu, volumetric_fog_menu,
	]:
		_make_button_group(menu)

func _process(_delta):
	if loading.visible:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress.value = progress[0] * 100
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			loading_progress.value = 100
			set_process(false)
			loading_done_timer.start()
		else:
			print("Error while loading level: " + str(status))
			main.show()
			loading.hide()

func _make_button_group(common_parent: Node):
	var group = ButtonGroup.new()
	for btn in common_parent.get_children():
		if not btn is BaseButton:
			continue
		btn.button_group = group

func _on_loading_done_timer_timeout():
	multiplayer.multiplayer_peer = peer
	emit_signal("replace_main_scene", ResourceLoader.load_threaded_get(path))

func _on_play_pressed():
	main.hide()
	loading.show()
	if ResourceLoader.has_cached(path):
		multiplayer.multiplayer_peer = peer
		emit_signal("replace_main_scene", ResourceLoader.load_threaded_get(path))
	else:
		ResourceLoader.load_threaded_request(path, "", true)

func _on_settings_pressed():
	main.hide()
	settings_menu.show()
	settings_action_cancel.grab_focus()

	if (
			Settings.config_file.get_value("video", "display_mode") == Window.MODE_WINDOWED
			or Settings.config_file.get_value("video", "display_mode") == Window.MODE_MAXIMIZED
	):
		display_mode_windowed.button_pressed = true
	elif Settings.config_file.get_value("video", "display_mode") == Window.MODE_FULLSCREEN:
		display_mode_fullscreen.button_pressed = true
	else:
		display_mode_exclusive_fullscreen.button_pressed = true

	if Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_DISABLED:
		vsync_disabled.button_pressed = true
	elif Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_ENABLED:
		vsync_enabled.button_pressed = true
	elif Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_ADAPTIVE:
		vsync_adaptive.button_pressed = true
	else:
		vsync_mailbox.button_pressed = true

	if Settings.config_file.get_value("video", "max_fps") == 30:
		max_fps_30.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 40:
		max_fps_40.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 60:
		max_fps_60.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 72:
		max_fps_72.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 90:
		max_fps_90.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 120:
		max_fps_120.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 144:
		max_fps_144.button_pressed = true
	else:
		max_fps_unlimited.button_pressed = true

	if is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 3.0):
		resolution_scale_ultra_performance.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 2.0):
		resolution_scale_performance.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 1.7):
		resolution_scale_balanced.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 1.5):
		resolution_scale_quality.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 1.3):
		resolution_scale_ultra_quality.button_pressed = true
	else:
		resolution_scale_native.button_pressed = true

	if Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_BILINEAR:
		scale_filter_bilinear.button_pressed = true
	elif Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_FSR:
		scale_filter_fsr1.button_pressed = true
	else:
		scale_filter_fsr2.button_pressed = true

	if Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.LIGHTMAP_GI:
		gi_lightmapgi.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.VOXEL_GI:
		gi_voxelgi.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.SDFGI:
		gi_sdfgi.button_pressed = true

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.DISABLED:
		gi_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.LOW:
		gi_low.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.HIGH:
		gi_high.button_pressed = true

	if not Settings.config_file.get_value("rendering", "taa"):
		taa_disabled.button_pressed = true
	else:
		taa_enabled.button_pressed = true

	if Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_DISABLED:
		msaa_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_2X:
		msaa_2x.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_4X:
		msaa_4x.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_8X:
		msaa_8x.button_pressed = true

	if not Settings.config_file.get_value("rendering", "fxaa"):
		fxaa_disabled.button_pressed = true
	else:
		fxaa_enabled.button_pressed = true

	if not Settings.config_file.get_value("rendering", "shadow_mapping"):
		shadow_mapping_disabled.button_pressed = true
	else:
		shadow_mapping_enabled.button_pressed = true

	if Settings.config_file.get_value("rendering", "ssao_quality") == -1:
		ssao_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssao_quality") == RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
		ssao_medium.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssao_quality") == RenderingServer.ENV_SSAO_QUALITY_HIGH:
		ssao_high.button_pressed = true

	if Settings.config_file.get_value("rendering", "ssil_quality") == -1:
		ssil_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssil_quality") == RenderingServer.ENV_SSIL_QUALITY_MEDIUM:
		ssil_medium.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssil_quality") == RenderingServer.ENV_SSIL_QUALITY_HIGH:
		ssil_high.button_pressed = true

	if not Settings.config_file.get_value("rendering", "bloom"):
		bloom_disabled.button_pressed = true
	else:
		bloom_enabled.button_pressed = true

	if not Settings.config_file.get_value("rendering", "volumetric_fog"):
		volumetric_fog_disabled.button_pressed = true
	else:
		volumetric_fog_enabled.button_pressed = true


func _on_quit_pressed():
	get_tree().quit()


func _on_apply_pressed():
	main.show()
	play_button.grab_focus()
	settings_menu.hide()

	if display_mode_windowed.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_WINDOWED)
	elif display_mode_fullscreen.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_FULLSCREEN)
	elif display_mode_exclusive_fullscreen.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_EXCLUSIVE_FULLSCREEN)

	if vsync_disabled.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_DISABLED)
	elif vsync_enabled.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_ENABLED)
	elif vsync_adaptive.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_ADAPTIVE)
	elif vsync_mailbox.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_MAILBOX)

	if max_fps_30.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 30)
	elif max_fps_40.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 40)
	elif max_fps_60.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 60)
	elif max_fps_72.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 72)
	elif max_fps_90.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 90)
	elif max_fps_120.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 120)
	elif max_fps_144.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 144)
	elif max_fps_unlimited.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 0)

	if resolution_scale_ultra_performance.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 3.0)
	elif resolution_scale_performance.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 2.0)
	elif resolution_scale_balanced.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 1.7)
	elif resolution_scale_quality.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 1.5)
	elif resolution_scale_ultra_quality.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 1.3)
	elif resolution_scale_native.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0)

	if scale_filter_bilinear.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_BILINEAR)
	elif scale_filter_fsr1.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_FSR)
	elif scale_filter_fsr2.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_FSR2)

	if gi_lightmapgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.LIGHTMAP_GI)
	elif gi_voxelgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.VOXEL_GI)
	elif gi_sdfgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.SDFGI)

	if gi_low.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.LOW)
	elif gi_high.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.HIGH)
	elif gi_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.DISABLED)

	Settings.config_file.set_value("rendering", "taa", taa_enabled.button_pressed)

	if msaa_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_DISABLED)
	elif msaa_2x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_2X)
	elif msaa_4x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_4X)
	elif msaa_8x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_8X)

	Settings.config_file.set_value("rendering", "shadow_mapping", shadow_mapping_enabled.button_pressed)
	Settings.config_file.set_value("rendering", "fxaa", fxaa_enabled.button_pressed)

	if ssao_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", -1)
	elif ssao_medium.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", RenderingServer.ENV_SSAO_QUALITY_MEDIUM)
	elif ssao_high.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", RenderingServer.ENV_SSAO_QUALITY_HIGH)

	if ssil_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "ssil_quality", -1)
	elif ssil_medium.button_pressed:
		Settings.config_file.set_value("rendering", "ssil_quality", RenderingServer.ENV_SSIL_QUALITY_MEDIUM)
	elif ssil_high.button_pressed:
		Settings.config_file.set_value("rendering", "ssil_quality", RenderingServer.ENV_SSIL_QUALITY_HIGH)

	Settings.config_file.set_value("rendering", "bloom", bloom_enabled.button_pressed)
	Settings.config_file.set_value("rendering", "volumetric_fog", volumetric_fog_enabled.button_pressed)

	# Apply relevant settings directly.
	Settings.apply_graphics_settings(get_window(), world_environment.environment, self)

	Settings.save_settings()


func _on_cancel_pressed():
	main.show()
	play_button.grab_focus()
	settings_menu.hide()
	online.hide()


func _on_play_online_pressed():
	online.show()
	main.hide()


func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(int($UI/Online/Port.value))
	_on_play_pressed()
	online.hide()


func _on_connect_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client($UI/Online/Address.text, int($UI/Online/Port.value))
	_on_play_pressed()
	online.hide()
