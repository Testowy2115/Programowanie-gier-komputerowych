extends Node3D

var score: int = 0
var bestscore: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.area_entered.connect(_on_hit)
	pass # Replace with function body.

func _on_hit(_area: Area3D):
	print("Postrzelony kloc!")
	
	var main_node = get_tree().current_scene
	if main_node.has_method("add_score"):
		main_node.add_score(1)
	
	queue_free()
