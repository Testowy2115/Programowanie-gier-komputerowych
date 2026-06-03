extends Node3D

@export var speed: float = 30.0
@export var lifetime: float = 3.0
@export var direction: Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
