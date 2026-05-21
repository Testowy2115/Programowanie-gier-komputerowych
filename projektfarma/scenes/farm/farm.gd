extends Node2D

var max_flowers_on_map = 15

func _ready() -> void:
		var grass_bg = ColorRect.new()
		grass_bg.color = Color(0.3, 0.6, 0.3)
		grass_bg.size = Vector2(800, 800)
		grass_bg.position = Vector2(-400, -400)
		grass_bg.z_index = -1
		add_child(grass_bg)

		# Granice mapy
		create_border(Vector2(0, -400), Vector2(800, 50)) 
		create_border(Vector2(0, 400), Vector2(800, 50)) 
		create_border(Vector2(-400, 0), Vector2(50, 800))
		create_border(Vector2(400, 0), Vector2(50, 800))
		
		spawn_flowers(10)
		
		var spawn_timer = Timer.new()
		spawn_timer.wait_time = 3.0
		spawn_timer.autostart = true
		spawn_timer.timeout.connect(_on_flower_spawn_timeout)
		add_child(spawn_timer)

func _on_flower_spawn_timeout() -> void:
	if get_tree().get_nodes_in_group("flowers").size() < max_flowers_on_map:
		spawn_flowers(1)

func create_border(pos: Vector2, rect_size: Vector2) -> void:
		var wall = StaticBody2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()

		shape.size = rect_size
		collision.shape = shape
		wall.position = pos

		wall.add_child(collision)
		add_child(wall)

func spawn_flowers(amount: int):
	var flower_script = load("res://scenes/farm/flower.gd")
	if flower_script == null:
		return
		
	for i in range(amount):
		var flower = Area2D.new()
		flower.set_script(flower_script)
		flower.position = Vector2(randf_range(-300, 300), randf_range(-300, 300))
		add_child(flower)
