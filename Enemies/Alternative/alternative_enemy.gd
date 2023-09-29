extends CharacterBody2D

const EnemyDeathEffect = preload("res://Effects/enemy_death_effect.tscn")
const HitEffect = preload("res://Effects/hit_effect.tscn")

# Movement variables are export to change individual bats
@export var ACCELERATION = 400
@export var MAX_SPEED = 50
@export var FRICTION = 40
@export var SEPARATION = 400
@export var KNOCKBACK = 140
@export var invincibility_duration = 0.4

@onready var sprite = $Sprite2D
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var hurtbox = $Hurtbox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	pass

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# match state for movement types (see Bat for example)
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * SEPARATION
	move_and_slide()

func accelerate_to(pos, delta):
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

func adjust_sprite_direction():
	sprite.flip_h = velocity.x < 0

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	velocity = area.knockback_vector * KNOCKBACK
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(invincibility_duration)

func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position

func _on_hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
