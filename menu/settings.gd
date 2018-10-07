extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const GI_QUALITY_HIGH = 2	
const GI_QUALITY_LOW = 1	
const GI_QUALITY_DISABLED = 0

const AA_8X = 3
const AA_4X = 2
const AA_2X = 1
const AA_DISABLED = 0

const SSAO_QUALITY_HIGH = 2	
const SSAO_QUALITY_LOW = 1	
const SSAO_QUALITY_DISABLED = 0

const RESOLUTION_NATIVE = 3
const RESOLUTION_1080 = 2
const RESOLUTION_720 = 1
const RESOLUTION_576 = 0

var gi_quality = GI_QUALITY_LOW
var aa_quality = AA_2X
var ssao_quality = SSAO_QUALITY_DISABLED
var resolution = RESOLUTION_NATIVE

func load_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.READ)
	if (error):
		print("no settings to load..")
		return
	var d = parse_json( f.get_as_text() )
	if (typeof(d)!=TYPE_DICTIONARY):
		return
	if ("gi" in d):	
		gi_quality = int(d.gi)
		
	if ("aa" in d):	
		aa_quality = int(d.aa)
		
	if ("ssao" in d):
		ssao_quality = int(d.ssao)

	if ("resolution" in d):
		resolution = int(d.resolution)
	
func save_settings():
	
	var f = File.new()
	var error = f.open("user://settings.json", File.WRITE)
	assert( not error )
	
	var d = { "gi":gi_quality, "aa":aa_quality, "ssao":ssao_quality, "resolution":resolution }
	f.store_line( to_json(d) )


	
func _ready():
	load_settings()


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
