extends Node2D

# Loads in background music upon game being run
@onready var backgroundMusic = $BackgroundMusic
@onready var player = $Player
@onready var gameOver = $"CanvasLayer/Game Over"
var stats = PlayerStats
var enemyGlobalStats = EnemyGlobalStats

func _ready():
	pass

func game_over():
	gameOver.set_visible(true)

# Loops the background music, connected via. signal to finished()
func _on_background_music_finished():
	backgroundMusic.play()
	# Randomizes seed
	randomize()

func _on_restart_pressed():
	get_tree().reload_current_scene()
	stats.set_health(stats.max_health)
	enemyGlobalStats.set_num_enemies(enemyGlobalStats.initial_enemies)
