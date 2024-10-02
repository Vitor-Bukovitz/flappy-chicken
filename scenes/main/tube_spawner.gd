class_name TubeSpawner

extends Node2D

signal hit_tube
signal pass_tube

const TUBES_SPEED = 360
const MAX_TUBES: int = 5
const TUBE_SPAWN_DISTANCE: float = 200.0
const TUBE_VERTICAL_RANGE: float = 300.0

@onready var tubes: Node2D = $Tubes
@onready var timer: Timer = $Timer
@onready var viewport_size: Vector2 = tubes.get_viewport_rect().size

var tube_scene: PackedScene = preload("res://scenes/main/tube.tscn")

func _physics_process(delta: float) -> void:
	for child: Node in tubes.get_children():
		child.position.x -= (TUBES_SPEED * delta)

func _on_timer_timeout() -> void:
	var new_tube: Tube
	
	if tubes.get_child_count() >= MAX_TUBES:
		new_tube = tubes.get_child(0)
		tubes.move_child(new_tube, -1)
	else:
		new_tube = tube_scene.instantiate()
		new_tube.hit.connect(_on_hit_tube)
		tubes.add_child(new_tube)
	
	new_tube.position = Vector2(
		viewport_size.x + TUBE_SPAWN_DISTANCE,
		(viewport_size.y / 2) + randf_range(-TUBE_VERTICAL_RANGE, TUBE_VERTICAL_RANGE)
	)
	
	if tubes.get_child_count() >= 2:
		pass_tube.emit()

func _on_hit_tube(collision_point: Vector2) -> void:
	hit_tube.emit(collision_point)

func reset() -> void:
	timer.start()
	for child: Node in tubes.get_children():
		child.queue_free()
