extends Node2D

@export var initial_enemies = 8
@onready var num_enemies = initial_enemies

signal no_enemies

func enemy_died():
	num_enemies -= 1
	if num_enemies <= 0:
		emit_signal("no_enemies")

func set_num_enemies(new_num_enemies):
	num_enemies = new_num_enemies
