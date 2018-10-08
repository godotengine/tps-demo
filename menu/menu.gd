extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if (Input.is_action_just_pressed("quit")):
		if $ui/settings.visible:
			$ui/main.show()
			$ui/settings.hide()
		else:
			get_tree().quit()
			

func _on_play_pressed():
	$ui/main.hide()
	$ui/loading.show()
	$begin_load_timer.start()

func _on_settings_pressed():
	$ui/main.hide()
	$ui/settings.show()
	
	if (settings.gi_quality == settings.GI_QUALITY_HIGH):
		$ui/settings/gi_high.pressed=true
	elif (settings.gi_quality == settings.GI_QUALITY_LOW):
		$ui/settings/gi_low.pressed=true
	elif (settings.gi_quality == settings.GI_QUALITY_DISABLED):
		$ui/settings/gi_disabled.pressed=true

	if (settings.aa_quality == settings.AA_8X):
		$ui/settings/aa_8x.pressed=true
	elif (settings.aa_quality == settings.AA_4X):
		$ui/settings/aa_4x.pressed=true
	elif (settings.aa_quality == settings.AA_2X):
		$ui/settings/aa_2x.pressed=true
	elif (settings.aa_quality == settings.AA_DISABLED):
		$ui/settings/aa_disabled.pressed=true

	if (settings.ssao_quality == settings.SSAO_QUALITY_HIGH):
		$ui/settings/ssao_high.pressed=true
	elif (settings.ssao_quality == settings.SSAO_QUALITY_LOW):
		$ui/settings/ssao_low.pressed=true
	elif (settings.ssao_quality == settings.SSAO_QUALITY_DISABLED):
		$ui/settings/ssao_disabled.pressed=true
		
	if (settings.resolution == settings.RESOLUTION_NATIVE):
		$ui/settings/resolution_native.pressed = true
	elif (settings.resolution == settings.RESOLUTION_1080):
		$ui/settings/resolution_1080.pressed = true
	elif (settings.resolution == settings.RESOLUTION_720):
		$ui/settings/resolution_720.pressed = true
	elif (settings.resolution == settings.RESOLUTION_576):
		$ui/settings/resolution_576.pressed = true


func _on_apply_pressed():
	$ui/main.show()
	$ui/settings.hide()
	
	if($ui/settings/gi_high.pressed):
		settings.gi_quality = settings.GI_QUALITY_HIGH
	elif($ui/settings/gi_low.pressed):
		settings.gi_quality = settings.GI_QUALITY_LOW
	elif($ui/settings/gi_disabled.pressed):
		settings.gi_quality = settings.GI_QUALITY_DISABLED

	if($ui/settings/aa_8x.pressed):
		settings.aa_quality = settings.AA_8X
	elif($ui/settings/aa_4x.pressed):
		settings.aa_quality = settings.AA_4X
	elif($ui/settings/aa_2x.pressed):
		settings.aa_quality = settings.AA_2X
	elif($ui/settings/aa_disabled.pressed):
		settings.aa_quality = settings.AA_DISABLED

	if($ui/settings/ssao_high.pressed):
		settings.ssao_quality = settings.SSAO_QUALITY_HIGH
	elif($ui/settings/ssao_low.pressed):
		settings.ssao_quality = settings.SSAO_QUALITY_LOW
	elif($ui/settings/ssao_disabled.pressed):
		settings.ssao_quality = settings.SSAO_QUALITY_DISABLED

	if($ui/settings/resolution_native.pressed):
		settings.resolution = settings.RESOLUTION_NATIVE
	elif($ui/settings/resolution_1080.pressed):
		settings.resolution = settings.RESOLUTION_1080
	elif($ui/settings/resolution_720.pressed):
		settings.resolution = settings.RESOLUTION_720
	elif($ui/settings/resolution_576.pressed):
		settings.resolution = settings.RESOLUTION_576

	settings.save_settings()

func _on_cancel_pressed():
	$ui/main.show()
	$ui/settings.hide()


func _on_begin_load_timer_timeout():
	get_tree().change_scene("res://level/level.tscn")