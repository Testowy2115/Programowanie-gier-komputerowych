extends Node3D

@export var camera_target: Camera3D
@export var lag_speed := 7.0

func _process(delta: float) -> void:
	if camera_target:
		global_position = global_position.lerp(camera_target.global_position, lag_speed * delta)
