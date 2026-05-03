extends Node3D

@export var speed: float = 30.0
@export var lifetime: float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.z -= speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	pass
