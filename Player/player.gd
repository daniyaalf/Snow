extends CharacterBody2D

# ORGANIZATION OF CODE:
# 1a. Constants
# 1b. Export Vars (subject to switch with 1a)
# 2. Enum
# 3. Onready vars
# 4. Other vars
# 5. Unique Functions
# 6. Signal Functions

# Player Hurt Sound
const PlayerHurtSound = preload("res://Player/player_hurt_sound.tscn")

# Physics constants
const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500
const ROLL_SPEED = 110

# Other constants
const invincibility_duration = 0.6 # Export later?

# The Player's behavioural states
enum {
	MOVE,
	ROLL,
	ATTACK
}

# Accessing nodes of the Player, see Scene tree
@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get('parameters/playback')
@onready var swordHitbox = $HitboxPivot/SwordHitbox
@onready var hurtbox = $Hurtbox
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer
# @onready var timer = $TimePanel

# NOTE: velocity is a built-in variable; Vector2.ZERO by default

# DEFAULT SETTINGS
var state = MOVE
var roll_vector = Vector2.LEFT
var stats = PlayerStats

# Upon game being run, these will always hold true
func _ready():
	# Remove the player from the world if they have no health
	stats.connect("no_health", queue_free)
	# Run the animation tree (allows player to move)
	animationTree.active = true
	# (SUBJECT TO CHANGE):
	# at default, the player is facing left and thus their roll direction and sword
	# hitbox direction are fixed to go left on start, although any movement from the player
	# and this no longer really matters because the hitbox directions will change correctly
	swordHitbox.knockback_vector = roll_vector

# Controls behaviour of player
func _physics_process(delta):
	# Matches each value of the variable 'state' to the function dictating player behaviour
	match state:
		MOVE:
			move_state(delta)
		
		ROLL:
			roll_state(delta)
		
		ATTACK:
			attack_state(delta)
	
# For player's move state (moving or standing still, just not rolling or attacking)
func move_state(delta):
	var input_vector = Vector2.ZERO
	# This does exactly what it looks like
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Normalize the direction vector
	input_vector = input_vector.normalized()
	# If the player isn't still then update these things
	if input_vector != Vector2.ZERO:
		# You roll in the direction you're moving in
		roll_vector = input_vector
		# You swipe your sword in the direction you're moving in
		swordHitbox.knockback_vector = input_vector
		# These animation blend vectors ensure that the player animations transition between each
		# other properly, all blend positions are set to (0, 0)
		animationTree.set('parameters/Idle/blend_position', input_vector)
		animationTree.set('parameters/Run/blend_position', input_vector)
		animationTree.set('parameters/Attack/blend_position', input_vector)
		animationTree.set('parameters/Roll/blend_position', input_vector)
		# If the player is moving their animationState is Run (see animationTree Node)
		animationState.travel('Run')
		# Move towards player MAX_SPEED using ACCELERATION
		# Multiplying by delta ensures that the position is updated in each frame,
		# it is necessary for smooth movement but means we must make the constants larger numbers
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		# If the player's standing still then their animation is obviously idle
		animationState.travel('Idle')
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	# this function just updates the player's position
	move_and_slide()
	
	# If you press roll (the roll button and attack button are configured in project settings)
	# then the player's state is set to roll; same line of reasoning for attack below
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(delta):
	animationState.travel("Roll")
	# You get iframes in the roll for 0.6 sec
	hurtbox.start_invincibility(invincibility_duration)
	velocity = velocity.move_toward(roll_vector * ROLL_SPEED, ACCELERATION * delta)
	move_and_slide()

func attack_state(delta):
	animationState.travel('Attack')
	# Added a bit of a slide to the attack so you don't fully stop moving, subject to modification
	velocity = velocity.move_toward(Vector2.ZERO, (FRICTION/5) * delta)
	move_and_slide()

# After the player rolls their speed decreases to a quarter of what it was before
# This is used in the AnimationPlayer
func roll_animation_finished():
	velocity = velocity / 4
	state = MOVE

# Also used in the AnimationPlayer
func attack_animation_finished():
	state = MOVE

# When the hurtbox area is entered by something that is allowed to collide with it (like enemies)
func _on_hurtbox_area_entered(area):
	# Takes whatever damage the *area entering the hurtbox* is dealing
	stats.health -= area.damage
	# iframes
	hurtbox.start_invincibility(invincibility_duration)
	# hit effect
	hurtbox.create_hit_effect()
	# sound of player getting hurt
	var playerHurtSound = PlayerHurtSound.instantiate()
	get_tree().current_scene.add_child(playerHurtSound)

# Blinking animation upon getting hit (uses a Shader, see Sprite node in Player)
func _on_hurtbox_invincibility_started():
	if state != ROLL:
		blinkAnimationPlayer.play("Start")

func _on_hurtbox_invincibility_ended():
	if state != ROLL:
		blinkAnimationPlayer.play("Stop")
