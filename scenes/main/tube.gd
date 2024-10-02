class_name Tube

extends Area2D

signal hit

func _on_body_entered(body: Node2D) -> void:
	var collision_point: Vector2 = get_collision_point(body)
	hit.emit(collision_point)

func get_collision_point(body: Node2D) -> Vector2:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, body.global_position)
	var result: Dictionary = space_state.intersect_ray(query)
	return result.get("position")
