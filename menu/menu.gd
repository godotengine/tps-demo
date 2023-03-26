extends Node

var path = "res://level/level.tscn"

signal replace_main_scene
#warning-ignore:unused_signal
signal quit # Useless, but needed as there is no clean way to check if a node exposes a signal

var peer : MultiplayerPeer = OfflineMultiplayerPeer.new()

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

@onready var gi_type_menu = settings_menu.get_node("GIType")
@onready var gi_sdfgi = gi_type_menu.get_node("SDFGI")
@onready var gi_voxelgi = gi_type_menu.get_node("VoxelGI")
@onready var gi_lightmapgi = gi_type_menu.get_node("LightmapGI")

@onready var gi_menu = settings_menu.get_node("GI")
@onready var gi_high = gi_menu.get_node("High")
@onready var gi_low = gi_menu.get_node("Low")
@onready var gi_disabled = gi_menu.get_node("Disabled")

@onready var aa_menu = settings_menu.get_node("AA")
@onready var aa_8x = aa_menu.get_node("8X")
@onready var aa_4x = aa_menu.get_node("4X")
@onready var aa_2x = aa_menu.get_node("2X")
@onready var aa_disabled = aa_menu.get_node("Disabled")

@onready var shadow_menu = settings_menu.get_node("Shadow")
@onready var shadow_enabled = shadow_menu.get_node("Enabled")
@onready var shadow_disabled = shadow_menu.get_node("Disabled")

@onready var fxaa_menu = settings_menu.get_node("FXAA")
@onready var fxaa_enabled = fxaa_menu.get_node("Enabled")
@onready var fxaa_disabled = fxaa_menu.get_node("Disabled")

@onready var ssao_menu = settings_menu.get_node("SSAO")
@onready var ssao_high = ssao_menu.get_node("High")
@onready var ssao_low = ssao_menu.get_node("Low")
@onready var ssao_disabled = ssao_menu.get_node("Disabled")

@onready var bloom_menu = settings_menu.get_node("Bloom")
@onready var bloom_enabled = bloom_menu.get_node("Enabled")
@onready var bloom_disabled = bloom_menu.get_node("Disabled")

@onready var resolution_menu = settings_menu.get_node("Resolution")
@onready var resolution_100 = resolution_menu.get_node("100")
@onready var resolution_90 = resolution_menu.get_node("90")
@onready var resolution_70 = resolution_menu.get_node("70")
@onready var resolution_50 = resolution_menu.get_node("50")

@onready var fullscreen_menu = settings_menu.get_node("Fullscreen")
@onready var fullscreen_yes = fullscreen_menu.get_node("Yes")
@onready var fullscreen_no = fullscreen_menu.get_node("No")

@onready var loading = ui.get_node("Loading")
@onready var loading_progress = loading.get_node("Progress")
@onready var loading_done_timer = loading.get_node("DoneTimer")

