class_name Main

extends Node

# Animations
const HIT_ANIMATION: String = "hit"
const END_ANIMATION: String = "end"

# Save
const SAVE_FILE: String = "user://savegame.dat"

# Labels
@onready var start_label: Label = $Container/BottomMarginContainer/StartLabel
@onready var game_name_label: Label = $Container/CenterMarginContainer/GameNameLabel
@onready var score_label: Label = $Container/ScoreMarginContainer/VBoxContainer/ScoreLabel
@onready var highest_score_label: Label = $Container/ScoreMarginContainer/VBoxContainer/HighestScoreLabel

# Animations
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# SFX
@onready var hit_audio: AudioStreamPlayer2D = $HitAudio
@onready var score_audio: AudioStreamPlayer2D = $ScoreAudio

# Main Nodes
@onready var player: Player = $Player
@onready var tube_spawner: TubeSpawner = $TubeSpawner

# Secondary Nodes
@onready var background: Node2D = $Background
@onready var trees: Parallax2D = $Background/ParallaxTrees

# Variables
var score: int = 0
var highest_score: int = 0
var can_start_game: bool = true

func _ready() -> void:
	trees.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	_retrieve_saved_game()

func _input(event: InputEvent) -> void:
	# Handle Start Game
	if event is InputEventScreenTouch and event.is_pressed() or event.is_action_pressed("ui_accept"):
		_start_game()

func _start_game() -> void:
	if not can_start_game:
		return
	can_start_game = false
	
	# Score / Labels
	score = 0
	score_label.text = ""
	start_label.hide()
	game_name_label.hide()
	
	# Animations
	animation_player.stop()
	
	# Tube Spawner
	tube_spawner.reset()
	
	# Player
	player.position = Vector2(430, 1080)
	player.start()
	
	# Physics and Process
	trees.process_mode = Node.PROCESS_MODE_INHERIT
	background.process_mode = Node.PROCESS_MODE_INHERIT
	tube_spawner.process_mode = Node.PROCESS_MODE_INHERIT

func _pause_game() -> void:
	background.process_mode = Node.PROCESS_MODE_DISABLED
	tube_spawner.process_mode = Node.PROCESS_MODE_DISABLED

func _end_game() -> void:
	_pause_game.call_deferred()
	animation_player.play(END_ANIMATION)
	player.die()
	_save_game()

func _enable_start_game() -> void:
	can_start_game = true

func _save_game() -> void:
	if highest_score < score:
		highest_score_label.text = "Highest Score: " + str(score)
		var save_file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
		save_file.store_string(str(score))

func _retrieve_saved_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return
	var save_file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.READ)
	highest_score = int(save_file.get_as_text())
	highest_score_label.text = "Highest Score: " + str(highest_score)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == END_ANIMATION:
		_enable_start_game()

func _on_animation_finished() -> void:
	animated_sprite.hide()

func _on_tube_spawner_pass_tube() -> void:
	score_audio.play()
	score +=1
	score_label.text = str(score)

func _on_tube_spawner_hit_tube(collision_point: Vector2) -> void:
	hit_audio.play()
	animated_sprite.show()
	animated_sprite.play(HIT_ANIMATION)
	animated_sprite.global_position = collision_point
	_end_game()

func _on_player_player_exit_screen() -> void:
	hit_audio.play()
	_end_game()
