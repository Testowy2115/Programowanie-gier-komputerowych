extends Node2D

var bee_data = {}
var player = null
var current_flower = null
var offset_from_player = Vector2.ZERO
var flower_offset = Vector2.ZERO
var flight_phase = 0.0

var speed = 150.0
var bob_time = 0.0
var bob_speed = 10.0
var bob_height = 8.0

var sprite = null
var base_position = Vector2.ZERO

func _ready():
	base_position = position
	z_index = 5
	
	sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	update_from_data()

	sprite.scale = Vector2(0.8, 0.8)
	offset_from_player = Vector2(randf_range(-70, 70), randf_range(-55, 65))
	flower_offset = Vector2(randf_range(-22, 22), randf_range(-18, 18))
	flight_phase = randf_range(0.0, TAU)
	speed = randf_range(125.0, 180.0)
	bob_speed = randf_range(7.0, 12.0)
	bob_height = randf_range(5.0, 10.0)
	add_to_group("bees")

func update_from_data() -> void:
	if sprite == null:
		return

	if "texture" in bee_data and bee_data["texture"] != "":
		sprite.texture = load(bee_data["texture"])
	else:
		var tex = load("res://assets/game/animals/classicbee.png")
		if tex:
			sprite.texture = tex
			
	if "color" in bee_data and sprite.texture:
		sprite.self_modulate = bee_data["color"]
	else:
		sprite.self_modulate = Color.WHITE

func _process(delta):
	if not is_instance_valid(player):
		return

	var target_pos = player.position + offset_from_player

	if current_flower != null and is_instance_valid(current_flower) and current_flower.nectar_amount > 0:
		var flower_pos = get_node_local_position(current_flower)
		var orbit = Vector2(cos(bob_time * 2.2 + flight_phase), sin(bob_time * 2.7 + flight_phase)) * 8.0
		target_pos = flower_pos + flower_offset + orbit
		if base_position.distance_to(flower_pos) < 34.0:
			current_flower.gather(self, delta)
	else:
		var flowers = get_tree().get_nodes_in_group("flowers")
		var closest = null
		var dist = 999999.0
		for f in flowers:
			if f.nectar_amount > 0:
				var flower_pos = get_node_local_position(f)
				var d = base_position.distance_to(flower_pos)
				if d < 180.0 and d < dist:
					closest = f
					dist = d
		current_flower = closest

	var dir = (target_pos - base_position).normalized()
	base_position = base_position.move_toward(target_pos, speed * delta)
	
	if dir.x != 0:
		sprite.flip_h = dir.x > 0
		
	bob_time += delta
	var bob_offset = Vector2(0, sin(bob_time * bob_speed) * bob_height)
	
	position = base_position + bob_offset

func gather_nectar(amount: float):
	if is_instance_valid(player):
		player.add_pollen(amount)

func get_node_local_position(node: Node2D) -> Vector2:
	if get_parent() is Node2D:
		return get_parent().to_local(node.global_position)
	return node.global_position
