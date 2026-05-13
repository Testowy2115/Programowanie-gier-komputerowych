extends Node3D

@export var camera_target: Camera3D
@export var lag_speed := 7.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if camera_target:
		global_position = global_position.lerp(camera_target.global_position, lag_speed * delta)
