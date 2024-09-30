class_name Main

extends Node

@onready var score_label: Label = $Container/MarginContainer/Label

@onready var player: Player = $Player
@onready var tube_spawner: Node2D = $TubeSpawner
@onready var background: Node2D = $Background

var score: int = 0

func _on_tube_spawner_hit_tube() ->  void:
	_pause_game.call_deferred()

func _pause_game() -> void:
	background.process_mode = Node.PROCESS_MODE_DISABLED
	tube_spawner.process_mode = Node.PROCESS_MODE_DISABLED
	player.die()

func _on_tube_spawner_pass_tube() -> void:
	score +=1
	score_label.text = str(score)
