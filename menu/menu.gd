extends Node

var res_loader: ResourceInteractiveLoader = null
var loading_thread: Thread = null

signal replace_main_scene
#warning-ignore:unused_signal
signal quit # Useless, but needed as there is no clean way to check if a node exposes a signal

onready var ui = $UI
onready var main = ui.get_node(@"Main")
onready var play_button = main.get_node(@"Play")
onready var settings_button = main.get_node(@"Settings")
onready var quit_button = main.get_node(@"Quit")

onready var settings_menu = ui.get_node(@"Settings")
onready var settings_actions = settings_menu.get_node(@"Actions")
onready var settings_action_apply = settings_actions.get_node(@"Apply")
onready var settings_action_cancel = settings_actions.get_node(@"Cancel")

onready var aa_menu = settings_menu.get_node(@"AA")
onready var aa_8x = aa_menu.get_node(@"8X")
onready var aa_4x = aa_menu.get_node(@"4X")
onready var aa_2x = aa_menu.get_node(@"2X")
onready var aa_disabled = aa_menu.get_node(@"Disabled")

onready var ssao_menu = settings_menu.get_node(@"SSAO")
onready var ssao_high = ssao_menu.get_node(@"High")
onready var ssao_low = ssao_menu.get_node(@"Low")
onready var ssao_disabled = ssao_menu.get_node(@"Disabled")

onready var bloom_menu = settings_menu.get_node(@"Bloom")
onready var bloom_high = bloom_menu.get_node(@"High")
onready var bloom_low = bloom_menu.get_node(@"Low")
onready var bloom_disabled = bloom_menu.get_node(@"Disabled")

onready var resolution_menu = settings_menu.get_node(@"Resolution")
onready var resolution_native = resolution_menu.get_node(@"Native")
onready var resolution_1080 = resolution_menu.get_node(@"1080")
onready var resolution_720 = resolution_menu.get_node(@"720")
onready var resolution_540 = resolution_menu.get_node(@"540")

onready var fullscreen_menu = settings_menu.get_node(@"Fullscreen")
onready var fullscreen_yes = fullscreen_menu.get_node(@"Yes")
onready var fullscreen_no = fullscreen_menu.get_node(@"No")

onready var loading = ui.get_node(@"Loading")
onready var loading_progress = loading.get_node(@"Progress")
onready var loading_done_timer = loading.get_node(@"DoneTimer")

func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1920, 1080))
	play_button.grab_focus()
	var sound_effects = $BackgroundCache/RedRobot/SoundEffects
	for child in sound_effects.get_children():
		child.unit_db = -200


func interactive_load(loader):
	while true:
		var status = loader.poll()
		if status == OK:
			loading_progress.value = (loader.get_stage() * 100) / loader.get_stage_count()
			continue
		elif status == ERR_FILE_EOF:
			loading_progress.value = 100
			loading_done_timer.start()
			break
		else:
			print("Error while loading level: " + str(status))
			main.show()
			loading.hide()
			break


func loading_done(loader):
	loading_thread.wait_to_finish()
	emit_signal("replace_main_scene", loader.get_resource())
	res_loader = null
	# Weirdly, "res_loader = null" is needed as otherwise
	# loading the resource again is not possible.


func _on_loading_done_timer_timeout():
	loading_done(res_loader)


func _on_play_pressed():
	main.hide()
	loading.show()
	var path = "res://level/level.tscn"
	if ResourceLoader.has_cached(path):
		emit_signal("replace_main_scene", ResourceLoader.load(path))
	else:
		res_loader = ResourceLoader.load_interactive(path)
		loading_thread = Thread.new()
		#warning-ignore:return_value_discarded
		loading_thread.start(self, "interactive_load", res_loader)


func _on_settings_pressed():
	main.hide()
	settings_menu.show()
	settings_action_cancel.grab_focus()

	if Settings.aa_quality == Settings.AAQuality.AA_8X:
		aa_8x.pressed = true
	elif Settings.aa_quality == Settings.AAQuality.AA_4X:
		aa_4x.pressed = true
	elif Settings.aa_quality == Settings.AAQuality.AA_2X:
		aa_2x.pressed = true
	elif Settings.aa_quality == Settings.AAQuality.DISABLED:
		aa_disabled.pressed = true

	if Settings.ssao_quality == Settings.SSAOQuality.HIGH:
		ssao_high.pressed = true
	elif Settings.ssao_quality == Settings.SSAOQuality.LOW:
		ssao_low.pressed = true
	elif Settings.ssao_quality == Settings.SSAOQuality.DISABLED:
		ssao_disabled.pressed = true

	if Settings.bloom_quality == Settings.BloomQuality.HIGH:
		bloom_high.pressed = true
	elif Settings.bloom_quality == Settings.BloomQuality.LOW:
		bloom_low.pressed = true
	elif Settings.bloom_quality == Settings.BloomQuality.DISABLED:
		bloom_disabled.pressed = true

	if Settings.resolution == Settings.Resolution.NATIVE:
		resolution_native.pressed = true
	elif Settings.resolution == Settings.Resolution.RES_1080:
		resolution_1080.pressed = true
	elif Settings.resolution == Settings.Resolution.RES_720:
		resolution_720.pressed = true
	elif Settings.resolution == Settings.Resolution.RES_540:
		resolution_540.pressed = true

	if Settings.fullscreen:
		fullscreen_yes.pressed = true
	else:
		fullscreen_no.pressed = true


func _on_quit_pressed():
	get_tree().quit()


func _on_apply_pressed():
	main.show()
	play_button.grab_focus()
	settings_menu.hide()

	if aa_8x.pressed:
		Settings.aa_quality = Settings.AAQuality.AA_8X
	elif aa_4x.pressed:
		Settings.aa_quality = Settings.AAQuality.AA_4X
	elif aa_2x.pressed:
		Settings.aa_quality = Settings.AAQuality.AA_2X
	elif aa_disabled.pressed:
		Settings.aa_quality = Settings.AAQuality.DISABLED

	if ssao_high.pressed:
		Settings.ssao_quality = Settings.SSAOQuality.HIGH
	elif ssao_low.pressed:
		Settings.ssao_quality = Settings.SSAOQuality.LOW
	elif ssao_disabled.pressed:
		Settings.ssao_quality = Settings.SSAOQuality.DISABLED

	if bloom_high.pressed:
		Settings.bloom_quality = Settings.BloomQuality.HIGH
	elif bloom_low.pressed:
		Settings.bloom_quality = Settings.BloomQuality.LOW
	elif bloom_disabled.pressed:
		Settings.bloom_quality = Settings.BloomQuality.DISABLED

	if resolution_native.pressed:
		Settings.resolution = Settings.Resolution.NATIVE
	elif resolution_1080.pressed:
		Settings.resolution = Settings.Resolution.RES_1080
	elif resolution_720.pressed:
		Settings.resolution = Settings.Resolution.RES_720
	elif resolution_540.pressed:
		Settings.resolution = Settings.Resolution.RES_540

	Settings.fullscreen = fullscreen_yes.pressed

	# Apply the setting directly
	OS.window_fullscreen = Settings.fullscreen

	Settings.save_settings()


func _on_cancel_pressed():
	main.show()
	play_button.grab_focus()
	settings_menu.hide()
