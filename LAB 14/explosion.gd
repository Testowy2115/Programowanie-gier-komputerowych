extends Node3D

const CLEANUP_DELAY := 0.8

func _ready() -> void:
	await get_tree().create_timer(CLEANUP_DELAY).timeout
	queue_free()
