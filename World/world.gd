extends Node2D

# Loads in background music upon game being run
@onready var backgroundMusic = $BackgroundMusic

# Loops the background music, connected via. signal to finished()
func _on_background_music_finished():
	backgroundMusic.play()
	# Randomizes seed
	randomize()
