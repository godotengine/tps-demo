extends Spatial

var res_loader : ResourceInteractiveLoader = null
var loading_thread : Thread = null

signal replace_main_scene
#warning-ignore:unused_signal
signal quit # Useless, but needed as there is no clean way to check if a node exposes a signal

func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1920, 1080))
	$ui/main/play.grab_focus()


func interactive_load(loader):
	while true:
		var status = loader.poll()
		if status == OK:
			$ui/loading/progress.value = (loader.get_stage() * 100) / loader.get_stage_count()
			continue
		elif status == ERR_FILE_EOF:
			$ui/loading/progress.value = 100
			$ui/loading/loading_done_timer.start()
			break
		else:
			print("Error while loading level: " + str(status))
			$ui/main.show()
			$ui/loading.hide()
			break


func loading_done(loader):
	loading_thread.wait_to_finish()
	emit_signal("replace_main_scene", loader.get_resource())
	res_loader = null # Weirdly, this is needed as otherwise loading the resource again is not possible


func _on_loading_done_timer_timeout():
	loading_done(res_loader)


func _on_play_pressed():
	$ui/main.hide()
	$ui/loading.show()
	var path = "res://level/level.tscn"
	if ResourceLoader.has_cached(path):
		emit_signal("replace_main_scene", ResourceLoader.load(path))
	else:
		res_loader = ResourceLoader.load_interactive(path)
		loading_thread = Thread.new()
		#warning-ignore:return_value_discarded
		loading_thread.start(self, "interactive_load", res_loader)


func _on_settings_pressed():
	$ui/main.hide()
	$ui/settings.show()
	$ui/settings/actions/cancel.grab_focus()
	
	if settings.gi_quality == settings.GIQuality.HIGH:
		$ui/settings/gi/gi_high.pressed = true
	elif settings.gi_quality == settings.GIQuality.LOW:
		$ui/settings/gi/gi_low.pressed = true
	elif settings.gi_quality == settings.GIQuality.DISABLED:
		$ui/settings/gi/gi_disabled.pressed = true

	if settings.aa_quality == settings.AAQuality.AA_8X:
		$ui/settings/aa/aa_8x.pressed = true
	elif settings.aa_quality == settings.AAQuality.AA_4X:
		$ui/settings/aa/aa_4x.pressed = true
	elif settings.aa_quality == settings.AAQuality.AA_2X:
		$ui/settings/aa/aa_2x.pressed = true
	elif settings.aa_quality == settings.AAQuality.DISABLED:
		$ui/settings/aa/aa_disabled.pressed = true

	if settings.ssao_quality == settings.SSAOQuality.HIGH:
		$ui/settings/ssao/ssao_high.pressed = true
	elif settings.ssao_quality == settings.SSAOQuality.LOW:
		$ui/settings/ssao/ssao_low.pressed = true
	elif settings.ssao_quality == settings.SSAOQuality.DISABLED:
		$ui/settings/ssao/ssao_disabled.pressed = true
		
	if settings.resolution == settings.Resolution.NATIVE:
		$ui/settings/resolution/resolution_native.pressed = true
	elif settings.resolution == settings.Resolution.RES_1080:
		$ui/settings/resolution/resolution_1080.pressed = true
	elif settings.resolution == settings.Resolution.RES_720:
		$ui/settings/resolution/resolution_720.pressed = true
	elif settings.resolution == settings.Resolution.RES_576:
		$ui/settings/resolution/resolution_576.pressed = true

	if settings.fullscreen:
		$ui/settings/fullscreen/fullscreen_yes.pressed = true
	else:
		$ui/settings/fullscreen/fullscreen_no.pressed = true


func _on_quit_pressed():
	get_tree().quit()


func _on_apply_pressed():
	$ui/main.show()
	$ui/main/play.grab_focus()
	$ui/settings.hide()
	
	if $ui/settings/gi/gi_high.pressed:
		settings.gi_quality = settings.GIQuality.HIGH
	elif $ui/settings/gi/gi_low.pressed:
		settings.gi_quality = settings.GIQuality.LOW
	elif $ui/settings/gi/gi_disabled.pressed:
		settings.gi_quality = settings.GIQuality.DISABLED
	
	if $ui/settings/aa/aa_8x.pressed:
		settings.aa_quality = settings.AAQuality.AA_8X
	elif $ui/settings/aa/aa_4x.pressed:
		settings.aa_quality = settings.AAQuality.AA_4X
	elif $ui/settings/aa/aa_2x.pressed:
		settings.aa_quality = settings.AAQuality.AA_2X
	elif $ui/settings/aa/aa_disabled.pressed:
		settings.aa_quality = settings.AAQuality.DISABLED
	
	if $ui/settings/ssao/ssao_high.pressed:
		settings.ssao_quality = settings.SSAOQuality.HIGH
	elif $ui/settings/ssao/ssao_low.pressed:
		settings.ssao_quality = settings.SSAOQuality.LOW
	elif $ui/settings/ssao/ssao_disabled.pressed:
		settings.ssao_quality = settings.SSAOQuality.DISABLED
	
	if $ui/settings/resolution/resolution_native.pressed:
		settings.resolution = settings.Resolution.NATIVE
	elif $ui/settings/resolution/resolution_1080.pressed:
		settings.resolution = settings.Resolution.RES_1080
	elif $ui/settings/resolution/resolution_720.pressed:
		settings.resolution = settings.Resolution.RES_720
	elif $ui/settings/resolution/resolution_576.pressed:
		settings.resolution = settings.Resolution.RES_576

	settings.fullscreen = $ui/settings/fullscreen/fullscreen_yes.pressed
	
	# Apply the setting directly
	OS.window_fullscreen = settings.fullscreen

	settings.save_settings()


func _on_cancel_pressed():
	$ui/main.show()
	$ui/main/play.grab_focus()
	$ui/settings.hide()
