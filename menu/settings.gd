extends Node

enum GIQuality {
	DISABLED = 0
	LOW = 1
	HIGH = 2
}

enum AAQuality {
	DISABLED = 0
	AA_2X = 1
	AA_4X = 2
	AA_8X = 3
}

enum SSAOQuality {
	DISABLED = 0
	LOW = 1
	HIGH = 2
}

enum Resolution {
	RES_576 = 0
	RES_720 = 1
	RES_1080 = 2
	NATIVE = 3
}

var gi_quality = GIQuality.LOW
var aa_quality = AAQuality.AA_2X
var ssao_quality = SSAOQuality.DISABLED
var resolution = Resolution.NATIVE

func _ready():
	load_settings()


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
	
	if "ssao" in d:
		ssao_quality = int(d.ssao)
	
	if "resolution" in d:
		resolution = int(d.resolution)


func save_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.WRITE)
	assert(not error)
	
	var d = { "gi":gi_quality, "aa":aa_quality, "ssao":ssao_quality, "resolution":resolution }
	f.store_line(to_json(d))