func _ready():
	if DisplayServer.get_name() == "headless":
		_on_host_pressed.call_deferred()

	play_button.grab_focus()
	var sound_effects = $BackgroundCache/RedRobot/SoundEffects
	for child in sound_effects.get_children():
		child.volume_db = -200
	for menu in [gi_type_menu, gi_menu, aa_menu, fxaa_menu, ssao_menu, shadow_menu,
			bloom_menu, resolution_menu, fullscreen_menu]:
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

	if Settings.gi_type == Settings.GIType.SDFGI:
		gi_sdfgi.button_pressed = true
	elif Settings.gi_type == Settings.GIType.VOXEL_GI:
		gi_voxelgi.button_pressed = true
	elif Settings.gi_type == Settings.GIType.LIGHTMAP_GI:
		gi_lightmapgi.button_pressed = true

	if Settings.gi_quality == Settings.GIQuality.HIGH:
		gi_high.button_pressed = true
	elif Settings.gi_quality == Settings.GIQuality.LOW:
		gi_low.button_pressed = true
	elif Settings.gi_quality == Settings.GIQuality.DISABLED:
		gi_disabled.button_pressed = true

	if Settings.aa_quality == Settings.AAQuality.AA_8X:
		aa_8x.button_pressed = true
	elif Settings.aa_quality == Settings.AAQuality.AA_4X:
		aa_4x.button_pressed = true
	elif Settings.aa_quality == Settings.AAQuality.AA_2X:
		aa_2x.button_pressed = true
	elif Settings.aa_quality == Settings.AAQuality.DISABLED:
		aa_disabled.button_pressed = true

	if Settings.shadow_enabled:
		shadow_enabled.button_pressed = true
	else:
		shadow_disabled.button_pressed = true

	if Settings.fxaa:
		fxaa_enabled.button_pressed = true
	else:
		fxaa_disabled.button_pressed = true

	if Settings.ssao_quality == Settings.SSAOQuality.HIGH:
		ssao_high.button_pressed = true
	elif Settings.ssao_quality == Settings.SSAOQuality.LOW:
		ssao_low.button_pressed = true
	elif Settings.ssao_quality == Settings.SSAOQuality.DISABLED:
		ssao_disabled.button_pressed = true

	if Settings.bloom:
		bloom_enabled.button_pressed = true
	else:
		bloom_disabled.button_pressed = true

	if Settings.resolution > 0.99:
		resolution_100.button_pressed = true
	elif Settings.resolution > 0.89:
		resolution_90.button_pressed = true
	elif Settings.resolution > 0.69:
		resolution_70.button_pressed = true
	elif Settings.resolution > 0.49:
		resolution_50.button_pressed = true

	if Settings.fullscreen:
		fullscreen_yes.button_pressed = true
	else:
		fullscreen_no.button_pressed = true

func _on_quit_pressed():
	get_tree().quit()


func _on_apply_pressed():
	main.show()
	play_button.grab_focus()
	settings_menu.hide()

	if gi_sdfgi.button_pressed:
		Settings.gi_type = Settings.GIType.SDFGI
	elif gi_voxelgi.button_pressed:
		Settings.gi_type = Settings.GIType.VOXEL_GI
	elif gi_lightmapgi.button_pressed:
		Settings.gi_type = Settings.GIType.LIGHTMAP_GI

	if gi_high.button_pressed:
		Settings.gi_quality = Settings.GIQuality.HIGH
	elif gi_low.button_pressed:
		Settings.gi_quality = Settings.GIQuality.LOW
	elif gi_disabled.button_pressed:
		Settings.gi_quality = Settings.GIQuality.DISABLED

	if aa_8x.button_pressed:
		Settings.aa_quality = Settings.AAQuality.AA_8X
	elif aa_4x.button_pressed:
		Settings.aa_quality = Settings.AAQuality.AA_4X
	elif aa_2x.button_pressed:
		Settings.aa_quality = Settings.AAQuality.AA_2X
	elif aa_disabled.button_pressed:
		Settings.aa_quality = Settings.AAQuality.DISABLED

	Settings.shadow_enabled = shadow_enabled.button_pressed
	Settings.fxaa = fxaa_enabled.button_pressed

	if ssao_high.button_pressed:
		Settings.ssao_quality = Settings.SSAOQuality.HIGH
	elif ssao_low.button_pressed:
		Settings.ssao_quality = Settings.SSAOQuality.LOW
	elif ssao_disabled.button_pressed:
		Settings.ssao_quality = Settings.SSAOQuality.DISABLED

	Settings.bloom = bloom_enabled.button_pressed

	if resolution_100.button_pressed:
		Settings.resolution = 1.0
	elif resolution_90.button_pressed:
		Settings.resolution = 0.9
	elif resolution_70.button_pressed:
		Settings.resolution = 0.7
	elif resolution_50.button_pressed:
		Settings.resolution = 0.5

	Settings.fullscreen = fullscreen_yes.button_pressed

	# Apply the setting directly
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (Settings.fullscreen) else Window.MODE_WINDOWED

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
