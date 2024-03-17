extends CharacterBody2D

const EnemyDeathEffect = preload("res://Effects/enemy_death_effect.tscn")
const HitEffect = preload("res://Effects/hit_effect.tscn")
const SEPARATION = 400
const KNOCKBACK = 140
# Movement variables are export to change individual bats
@export var ACCELERATION = 400
@export var MAX_SPEED = 50
@export var FRICTION = 40

enum {
	IDLE,
	WANDER,
	CHASE
}

@onready var sprite = $Sprite2D
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var hurtbox = $Hurtbox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer

var state = CHASE
var enemyGlobalStats = EnemyGlobalStats

func _ready():
	var positions = [[-176, -48], [-256, 208], [-112, 80], 
	[80, -40], [80, -144], [176, 208], [344, 128], [-96, 208]]
	var index = randi_range(0, 7)
	position.x = positions[index][0]
	position.y = positions[index][1]
	sprite.play("Fly")
	state = pick_random_state([IDLE, WANDER])
	randomize() # Remove to have fixed seed

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				reset_state_and_timer()
		
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0 or \
					global_position.distance_to(wanderController.target_position) <= MAX_SPEED/5:
				reset_state_and_timer()
			accelerate_to(wanderController.target_position, delta)
			check_sprite_direction()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_to(player.global_position, delta)
			else:
				state = IDLE
			check_sprite_direction()

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * SEPARATION
	move_and_slide()

func accelerate_to(position, delta):
	var direction = global_position.direction_to(position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

func check_sprite_direction():
	sprite.flip_h = velocity.x < 0

func reset_state_and_timer():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(randf_range(1, 3))

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	velocity = area.knockback_vector * KNOCKBACK
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position
	enemyGlobalStats.enemy_died()

func _on_hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
