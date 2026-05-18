extends Node2D

func _ready() -> void:
	var grass_bg = ColorRect.new()
	grass_bg.color = Color(0.3, 0.6, 0.3)
	grass_bg.size = Vector2(2000, 2000)
	grass_bg.position = Vector2(-1000, -1000)
	grass_bg.z_index = -1 # Żeby było pod graczem
	add_child(grass_bg)
	
	# Granice mapy
	create_border(Vector2(0, -900), Vector2(2000, 50)) 
	create_border(Vector2(0, 900), Vector2(2000, 50)) 
	create_border(Vector2(-900, 0), Vector2(50, 2000))
	create_border(Vector2(900, 0), Vector2(50, 2000))

func create_border(pos: Vector2, rect_size: Vector2) -> void:
	var wall = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	shape.size = rect_size
	collision.shape = shape
	wall.position = pos
	
	wall.add_child(collision)
	add_child(wall)
