extends Area2D

@export var HitEffect = preload("res://Effects/hit_effect.tscn")
@export var offset = Vector2.ZERO

@onready var timer = $Timer

var invincible = false : set = set_invincible, get = get_invincible

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func get_invincible():
	return invincible

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	if HitEffect != null:
		var effect = HitEffect.instantiate()
		var main = get_tree().current_scene
		main.add_child(effect)
		effect.global_position = global_position - offset

func _on_timer_timeout():
	self.invincible = false

func _on_invincibility_started():
	set_deferred("monitoring", false)

func _on_invincibility_ended():
	monitoring = true
