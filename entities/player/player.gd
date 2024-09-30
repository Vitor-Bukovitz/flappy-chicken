class_name Player

extends CharacterBody2D

const JUMP_VELOCITY: float = -800.0
const FALL_VELOCITY_MULTIPLIER: float = 1.5
const MAX_ROTATION: float = 35
const TILT_SPEED: float = 100

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * FALL_VELOCITY_MULTIPLIER

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
	
	# Handle tilting
	if velocity.y <= 0:
		rotation = lerp(rotation, deg_to_rad(-MAX_ROTATION), delta * 20)
	else:
		rotation = lerp(rotation, deg_to_rad(MAX_ROTATION), delta * 2)
	
	move_and_slide()

func die() -> void:
	# Disable physics processing
	set_physics_process(false)
	
	# Reset velocity
	velocity = Vector2.ZERO
	
	# Create and start a timer
	var timer: SceneTreeTimer = get_tree().create_timer(0.5)
	timer.timeout.connect(_on_death_timer_timeout)

func _on_death_timer_timeout() -> void:
	set_physics_process(true)
