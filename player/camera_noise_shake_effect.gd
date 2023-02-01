extends Camera3D

# Constant values of the effect.
const SPEED = 1.0
const DECAY_RATE = 1.5
const MAX_YAW = 0.05
const MAX_PITCH = 0.05
const MAX_ROLL = 0.1
const MAX_TRAUMA = 1.2

# Default values.
var start_rotation = rotation
var trauma = 0.0
var time = 0.0
var noise = FastNoiseLite.new()
var noise_seed = randi()


func _ready():
	noise.seed = noise_seed
	noise.fractal_octaves = 1
	noise.fractal_lacunarity = 1.0

	# This variable is reset if the camera position is changed by other scripts,
	# such as when zooming in/out or focusing checked a different position.
	# This should NOT be done when the camera shake is happening.
	start_rotation = rotation


func _process(delta):
	if trauma > 0.0:
		decay_trauma(delta)
		apply_shake(delta)


# Add trauma to start/continue the shake.
func add_trauma(amount):
	trauma = min(trauma + amount, MAX_TRAUMA)


# Decay the trauma effect over time.
func decay_trauma(delta):
	var change = DECAY_RATE * delta
	trauma = max(trauma - change, 0.0)


# Apply the random shake accoring to delta time.
func apply_shake(delta):
	# Using a magic number here to get a pleasing effect at SPEED 1.0.
	time += delta * SPEED * 5000.0
	var shake = trauma * trauma
	var yaw = MAX_YAW * shake * get_noise_value(noise_seed, time)
	var pitch = MAX_PITCH * shake * get_noise_value(noise_seed + 1, time)
	var roll = MAX_ROLL * shake * get_noise_value(noise_seed + 2, time)
	rotation = start_rotation + Vector3(pitch, yaw, roll)


# Return a random float in range(-1, 1) using OpenSimplex noise.
func get_noise_value(seed_value, t):
	noise.seed = seed_value
	return noise.get_noise_1d(t)
