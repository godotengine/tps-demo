extends Camera3D

# Constant values of the effect.
const SPEED: float = 1.0
const DECAY_RATE: float = 1.5
const MAX_YAW: float = 0.05
const MAX_PITCH: float = 0.05
const MAX_ROLL: float = 0.1
const MAX_TRAUMA: float = 1.2

# Default values.
var start_rotation: Vector3 = rotation
var trauma: float = 0.0
var time: float = 0.0
var noise := FastNoiseLite.new()
var noise_seed: int = randi()


func _ready() -> void:
	noise.seed = noise_seed
	noise.fractal_octaves = 1
	noise.fractal_lacunarity = 1.0

	# This variable is reset if the camera position is changed by other scripts,
	# such as when zooming in/out or focusing checked a different position.
	# This should NOT be done when the camera shake is happening.
	start_rotation = rotation


func _process(delta: float) -> void:
	if trauma > 0.0:
		decay_trauma(delta)
		apply_shake(delta)


# Add trauma to start/continue the shake.
func add_trauma(amount: float) -> void:
	trauma = minf(trauma + amount, MAX_TRAUMA)


# Decay the trauma effect over time.
func decay_trauma(delta: float) -> void:
	var change: float = DECAY_RATE * delta
	trauma = maxf(trauma - change, 0.0)


# Apply the random shake accoring to delta time.
func apply_shake(delta: float) -> void:
	# Using a magic number here to get a pleasing effect at SPEED 1.0.
	time += delta * SPEED * 5000.0
	var shake: float = trauma * trauma
	var yaw: float = MAX_YAW * shake * get_noise_value(noise_seed, time)
	var pitch: float = MAX_PITCH * shake * get_noise_value(noise_seed + 1, time)
	var roll: float = MAX_ROLL * shake * get_noise_value(noise_seed + 2, time)
	rotation = start_rotation + Vector3(pitch, yaw, roll)


# Return a random float in range(-1, 1) using OpenSimplex noise.
func get_noise_value(seed_value: int, pos: float) -> float:
	noise.seed = seed_value
	return noise.get_noise_1d(pos)
