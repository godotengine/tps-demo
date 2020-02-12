extends Spatial

var res_loader : ResourceInteractiveLoader = null
var loading_thread : Thread = null

func _ready():
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
	#warning-ignore:return_value_discarded
	get_tree().change_scene_to(loader.get_resource())


func _on_loading_done_timer_timeout():
	call_deferred("loading_done", res_loader)


func _on_play_pressed():
	$ui/main.hide()
	$ui/loading.show()
	res_loader = ResourceLoader.load_interactive("res://level/level.tscn")
	loading_thread = Thread.new()
	#warning-ignore:return_value_discarded
	loading_thread.start(self, "interactive_load", res_loader)


func _on_settings_pressed():
	$ui/main.hide()
	$ui/settings.show()
	$ui/settings/cancel.grab_focus()
	
	if settings.gi_quality == settings.GIQuality.HIGH:
		$ui/settings/gi_high.pressed=true
	elif settings.gi_quality == settings.GIQuality.LOW:
		$ui/settings/gi_low.pressed=true
	elif settings.gi_quality == settings.GIQuality.DISABLED:
		$ui/settings/gi_disabled.pressed=true

	if settings.aa_quality == settings.AAQuality.AA_8X:
		$ui/settings/aa_8x.pressed=true
	elif settings.aa_quality == settings.AAQuality.AA_4X:
		$ui/settings/aa_4x.pressed=true
	elif settings.aa_quality == settings.AAQuality.AA_2X:
		$ui/settings/aa_2x.pressed=true
	elif settings.aa_quality == settings.AAQuality.AA_DISABLED:
		$ui/settings/aa_disabled.pressed=true

	if settings.ssao_quality == settings.SSAOQuality.HIGH:
		$ui/settings/ssao_high.pressed=true
	elif settings.ssao_quality == settings.SSAOQuality.LOW:
		$ui/settings/ssao_low.pressed=true
	elif settings.ssao_quality == settings.SSAOQuality.DISABLED:
		$ui/settings/ssao_disabled.pressed=true
		
	if settings.resolution == settings.Resolution.NATIVE:
		$ui/settings/resolution_native.pressed = true
	elif settings.resolution == settings.Resolution.RES_1080:
		$ui/settings/resolution_1080.pressed = true
	elif settings.resolution == settings.Resolution.RES_720:
		$ui/settings/resolution_720.pressed = true
	elif settings.resolution == settings.Resolution.RES_576:
		$ui/settings/resolution_576.pressed = true


func _on_quit_pressed():
	get_tree().quit()


func _on_apply_pressed():
	$ui/main.show()
	$ui/main/play.grab_focus()
	$ui/settings.hide()
	
	if $ui/settings/gi_high.pressed:
		settings.gi_quality = settings.GIQuality.HIGH
	elif $ui/settings/gi_low.pressed:
		settings.gi_quality = settings.GIQuality.LOW
	elif $ui/settings/gi_disabled.pressed:
		settings.gi_quality = settings.GIQuality.DISABLED
	
	if $ui/settings/aa_8x.pressed:
		settings.aa_quality = settings.AAQuality.AA_8X
	elif $ui/settings/aa_4x.pressed:
		settings.aa_quality = settings.AAQuality.AA_4X
	elif $ui/settings/aa_2x.pressed:
		settings.aa_quality = settings.AAQuality.AA_2X
	elif $ui/settings/aa_disabled.pressed:
		settings.aa_quality = settings.AAQuality.AA_DISABLED
	
	if $ui/settings/ssao_high.pressed:
		settings.ssao_quality = settings.SSAOQuality.HIGH
	elif $ui/settings/ssao_low.pressed:
		settings.ssao_quality = settings.SSAOQuality.LOW
	elif $ui/settings/ssao_disabled.pressed:
		settings.ssao_quality = settings.SSAOQuality.DISABLED
	
	if $ui/settings/resolution_native.pressed:
		settings.resolution = settings.Resolution.NATIVE
	elif $ui/settings/resolution_1080.pressed:
		settings.resolution = settings.Resolution.RES_1080
	elif $ui/settings/resolution_720.pressed:
		settings.resolution = settings.Resolution.RES_720
	elif $ui/settings/resolution_576.pressed:
		settings.resolution = settings.Resolution.RES_576
	
	settings.save_settings()


func _on_cancel_pressed():
	$ui/main.show()
	$ui/main/play.grab_focus()
	$ui/settings.hide()
