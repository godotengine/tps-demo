extends Node

var fade_in_frame_counter = 60

func _ready():
	# We don't want the cache bullet to make noise. So just get rid of its audio.
	$Bullet/ExplosionAudio.queue_free()


func _physics_process(_delta):
	fade_in_frame_counter -= 1
	# Fade in progressively to hide artifacts.
	if fade_in_frame_counter == 50:
		# Hide after a few frames to be sure the shaders compiled.
		$Bullet.hide()
	if fade_in_frame_counter == 0:
		# This node has served its purpose, and now it's time to stop existing.
		self.queue_free()
