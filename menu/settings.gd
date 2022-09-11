extends Node

enum GIQuality {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

enum AAQuality {
	DISABLED = 0,
	AA_2X = 1,
	AA_4X = 2,
	AA_8X = 3,
}

enum SSAOQuality {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

enum BloomQuality {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

enum Resolution {
	RES_540 = 0,
	RES_720 = 1,
	RES_1080 = 2,
	NATIVE = 3,
}

var gi_quality = GIQuality.LOW
var aa_quality = AAQuality.AA_2X
var shadow_enabled = true
var fxaa = true
var ssao_quality = SSAOQuality.DISABLED
var bloom_quality = BloomQuality.HIGH
var resolution = Resolution.NATIVE
var fullscreen = true

func _ready():
	load_settings()


func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		get_tree().set_input_as_handled()


func load_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.READ)
	if error:
		print("There are no settings to load.")
		return

	var d = parse_json(f.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return

	if "gi" in d:
		gi_quality = int(d.gi)

	if "aa" in d:
		aa_quality = int(d.aa)

	if "shadow_enabled" in d:
		shadow_enabled = bool(d.shadow_enabled)

	if "fxaa" in d:
		fxaa = bool(d.fxaa)

	if "ssao" in d:
		ssao_quality = int(d.ssao)

	if "bloom" in d:
		bloom_quality = int(d.bloom)

	if "resolution" in d:
		resolution = int(d.resolution)

	if "fullscreen" in d:
		fullscreen = bool(d.fullscreen)


func save_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.WRITE)
	assert(not error)

	var d = { "gi":gi_quality, "aa":aa_quality, "shadow_enabled":shadow_enabled, "fxaa":fxaa, "ssao":ssao_quality, "bloom":bloom_quality, "resolution":resolution, "fullscreen":fullscreen }
	f.store_line(to_json(d))
