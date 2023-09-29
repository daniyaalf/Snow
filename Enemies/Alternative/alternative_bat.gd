extends "res://Enemies/enemy.gd"

# Set movement properties as export variables

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

func _ready():
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
			adjust_sprite_direction()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_to(player.global_position, delta)
			else:
				state = IDLE
			adjust_sprite_direction()

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * SEPARATION
	move_and_slide()

func reset_state_and_timer():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(randf_range(1, 3))

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
