class_name Player

extends CharacterBody2D

signal player_exit_screen

# Player Movement
const JUMP_VELOCITY: float = -800.0
const FALL_VELOCITY_MULTIPLIER: float = 1.5
const MAX_ROTATION: float = 35
const TILT_SPEED: float = 100

# Animations
const FLY_ANIMATION: String = "fly"

# Input
const FLY_INPUT: String = "ui_accept"

# Nodes
@onready var animations_sprites: AnimatedSprite2D = $AnimationsSprites
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var jump_audio: AudioStreamPlayer2D = $JumpAudio
@onready var lose_audio: AudioStreamPlayer2D =$LoseAudio

var is_dead: bool = false

func _ready() -> void:
	set_physics_process(false)
	animations_sprites.animation_finished.connect(_on_animation_finished)
	if global_position.y > viewport_size.y:
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * FALL_VELOCITY_MULTIPLIER
	
	# Handle tilting
	if velocity.y <= 0:
		rotation = lerp(rotation, deg_to_rad(-MAX_ROTATION), delta * 20)
	else:
		rotation = lerp(rotation, deg_to_rad(MAX_ROTATION), delta * 2)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	# Handle Fly
	if (event is InputEventScreenTouch and event.is_pressed() or event.is_action_pressed(FLY_INPUT)) and not is_dead:
		velocity.y = JUMP_VELOCITY
		jump_audio.play()
		animations_sprites.show()
		animations_sprites.stop()
		animations_sprites.play(FLY_ANIMATION)

func start() -> void:
	is_dead = false
	jump_audio.play()
	velocity.y = JUMP_VELOCITY
	set_physics_process(true)

func die() -> void:
	is_dead = true
	
	# Disable physics processing
	set_physics_process(false)
	
	# Reset velocity
	velocity = Vector2.ZERO
	
	# Create and start a timer
	var timer: SceneTreeTimer = get_tree().create_timer(0.5)
	timer.timeout.connect(_on_death_timer_timeout)

func _on_death_timer_timeout() -> void:
	lose_audio.play()
	set_physics_process(true)
 
func _on_animation_finished() -> void:
	animations_sprites.hide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not is_dead:
		player_exit_screen.emit()
